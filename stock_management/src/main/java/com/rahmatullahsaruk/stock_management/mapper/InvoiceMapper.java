package com.rahmatullahsaruk.stock_management.mapper;

import com.rahmatullahsaruk.stock_management.dto.InvoiceDTO;
import com.rahmatullahsaruk.stock_management.dto.ProductDTO;
import com.rahmatullahsaruk.stock_management.entity.Invoice;
import com.rahmatullahsaruk.stock_management.entity.Product;

import java.util.List;
import java.util.stream.Collectors;

public class InvoiceMapper {

    public static InvoiceDTO toDTO(Invoice invoice) {
        if (invoice == null) {
            return null;
        }

        InvoiceDTO dto = new InvoiceDTO();
        dto.setId(invoice.getId());
        dto.setInvoiceNumber(invoice.getInvoiceNumber());
        dto.setDate(invoice.getDate());
        dto.setCustomerName(invoice.getCustomerName());
        dto.setCustomerEmail(invoice.getCustomerEmail());
        dto.setCustomerPhone(invoice.getCustomerPhone());
        dto.setCustomerAddress(invoice.getCustomerAddress());
        dto.setSubtotal(invoice.getSubtotal());
        dto.setDiscount(invoice.getDiscount());
        dto.setTaxRate(invoice.getTaxRate());
        dto.setTaxAmount(invoice.getTaxAmount());
        dto.setTotal(invoice.getTotal());
        dto.setPaid(invoice.getPaid());

        // Convert product list to DTOs
        if (invoice.getProducts() != null) {
            List<ProductDTO> productDTOs = invoice.getProducts().stream()
                    .map(ProductMapper::toDTO)
                    .collect(Collectors.toList());
            dto.setProducts(productDTOs);
        }

        return dto;
    }

    public static Invoice toEntity(InvoiceDTO dto) {
        if (dto == null) {
            return null;
        }

        Invoice invoice = new Invoice();
        invoice.setId(dto.getId());
        invoice.setInvoiceNumber(dto.getInvoiceNumber());
        invoice.setDate(dto.getDate());
        invoice.setCustomerName(dto.getCustomerName());
        invoice.setCustomerEmail(dto.getCustomerEmail());
        invoice.setCustomerPhone(dto.getCustomerPhone());
        invoice.setCustomerAddress(dto.getCustomerAddress());
        invoice.setSubtotal(dto.getSubtotal());
        invoice.setDiscount(dto.getDiscount());
        invoice.setTaxRate(dto.getTaxRate());
        invoice.setTaxAmount(dto.getTaxAmount());
        invoice.setTotal(dto.getTotal());
        invoice.setPaid(dto.getPaid());

        // Convert ProductDTOs to Product entities and link them to the invoice
        if (dto.getProducts() != null) {
            List<Product> products = dto.getProducts().stream()
                    .map(ProductMapper::toEntity)
                    .peek(product -> product.setInvoice(invoice))
                    .collect(Collectors.toList());
            invoice.setProducts(products);
        }

        return invoice;
    }
}
