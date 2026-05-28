package com.zufar.icedlatte.playground;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/playground")
public class PlaygroundController {

    @GetMapping("/hello")
    public ResponseEntity<Map<String, String>> sayHello() {
        return ResponseEntity.ok(Map.of(
            "message", "Halo bro! API Java murni berhasil dibuat tanpa YAML! 😎",
            "status", "success"
        ));
    }
}
