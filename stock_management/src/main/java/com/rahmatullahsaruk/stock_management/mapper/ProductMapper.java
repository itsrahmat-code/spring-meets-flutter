package com.rahmatullahsaruk.stock_management.mapper;

import com.rahmatullahsaruk.stock_management.dto.ProductDTO;
import com.rahmatullahsaruk.stock_management.entity.Product;

public class ProductMapper {

    public static ProductDTO toDTO(Product product) {
        if (product == null) {
            return null;
        }

        ProductDTO dto = new ProductDTO();
        dto.setId(product.getId());
        dto.setProductName(product.getProductName());
        dto.setDescription(product.getDescription());
        dto.setPrice(product.getPrice());
        dto.setQuantity(product.getQuantity());
        dto.setInvoiceId(
                product.getInvoice() != null ? product.getInvoice().getId() : null
        );
        return dto;
    }

    public static Product toEntity(ProductDTO dto) {
        if (dto == null) {
            return null;
        }

        Product product = new Product();
        product.setId(dto.getId());
        product.setProductName(dto.getProductName());
        product.setDescription(dto.getDescription());
        product.setPrice(dto.getPrice());
        product.setQuantity(dto.getQuantity());
        // Invoice is set manually in InvoiceMapper to avoid circular reference
        return product;
    }
}
