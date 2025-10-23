package com.rahmatullahsaruk.stock_management.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import jakarta.annotation.PostConstruct;
import com.twilio.Twilio;

@Configuration
public class TwilioConfig {
    @Value("${twilio.accountSid:}") private String sid;
    @Value("${twilio.authToken:}")  private String token;

    @PostConstruct
    public void init() {
        if (sid == null || sid.isBlank() || token == null || token.isBlank()) {
            System.out.println("[TWILIO] Skipping Twilio.init(); creds are not set.");
            return;
        }
        Twilio.init(sid, token);
        System.out.println("[TWILIO] Initialized");
    }
}
