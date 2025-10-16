package com.rahmatullahsaruk.stock_management.dto;

import java.time.LocalDateTime;
import java.util.List;

public class InvoiceDTO {

    private Long id;
    private String invoiceNumber;
    private LocalDateTime date;

    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String customerAddress;

    private double subtotal;
    private double discount;
    private double taxRate;
    private double taxAmount;
    private double total;
    private double paid;

    // Include a list of products associated with this invoice
    private List<ProductDTO> products;

    public InvoiceDTO() {}

    public InvoiceDTO(Long id, String invoiceNumber, LocalDateTime date, String customerName,
                      String customerEmail, String customerPhone, String customerAddress,
                      double subtotal, double discount, double taxRate, double taxAmount,
                      double total, double paid, List<ProductDTO> products) {
        this.id = id;
        this.invoiceNumber = invoiceNumber;
        this.date = date;
        this.customerName = customerName;
        this.customerEmail = customerEmail;
        this.customerPhone = customerPhone;
        this.customerAddress = customerAddress;
        this.subtotal = subtotal;
        this.discount = discount;
        this.taxRate = taxRate;
        this.taxAmount = taxAmount;
        this.total = total;
        this.paid = paid;
        this.products = products;
    }

    // --- Getters and Setters ---
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getInvoiceNumber() {
        return invoiceNumber;
    }

    public void setInvoiceNumber(String invoiceNumber) {
        this.invoiceNumber = invoiceNumber;
    }

    public LocalDateTime getDate() {
        return date;
    }

    public void setDate(LocalDateTime date) {
        this.date = date;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getCustomerAddress() {
        return customerAddress;
    }

    public void setCustomerAddress(String customerAddress) {
        this.customerAddress = customerAddress;
    }

    public double getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(double subtotal) {
        this.subtotal = subtotal;
    }

    public double getDiscount() {
        return discount;
    }

    public void setDiscount(double discount) {
        this.discount = discount;
    }

    public double getTaxRate() {
        return taxRate;
    }

    public void setTaxRate(double taxRate) {
        this.taxRate = taxRate;
    }

    public double getTaxAmount() {
        return taxAmount;
    }

    public void setTaxAmount(double taxAmount) {
        this.taxAmount = taxAmount;
    }

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }

    public double getPaid() {
        return paid;
    }

    public void setPaid(double paid) {
        this.paid = paid;
    }

    public List<ProductDTO> getProducts() {
        return products;
    }

    public void setProducts(List<ProductDTO> products) {
        this.products = products;
    }
}
