package com.rahmatullahsaruk.stock_management.restcontroller;

import com.rahmatullahsaruk.stock_management.dto.InvoiceDTO;
import com.rahmatullahsaruk.stock_management.dto.SalesSummaryDTO;
import com.rahmatullahsaruk.stock_management.entity.Invoice;
import com.rahmatullahsaruk.stock_management.entity.Product;
import com.rahmatullahsaruk.stock_management.mapper.InvoiceMapper;
import com.rahmatullahsaruk.stock_management.repository.InvoiceRepo;
import com.rahmatullahsaruk.stock_management.service.InvoiceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/invoices")
public class InvoiceController {

    @Autowired
    private InvoiceService invoiceService;

    @Autowired
    private InvoiceRepo invoiceRepo;

    // ✅ Create Invoice
    @PostMapping
    public ResponseEntity<InvoiceDTO> createInvoice(@RequestBody Invoice invoice) {
        Invoice saved = invoiceService.save(invoice);
        return ResponseEntity.ok(InvoiceMapper.toDTO(saved));
    }

    // ✅ Get All Invoices
    @GetMapping
    public ResponseEntity<List<InvoiceDTO>> getAllInvoices() {
        List<Invoice> invoices = invoiceService.getAll();
        List<InvoiceDTO> invoiceDTOs = invoices.stream()
                .map(InvoiceMapper::toDTO)
                .toList();
        return ResponseEntity.ok(invoiceDTOs);
    }

    // ✅ Get Invoice by ID
    @GetMapping("/{id}")
    public ResponseEntity<InvoiceDTO> getInvoiceById(@PathVariable Long id) {
        Optional<Invoice> invoiceOpt = invoiceService.getById(id);
        return invoiceOpt
                .map(invoice -> ResponseEntity.ok(InvoiceMapper.toDTO(invoice)))
                .orElse(ResponseEntity.notFound().build());
    }

    // ✅ Update Invoice
    @PutMapping("/{id}")
    public ResponseEntity<InvoiceDTO> updateInvoice(@PathVariable Long id, @RequestBody Invoice invoiceDetails) {
        Optional<Invoice> optionalInvoice = invoiceRepo.findById(id);

        if (optionalInvoice.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Invoice invoice = optionalInvoice.get();

        // Update basic fields
        invoice.setName(invoiceDetails.getName());
        invoice.setEmail(invoiceDetails.getEmail());
        invoice.setPhone(invoiceDetails.getPhone());
        invoice.setDiscount(invoiceDetails.getDiscount());
        invoice.setPaid(invoiceDetails.getPaid());
        invoice.setInvoiceNumber(invoiceDetails.getInvoiceNumber());

        // Clear old products and set new products, updating invoice ref
        invoice.getProducts().clear();
        if (invoiceDetails.getProducts() != null) {
            for (Product product : invoiceDetails.getProducts()) {
                product.setInvoice(invoice);
                invoice.getProducts().add(product);
            }
        }

        // Recalculate totals
        invoice.calculateTotals();

        Invoice updatedInvoice = invoiceRepo.save(invoice);
        return ResponseEntity.ok(InvoiceMapper.toDTO(updatedInvoice));
    }

    // ✅ Delete Invoice
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteInvoice(@PathVariable Long id) {
        if (!invoiceRepo.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        invoiceRepo.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    // dashboard sell summary
    @GetMapping("/sellsummary")
    public SalesSummaryDTO getSalesSummary() {
        Double today = invoiceService.getTodaySales();
        Double last7 = invoiceService.getLast7DaysSales();
        Double last30 = invoiceService.getLast30DaysSales();

        return new SalesSummaryDTO(today, last7, last30);
    }
}
