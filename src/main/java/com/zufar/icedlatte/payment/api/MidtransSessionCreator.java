package com.zufar.icedlatte.payment.api;

import com.zufar.icedlatte.cart.api.ShoppingCartProvider;
import com.zufar.icedlatte.openapi.dto.ShoppingCartDto;
import com.zufar.icedlatte.openapi.dto.UserDto;
import com.zufar.icedlatte.security.api.SecurityPrincipalProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Slf4j
@RequiredArgsConstructor
@Service
public class MidtransSessionCreator {

    private final SecurityPrincipalProvider securityPrincipalProvider;
    private final ShoppingCartProvider shoppingCartProvider;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${midtrans.server-key}")
    private String serverKey;

    @Value("${midtrans.api-url}")
    private String apiUrl;

    public String createSession() {
        log.info("midtrans.session.initiating");
        UserDto user = securityPrincipalProvider.get();
        UUID userId = user.getId();
        ShoppingCartDto cart = shoppingCartProvider.getByUserId(userId);

        // 1. Siapkan Headers (Autorisasi Basic Auth)
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        String authString = serverKey + ":";
        String encodedAuth = Base64.getEncoder().encodeToString(authString.getBytes());
        headers.set("Authorization", "Basic " + encodedAuth);

        // 2. Siapkan Payload (Body JSON)
        Map<String, Object> requestBody = new HashMap<>();
        
        // Transaction Details
        Map<String, Object> transactionDetails = new HashMap<>();
        transactionDetails.put("order_id", "ORDER-MID-" + UUID.randomUUID().toString().substring(0, 8));
        
        // Midtrans butuh harga integer (Rupiah), kita kalikan harga dollar dengan kurs Rp 15.000
        int grossAmount = (int) (cart.getItemsTotalPrice().doubleValue() * 15000); 
        transactionDetails.put("gross_amount", grossAmount);
        
        // Customer Details
        Map<String, Object> customerDetails = new HashMap<>();
        customerDetails.put("first_name", user.getFirstName());
        customerDetails.put("last_name", user.getLastName());
        customerDetails.put("email", user.getEmail());

        requestBody.put("transaction_details", transactionDetails);
        requestBody.put("customer_details", customerDetails);

        // 3. Tembak API Midtrans
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
        
        try {
            Map<String, Object> response = restTemplate.postForObject(apiUrl, entity, Map.class);
            String redirectUrl = (String) response.get("redirect_url");
            
            log.info("========== LINK PEMBAYARAN MIDTRANS ==========");
            log.info("Silakan klik link ini untuk membayar: {}", redirectUrl);
            log.info("============================================");
            
            return redirectUrl;
        } catch (Exception e) {
            log.error("Gagal membuat sesi Midtrans: {}", e.getMessage());
            throw new RuntimeException("Gagal membuat sesi pembayaran Midtrans");
        }
    }
}
