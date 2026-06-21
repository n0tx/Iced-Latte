package com.zufar.icedlatte.payment.endpoint;

import com.zufar.icedlatte.payment.api.MidtransSessionCreator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@RestController
@RequestMapping("/api/v1/payment/midtrans")
public class MidtransPaymentEndpoint {

    private final MidtransSessionCreator midtransSessionCreator;

    @PostMapping("/checkout")
    public ResponseEntity<Map<String, String>> processPayment() {
        String redirectUrl = midtransSessionCreator.createSession();
        log.info("midtrans.session.created: url={}", redirectUrl);
        return ResponseEntity.ok(Map.of("redirect_url", redirectUrl));
    }
}
