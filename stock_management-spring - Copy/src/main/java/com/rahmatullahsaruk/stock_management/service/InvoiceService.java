package com.rahmatullahsaruk.stock_management.service;

import com.rahmatullahsaruk.stock_management.entity.Invoice;
import com.rahmatullahsaruk.stock_management.entity.InvoiceItem;
import com.rahmatullahsaruk.stock_management.entity.Product;
import com.rahmatullahsaruk.stock_management.repository.InvoiceRepo;
import com.rahmatullahsaruk.stock_management.repository.ProductRepo;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class InvoiceService {

    @Autowired
    private InvoiceRepo invoiceRepo;

    @Autowired
    private ProductRepo productRepo;

    @Transactional
    public Invoice save(Invoice invoice) {
        List<InvoiceItem> invoiceItems = new ArrayList<>();

        for (InvoiceItem item : invoice.getItems()) {
            Product product = productRepo.findById(item.getProduct().getId())
                    .orElseThrow(() -> new RuntimeException("Product not found with ID: " + item.getProduct().getId()));

            // Check stock
            int remainingQty = product.getQuantity() - item.getQuantity();
            if (remainingQty < 0) {
                throw new RuntimeException("Insufficient stock for product: " + product.getName());
            }

            product.setQuantity(remainingQty);
            productRepo.save(product);

            // Create InvoiceItem
            InvoiceItem invoiceItem = new InvoiceItem();
            invoiceItem.setInvoice(invoice);
            invoiceItem.setProduct(product);
            invoiceItem.setQuantity(item.getQuantity());
            invoiceItem.setPriceAtSale(product.getPrice());

            invoiceItems.add(invoiceItem);
        }

        invoice.setItems(invoiceItems);

        if (invoice.getDate() == null) {
            invoice.setDate(LocalDateTime.now());
        }
        if (invoice.getInvoiceNumber() == null) {
            invoice.setInvoiceNumber("INV-" + System.currentTimeMillis());
        }

        invoice.calculateTotals();

        return invoiceRepo.save(invoice);
    }


    public List<Invoice> getAll() {
        return invoiceRepo.findAll();
    }

    public Optional<Invoice> getById(Long id) {
        return invoiceRepo.findById(id);
    }

    public void delete(Long id) {
        invoiceRepo.deleteById(id);
    }

    // salesdashboard

    public Double getTodaySales() {
        LocalDateTime start = LocalDate.now().atStartOfDay();
        LocalDateTime end = LocalDateTime.now();
        return invoiceRepo.getSalesBetween(start, end);
    }

    public Double getLast7DaysSales() {
        LocalDateTime start = LocalDate.now().minusDays(7).atStartOfDay();
        LocalDateTime end = LocalDateTime.now();
        return invoiceRepo.getSalesBetween(start, end);
    }

    public Double getLast30DaysSales() {
        LocalDateTime start = LocalDate.now().minusDays(30).atStartOfDay();
        LocalDateTime end = LocalDateTime.now();
        return invoiceRepo.getSalesBetween(start, end);
    }

    // salesdashboard end
}
