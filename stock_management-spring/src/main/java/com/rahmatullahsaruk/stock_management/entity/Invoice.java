package com.rahmatullahsaruk.stock_management.entity;


import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "invoices")
public class Invoice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private LocalDateTime date;

    private String name;
    private String email;
    private String phone;
    private String address;

    private double subtotal;   // Sum of (product price * quantity)
    private double discount;   // Applied discount (if any)
    private double taxRate = 5.0;  // Sales tax in percentage
    private double taxAmount;  // (subtotal - discount) * (taxRate / 100)
    private double total;      // Final total (subtotal - discount + tax)

    private double paid;


    private String invoiceNumber;

    @OneToMany(mappedBy = "invoice", orphanRemoval = true)
    private List<Product> products ;

    public Invoice() {
    }

    public Invoice(Long id, LocalDateTime date, String name, String email, String phone, String address, double subtotal, double discount, double taxRate, double taxAmount, double total, double paid,  String invoiceNumber, List<Product> products) {
        this.id = id;
        this.date = date;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.subtotal = subtotal;
        this.discount = discount;
        this.taxRate = taxRate;
        this.taxAmount = taxAmount;
        this.total = total;
        this.paid = paid;

        this.invoiceNumber = invoiceNumber;
        this.products = products;
    }

    // --- Getters and Setters ---

    public Long getId() { return id; }

    public void setId(Long id) { this.id = id; }

    public LocalDateTime getDate() { return date; }

    public void setDate(LocalDateTime date) { this.date = date; }

    public String getName() { return name; }

    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }

    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }

    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }

    public void setAddress(String address) { this.address = address; }

    public double getSubtotal() { return subtotal; }

    public void setSubtotal(double subtotal) { this.subtotal = subtotal; }

    public double getDiscount() { return discount; }

    public void setDiscount(double discount) { this.discount = discount; }

    public double getTaxRate() { return taxRate; }

    public void setTaxRate(double taxRate) { this.taxRate = taxRate; }

    public double getTaxAmount() { return taxAmount; }

    public void setTaxAmount(double taxAmount) { this.taxAmount = taxAmount; }

    public double getTotal() { return total; }

    public void setTotal(double total) { this.total = total; }

    public double getPaid() { return paid; }

    public void setPaid(double paid) { this.paid = paid; }



    public String getInvoiceNumber() { return invoiceNumber; }

    public void setInvoiceNumber(String invoiceNumber) { this.invoiceNumber = invoiceNumber; }

    public List<Product> getProducts() { return products; }

    public void setProducts(List<Product> products) { this.products = products; }

    // Automatically calculate subtotal, tax, total and due
    public void calculateTotals() {
        this.subtotal = products.stream()
                .mapToDouble(p -> p.getPrice() * p.getQuantity())
                .sum();

        this.taxAmount = (subtotal - discount) * (taxRate / 100.0);
        this.total = subtotal - discount + taxAmount;

    }
}