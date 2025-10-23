package com.rahmatullahsaruk.stock_management.service;

import com.rahmatullahsaruk.stock_management.entity.Invoice;
import com.rahmatullahsaruk.stock_management.entity.InvoiceItem;
import com.rahmatullahsaruk.stock_management.entity.Product;
import com.rahmatullahsaruk.stock_management.repository.InvoiceRepo;
import com.rahmatullahsaruk.stock_management.repository.ProductRepo;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import jakarta.annotation.PostConstruct;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class InvoiceService {

    @Autowired private InvoiceRepo invoiceRepo;
    @Autowired private ProductRepo productRepo;

    // ---- Email ----
    @Autowired(required = false)
    private JavaMailSender mailSender;

    // ---- Twilio (props -> env) ----
    @Value("${twilio.accountSid:}")          private String twilioSid;
    @Value("${twilio.authToken:}")           private String twilioToken;
    @Value("${twilio.fromNumber:}")          private String twilioFrom;              // if using a single number
    @Value("${twilio.messagingServiceSid:}") private String twilioMessagingSid;      // recommended in BD

    @PostConstruct
    public void printTwilioStatus() {
        System.out.println("[TWILIO CONFIG] SID set: " + !isBlank(twilioSid));
        System.out.println("[TWILIO CONFIG] Token set: " + !isBlank(twilioToken));
        System.out.println("[TWILIO CONFIG] FromNumber set: " + !isBlank(twilioFrom));
        System.out.println("[TWILIO CONFIG] MessagingServiceSid set: " + !isBlank(twilioMessagingSid));
    }

    @Transactional
    public Invoice save(Invoice invoice) {
        List<InvoiceItem> invoiceItems = new ArrayList<>();

        for (InvoiceItem item : invoice.getItems()) {
            Product product = productRepo.findById(item.getProduct().getId())
                    .orElseThrow(() -> new RuntimeException("Product not found with ID: " + item.getProduct().getId()));

            int remainingQty = product.getQuantity() - item.getQuantity();
            if (remainingQty < 0) throw new RuntimeException("Insufficient stock for product: " + product.getName());
            product.setQuantity(remainingQty);
            productRepo.save(product);

            InvoiceItem invoiceItem = new InvoiceItem();
            invoiceItem.setInvoice(invoice);
            invoiceItem.setProduct(product);
            invoiceItem.setQuantity(item.getQuantity());

            double clientPrice = item.getPriceAtSale(); // primitive double (default 0.0)
            invoiceItem.setPriceAtSale(clientPrice > 0 ? clientPrice : product.getPrice());

            invoiceItems.add(invoiceItem);
        }

        invoice.setItems(invoiceItems);

        if (invoice.getDate() == null) invoice.setDate(LocalDateTime.now());
        if (invoice.getInvoiceNumber() == null) invoice.setInvoiceNumber("INV-" + System.currentTimeMillis());

        invoice.calculateTotals();
        return invoiceRepo.save(invoice);
    }

    public List<Invoice> getAll() { return invoiceRepo.findAll(); }
    public Optional<Invoice> getById(Long id) { return invoiceRepo.findById(id); }
    public void delete(Long id) { invoiceRepo.deleteById(id); }

    // ---- Sales dashboard helpers (null-safe) ----
    public Double getTodaySales() {
        LocalDateTime start = LocalDate.now().atStartOfDay();
        LocalDateTime end = LocalDateTime.now();
        Double v = invoiceRepo.getSalesBetween(start, end);
        return v != null ? v : 0.0;
    }
    public Double getLast7DaysSales() {
        LocalDateTime start = LocalDate.now().minusDays(7).atStartOfDay();
        LocalDateTime end = LocalDateTime.now();
        Double v = invoiceRepo.getSalesBetween(start, end);
        return v != null ? v : 0.0;
    }
    public Double getLast30DaysSales() {
        LocalDateTime start = LocalDate.now().minusDays(30).atStartOfDay();
        LocalDateTime end = LocalDateTime.now();
        Double v = invoiceRepo.getSalesBetween(start, end);
        return v != null ? v : 0.0;
    }

    // ---- Send Receipt (Email/SMS) ----
    public void sendReceipt(Long invoiceId, String channel, String email, String phone) {
        if (invoiceId == null) throw new IllegalArgumentException("Missing invoice id");

        Invoice inv = invoiceRepo.findById(invoiceId)
                .orElseThrow(() -> new IllegalArgumentException("Invoice not found: " + invoiceId));

        String receiptText = buildReceiptText(inv);

        switch (channel == null ? "" : channel.toUpperCase()) {
            case "EMAIL" -> {
                if (isBlank(email)) throw new IllegalArgumentException("Email is required for EMAIL channel");
                sendEmail(email, "Your Invoice " + inv.getInvoiceNumber(), receiptText);
            }
            case "SMS" -> {
                if (isBlank(phone)) throw new IllegalArgumentException("Phone is required for SMS channel");
                String to = normalizeBangladesh(phone); // make +8801xxxxxxxxx if needed
                sendSms(to, receiptText);
            }
            default -> throw new IllegalArgumentException("Unsupported channel: " + channel);
        }
    }

    private void sendEmail(String to, String subject, String text) {
        if (mailSender == null) throw new IllegalStateException("Mail sender not configured");
        SimpleMailMessage msg = new SimpleMailMessage();
        msg.setTo(to);
        msg.setSubject(subject);
        msg.setText(text);
        mailSender.send(msg);
        System.out.println("[EMAIL SENT] to " + to);
    }

    private void sendSms(String toE164, String body) {
        if (isBlank(twilioSid) || isBlank(twilioToken)) {
            throw new IllegalStateException("Twilio SID/TOKEN not configured");
        }
        try {
            Message message;
            if (!isBlank(twilioMessagingSid)) {
                // ✅ Messaging Service (recommended in BD)
                message = Message.creator(new PhoneNumber(toE164), twilioMessagingSid, body).create();
            } else if (!isBlank(twilioFrom)) {
                // ✅ Single Twilio number
                message = Message.creator(new PhoneNumber(toE164), new PhoneNumber(twilioFrom), body).create();
            } else {
                throw new IllegalStateException("Either twilio.messagingServiceSid or twilio.fromNumber must be set");
            }
            System.out.println("[TWILIO SENT] SID=" + message.getSid() + " to=" + toE164);
        } catch (Exception e) {
            System.err.println("[TWILIO ERROR] " + e.getClass().getSimpleName() + ": " + e.getMessage());
            throw e;
        }
    }

    private String buildReceiptText(Invoice inv) {
        StringBuilder sb = new StringBuilder();
        sb.append("Invoice ").append(inv.getInvoiceNumber()).append("\n")
                .append("Customer: ").append(inv.getName() == null ? "-" : inv.getName()).append("\n")
                .append("Date: ").append(inv.getDate()).append("\n")
                .append("--------------------------------\n");
        for (InvoiceItem it : inv.getItems()) {
            String name = it.getProduct() != null ? it.getProduct().getName() : "Item";
            sb.append(name)
                    .append(" x").append(it.getQuantity())
                    .append(" @ ").append(it.getPriceAtSale())
                    .append(" = ").append(it.getPriceAtSale() * it.getQuantity())
                    .append("\n");
        }
        sb.append("--------------------------------\n")
                .append("Subtotal: ").append(inv.getSubtotal()).append("\n")
                .append("Discount: ").append(inv.getDiscount()).append("\n")
                .append("Total: ").append(inv.getTotal()).append("\n")
                .append("Paid: ").append(inv.getPaid()).append("\n")
                .append("Due: ").append(inv.getTotal() - inv.getPaid()).append("\n");
        return sb.toString();
    }

    private String normalizeBangladesh(String input) {
        String s = input == null ? "" : input.trim();
        if (s.startsWith("+")) return s;      // already E.164
        s = s.replaceAll("[^0-9]", "");
        if (s.startsWith("0")) s = s.substring(1);
        if (!s.startsWith("1")) s = "1" + s;  // ensure 1xxxxxxxxx
        return "+880" + s;
    }

    private boolean isBlank(String s) { return s == null || s.isBlank(); }
}
