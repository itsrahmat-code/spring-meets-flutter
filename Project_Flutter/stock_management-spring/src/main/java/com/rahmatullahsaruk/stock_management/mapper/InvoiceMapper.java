package com.rahmatullahsaruk.stock_management.mapper;



import com.rahmatullahsaruk.stock_management.dto.InvoiceDTO;
import com.rahmatullahsaruk.stock_management.dto.InvoiceItemDTO;
import com.rahmatullahsaruk.stock_management.entity.Invoice;
import com.rahmatullahsaruk.stock_management.entity.InvoiceItem;

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
        dto.setSubtotal(invoice.getSubtotal());
        dto.setDiscount(invoice.getDiscount());
        dto.setTotal(invoice.getTotal());
        dto.setPaid(invoice.getPaid());

        dto.setItems(invoice.getItems().stream().map(InvoiceMapper::toItemDTO).collect(Collectors.toList()));
        return dto;
    }

    private static InvoiceItemDTO toItemDTO(InvoiceItem item) {
        InvoiceItemDTO dto = new InvoiceItemDTO();
        dto.setProductId(item.getProduct().getId());
        dto.setProductName(item.getProduct().getName());
        dto.setQuantity(item.getQuantity());
        dto.setPriceAtSale(item.getPriceAtSale());
        return dto;
    }
}
