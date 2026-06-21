package com.zufar.icedlatte.payment.api;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zufar.icedlatte.email.message.EmailConfirmMessage;
import com.zufar.icedlatte.email.sender.AbstractEmailSender;
import com.zufar.icedlatte.order.api.OrderCreator;
import com.zufar.icedlatte.payment.exception.PaymentEventProcessingException;
import com.zufar.icedlatte.user.api.SingleUserProvider;
import com.zufar.icedlatte.user.entity.UserEntity;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;

@Slf4j
@RequiredArgsConstructor
@Service
@ConditionalOnProperty(name = "midtrans.enabled", havingValue = "true")
public class MidtransWebhookService {

    private final ObjectMapper objectMapper;
    private final OrderCreator orderCreator;
    private final AbstractEmailSender<EmailConfirmMessage> paymentEmailConfirmation;
    private final SingleUserProvider singleUserProvider;

    @Value("${midtrans.server-key}")
    private String serverKey;

    public void processWebhook(String payload) {
        log.info("midtrans.webhook.processing");
        try {
            JsonNode event = objectMapper.readTree(payload);

            String orderId = event.path("order_id").asText();
            String statusCode = event.path("status_code").asText();
            String grossAmount = event.path("gross_amount").asText();
            String signatureKey = event.path("signature_key").asText();
            String transactionStatus = event.path("transaction_status").asText();
            String fraudStatus = event.path("fraud_status").asText();
            String customField1 = event.path("custom_field1").asText(); // Contains userId

            // 1. Verify Signature
            verifySignature(orderId, statusCode, grossAmount, signatureKey);

            // 2. Check Payment Status
            if (isPaymentSuccessful(transactionStatus, fraudStatus)) {
                handleCompleted(customField1, orderId, grossAmount);
            } else {
                log.info("midtrans.webhook.ignored: status={}, fraud={}", transactionStatus, fraudStatus);
            }

            log.info("midtrans.webhook.processed: orderId={}", orderId);
        } catch (Exception e) {
            log.error("midtrans.webhook.error: {}", e.getMessage());
            throw new PaymentEventProcessingException("Failed to process Midtrans webhook");
        }
    }

    private void verifySignature(String orderId, String statusCode, String grossAmount, String signatureKey) {
        try {
            String rawString = orderId + statusCode + grossAmount + serverKey;
            MessageDigest digest = MessageDigest.getInstance("SHA-512");
            byte[] hash = digest.digest(rawString.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }

            if (!hexString.toString().equals(signatureKey)) {
                log.warn("midtrans.webhook.signature_invalid");
                throw new PaymentEventProcessingException("Invalid Midtrans Signature");
            }
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-512 algorithm not found", e);
        }
    }

    private boolean isPaymentSuccessful(String transactionStatus, String fraudStatus) {
        return ("capture".equals(transactionStatus) && "accept".equals(fraudStatus)) ||
               "settlement".equals(transactionStatus);
    }

    private void handleCompleted(String userIdStr, String orderId, String grossAmount) {
        if (userIdStr == null || userIdStr.isEmpty()) {
            log.warn("midtrans.webhook.no_user_id: orderId={}", orderId);
            return;
        }

        UUID userId = UUID.fromString(userIdStr);
        boolean created = orderCreator.createOrderAndDeleteCartMidtrans(userId, orderId);
        
        if (created) {
            try {
                UserEntity user = singleUserProvider.getUserEntityById(userId);
                
                // Construct a message to simulate Stripe session for the email sender if needed, 
                // or just send a raw notification. The AbstractEmailSender has sendNotification.
                paymentEmailConfirmation.sendNotification(user.getEmail(),
                        "Your payment with total amount - Rp " + grossAmount + " was successfully processed via Midtrans",
                        "Payment Confirmation for Your Recent Purchase (Midtrans)"
                );
                log.info("midtrans.webhook.email.sent: orderId={}", orderId);
            } catch (Exception e) {
                log.warn("midtrans.webhook.email.failed: orderId={}, error={}", orderId, e.getMessage());
            }
        } else {
            log.info("midtrans.webhook.already_processed: orderId={}", orderId);
        }
    }
}
