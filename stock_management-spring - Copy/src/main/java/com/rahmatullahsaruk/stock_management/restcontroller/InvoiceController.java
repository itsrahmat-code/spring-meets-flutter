package com.rahmatullahsaruk.stock_management.restcontroller;

import com.rahmatullahsaruk.stock_management.dto.InvoiceDTO;
import com.rahmatullahsaruk.stock_management.dto.SalesSummaryDTO;
import com.rahmatullahsaruk.stock_management.entity.Invoice;
import com.rahmatullahsaruk.stock_management.entity.InvoiceItem;
import com.rahmatullahsaruk.stock_management.mapper.InvoiceMapper;
import com.rahmatullahsaruk.stock_management.repository.InvoiceRepo;
import com.rahmatullahsaruk.stock_management.service.InvoiceService;
import com.twilio.exception.ApiException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/invoices")
public class InvoiceController {

    @Autowired private InvoiceService invoiceService;
    @Autowired private InvoiceRepo invoiceRepo;

    @PostMapping
    public ResponseEntity<InvoiceDTO> createInvoice(@RequestBody Invoice invoice) {
        Invoice saved = invoiceService.save(invoice);
        return ResponseEntity.ok(InvoiceMapper.toDTO(saved));
    }

    @PostMapping("/{id}/send-receipt")
    public ResponseEntity<?> sendReceipt(@PathVariable Long id,
                                         @RequestBody Map<String, String> payload) {
        String channel = payload.getOrDefault("channel", "EMAIL");
        String email   = payload.get("email");
        String phone   = payload.get("phone");
        try {
            invoiceService.sendReceipt(id, channel, email, phone);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Bad request: " + e.getMessage());
        } catch (ApiException e) { // Twilio error with a helpful message
            return ResponseEntity.status(502).body("Twilio error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError()
                    .body("Server error: " + e.getClass().getSimpleName() + ": " + e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<List<InvoiceDTO>> getAllInvoices() {
        List<Invoice> invoices = invoiceService.getAll();
        List<InvoiceDTO> dtoList = invoices.stream().map(InvoiceMapper::toDTO).toList();
        return ResponseEntity.ok(dtoList);
    }

    @GetMapping("/{id}")
    public ResponseEntity<InvoiceDTO> getInvoiceById(@PathVariable Long id) {
        Optional<Invoice> invoiceOpt = invoiceService.getById(id);
        return invoiceOpt
                .map(invoice -> ResponseEntity.ok(InvoiceMapper.toDTO(invoice)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<InvoiceDTO> updateInvoice(@PathVariable Long id,
                                                    @RequestBody Invoice updatedData) {
        Optional<Invoice> opt = invoiceRepo.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        Invoice existing = opt.get();
        existing.setName(updatedData.getName());
        existing.setEmail(updatedData.getEmail());
        existing.setPhone(updatedData.getPhone());
        existing.setDiscount(updatedData.getDiscount());
        existing.setPaid(updatedData.getPaid());
        existing.setInvoiceNumber(updatedData.getInvoiceNumber());

        existing.getItems().clear();
        if (updatedData.getItems() != null) {
            for (InvoiceItem item : updatedData.getItems()) {
                item.setInvoice(existing);
                existing.getItems().add(item);
            }
        }

        existing.calculateTotals();
        Invoice saved = invoiceRepo.save(existing);
        return ResponseEntity.ok(InvoiceMapper.toDTO(saved));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteInvoice(@PathVariable Long id) {
        if (!invoiceRepo.existsById(id)) return ResponseEntity.notFound().build();
        invoiceRepo.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/sellsummary")
    public SalesSummaryDTO getSalesSummary() {
        Double today  = invoiceService.getTodaySales();
        Double last7  = invoiceService.getLast7DaysSales();
        Double last30 = invoiceService.getLast30DaysSales();
        return new SalesSummaryDTO(today, last7, last30);
    }
}
