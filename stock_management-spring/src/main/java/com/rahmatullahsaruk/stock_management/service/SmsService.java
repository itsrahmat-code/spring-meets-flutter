package com.rahmatullahsaruk.stock_management.service;
// SmsService.java
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;

@Service
public class SmsService {
    @Value("${twilio.fromNumber}") private String from;

    public String send(String toE164, String body) {
        Message m = Message.creator(new PhoneNumber(toE164), new PhoneNumber(from), body).create();
        return m.getSid();
    }
}
