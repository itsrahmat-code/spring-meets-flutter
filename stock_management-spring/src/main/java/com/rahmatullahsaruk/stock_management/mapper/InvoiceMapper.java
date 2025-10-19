package com.rahmatullahsaruk.stock_management.mapper;



import com.rahmatullahsaruk.stock_management.dto.InvoiceDTO;
import com.rahmatullahsaruk.stock_management.dto.ProductDTO;
import com.rahmatullahsaruk.stock_management.entity.Invoice;
import com.rahmatullahsaruk.stock_management.entity.Product;

import java.util.stream.Collectors;

public class InvoiceMapper {



    public static InvoiceDTO toDTO(Invoice invoice) {
        InvoiceDTO dto = new InvoiceDTO();
        dto.setId(invoice.getId());
        dto.setInvoiceNumber(invoice.getInvoiceNumber());
        dto.setDate(invoice.getDate());

        dto.setName(invoice.getName());
        dto.setEmail(invoice.getEmail());
        dto.setPhone(invoice.getPhone());
        dto.setAddress(invoice.getAddress());

        dto.setSubtotal(invoice.getSubtotal());
        dto.setDiscount(invoice.getDiscount());
        dto.setTaxRate(invoice.getTaxRate());
        dto.setTaxAmount(invoice.getTaxAmount());
        dto.setTotal(invoice.getTotal());
        dto.setPaid(invoice.getPaid());


        dto.setProducts(invoice.getProducts()
                .stream()
                .map(InvoiceMapper::toProductDTO)
                .collect(Collectors.toList()));

        return dto;
    }

    private static ProductDTO toProductDTO(Product product) {
        ProductDTO dto = new ProductDTO();
        dto.setId(product.getId());   // if you want null → just remove this line
        dto.setName(product.getName());
        dto.setCategory(product.getCategory());
        dto.setBrand(product.getBrand());
        dto.setModel(product.getModel());
        dto.setDetails(product.getDetails());
        dto.setQuantity(product.getQuantity());
        dto.setPrice(product.getPrice());
        return dto;
    }



}