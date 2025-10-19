package com.rahmatullahsaruk.stock_management.service;

import com.rahmatullahsaruk.stock_management.entity.Invoice;
import com.rahmatullahsaruk.stock_management.entity.Product;
import com.rahmatullahsaruk.stock_management.repository.InvoiceRepo;
import com.rahmatullahsaruk.stock_management.repository.ProductRepo;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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
        List<Product> soldProducts = new ArrayList<>();

        for (Product invoiceProduct : invoice.getProducts()) {
            // Fetch the actual product from the database
            Product stockProduct = productRepo.findById(invoiceProduct.getId())
                    .orElseThrow(() -> new RuntimeException("Product not found with id: " + invoiceProduct.getId()));

            // Deduct stock quantity
            int newQuantity = stockProduct.getQuantity() - invoiceProduct.getQuantity();
            if (newQuantity < 0) {
                throw new RuntimeException("Not enough stock for product: " + stockProduct.getName());
            }
            stockProduct.setQuantity(newQuantity);
            productRepo.save(stockProduct);

            // Create a snapshot product for the invoice
            Product sold = new Product();
            sold.setName(stockProduct.getName());
            sold.setDetails(stockProduct.getDetails());
            sold.setPrice(stockProduct.getPrice());
            sold.setQuantity(invoiceProduct.getQuantity()); // Sold quantity
            sold.setInvoice(invoice);

            soldProducts.add(sold);
        }

        // Set products to invoice
        invoice.setProducts(soldProducts);

        // Set defaults if needed
        if (invoice.getDate() == null) {
            invoice.setDate(LocalDateTime.now());
        }

        if (invoice.getInvoiceNumber() == null || invoice.getInvoiceNumber().isBlank()) {
            invoice.setInvoiceNumber("INV-" + System.currentTimeMillis());
        }

        // Auto-calculate subtotal, tax, total
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
}
