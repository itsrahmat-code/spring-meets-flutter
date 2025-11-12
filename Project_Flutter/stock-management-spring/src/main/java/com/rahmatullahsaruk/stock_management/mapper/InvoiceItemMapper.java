package com.rahmatullahsaruk.stock_management.mapper;

import com.rahmatullahsaruk.stock_management.dto.InvoiceItemDTO;
import com.rahmatullahsaruk.stock_management.entity.Invoice;
import com.rahmatullahsaruk.stock_management.entity.InvoiceItem;
import com.rahmatullahsaruk.stock_management.entity.Product;
import com.rahmatullahsaruk.stock_management.repository.ProductRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class InvoiceItemMapper {

    @Autowired
    private ProductRepo productRepo;

    // Convert Entity → DTO
    public InvoiceItemDTO toDTO(InvoiceItem item) {
        if (item == null || item.getProduct() == null) return null;

        InvoiceItemDTO dto = new InvoiceItemDTO();
        dto.setProductId(item.getProduct().getId());
        dto.setProductName(item.getProduct().getName());
        dto.setQuantity(item.getQuantity());
        dto.setPriceAtSale(item.getPriceAtSale());
        return dto;
    }

    // Convert DTO → Entity (requires Product lookup and parent Invoice)
    public InvoiceItem toEntity(InvoiceItemDTO dto, Invoice invoice) {
        if (dto == null) return null;

        Product product = productRepo.findById(dto.getProductId())
                .orElseThrow(() -> new IllegalArgumentException("Product not found with ID: " + dto.getProductId()));

        InvoiceItem item = new InvoiceItem();
        item.setProduct(product);
        item.setInvoice(invoice);
        item.setQuantity(dto.getQuantity());
        item.setPriceAtSale(dto.getPriceAtSale());

        return item;
    }
}
