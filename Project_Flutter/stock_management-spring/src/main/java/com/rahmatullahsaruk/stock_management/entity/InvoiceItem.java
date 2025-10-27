package com.rahmatullahsaruk.stock_management.entity;

import jakarta.persistence.*;

@Entity
public class InvoiceItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "invoice_id")
    private Invoice invoice;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;

    private int quantity;
    private double priceAtSale;

    // Getters and Setters


    public InvoiceItem() {
    }

    public InvoiceItem(Long id, Invoice invoice, Product product, int quantity, double priceAtSale) {
        this.id = id;
        this.invoice = invoice;
        this.product = product;
        this.quantity = quantity;
        this.priceAtSale = priceAtSale;

    }


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Invoice getInvoice() {
        return invoice;
    }

    public void setInvoice(Invoice invoice) {
        this.invoice = invoice;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getPriceAtSale() {
        return priceAtSale;
    }

    public void setPriceAtSale(double priceAtSale) {
        this.priceAtSale = priceAtSale;
    }




}
