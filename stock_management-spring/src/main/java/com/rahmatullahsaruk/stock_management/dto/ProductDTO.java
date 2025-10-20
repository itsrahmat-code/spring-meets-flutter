package com.rahmatullahsaruk.stock_management.dto;


import com.rahmatullahsaruk.stock_management.entity.Product;

public class ProductDTO {

    private Long id;
    private String name;
    private Product.Category category;
    private String brand;
    private String model;
    private String details;
    private int quantity;
    private double price;

    public ProductDTO() {}

    public ProductDTO(Long id, String name, Product.Category category, String brand, String model, String details,
                      int quantity, double price) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.brand = brand;
        this.model = model;
        this.details = details;
        this.quantity = quantity;
        this.price = price;
    }

    // --- Getters and Setters ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Product.Category getCategory() { return category; }
    public void setCategory(Product.Category category) { this.category = category; }

    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    // --- Utility ---
    public double getTotalPrice() {
        return price * quantity;
    }
}
