package com.rahmatullahsaruk.stock_management.dto;

public class ProductDTO {

    private Long id;
    private String productName;
    private String description;
    private double price;
    private int quantity;
    private Long invoiceId; // Optional: link to invoice without embedding the full entity

    public ProductDTO() {}

    public ProductDTO(Long id, String productName, String description, double price, int quantity, Long invoiceId) {
        this.id = id;
        this.productName = productName;
        this.description = description;
        this.price = price;
        this.quantity = quantity;
        this.invoiceId = invoiceId;
    }

    // --- Getters and Setters ---
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Long getInvoiceId() {
        return invoiceId;
    }

    public void setInvoiceId(Long invoiceId) {
        this.invoiceId = invoiceId;
    }

    // --- Utility ---
    public double getTotalPrice() {
        return price * quantity;
    }
}
