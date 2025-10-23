package com.rahmatullahsaruk.stock_management.security;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;

public class TwilioPing {
    static final String SID  = System.getenv("TWILIO_ACCOUNT_SID");
    static final String TOK  = System.getenv("TWILIO_AUTH_TOKEN");
    static final String FROM = System.getenv("TWILIO_FROM_NUMBER");      // e.g. +15017122661
    static final String MSGS = System.getenv("TWILIO_MESSAGING_SID");    // e.g. MGxxxxxxxx (optional, recommended)

    // Bangladesh mobile in E.164 format:
    static final String TO   = "+8801XXXXXXXXX";

    public static void main(String[] args) {
        Twilio.init(SID, TOK);

        Message message;
        if (MSGS != null && !MSGS.isBlank()) {
            // ✅ Use the 3-arg creator, then set the Messaging Service SID
            message = Message
                    .creator(new PhoneNumber(TO), new PhoneNumber(FROM), "Twilio test: it works ✅")
                    .setMessagingServiceSid(MSGS)
                    .create();
        } else {
            // ✅ Classic: send from a specific Twilio number
            message = Message
                    .creator(new PhoneNumber(TO), new PhoneNumber(FROM), "Twilio test: it works ✅")
                    .create();
        }

        System.out.println("SID: " + message.getSid());
    }
}
