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
            // Fetch stock product from DB
            Product stockProduct = productRepo.findById(invoiceProduct.getId())
                    .orElseThrow(() -> new RuntimeException("Product not found with id: " + invoiceProduct.getId()));

            // Deduct stock
            int newQuantity = stockProduct.getQuantity() - invoiceProduct.getQuantity();
            if (newQuantity < 0) {
                throw new RuntimeException("Not enough stock for product: " + stockProduct.getProductName());
            }
            stockProduct.setQuantity(newQuantity);
            productRepo.save(stockProduct); // ✅ save updated stock

            // Create snapshot product for the invoice
            Product sold = new Product();
            sold.setProductName(stockProduct.getProductName());
            sold.setDescription(stockProduct.getDescription());
            sold.setPrice(stockProduct.getPrice());
            sold.setQuantity(invoiceProduct.getQuantity()); // sold quantity
            sold.setInvoice(invoice); // ✅ link to invoice

            soldProducts.add(sold);
        }

        invoice.setProducts(soldProducts);

        // Set defaults
        if (invoice.getDate() == null) {
            invoice.setDate(LocalDateTime.now());
        }
        if (invoice.getInvoiceNumber() == null) {
            invoice.setInvoiceNumber("INV-" + System.currentTimeMillis());
        }

        // Auto-calculate totals
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
