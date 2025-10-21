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
        dto.setName(product.getName());
        dto.setCategory(product.getCategory());
        dto.setBrand(product.getBrand());
        dto.setModel(product.getModel());
        dto.setDetails(product.getDetails());
        dto.setQuantity(product.getQuantity());
        dto.setPrice(product.getPrice());

        return dto;
    }

    public static Product toEntity(ProductDTO dto) {
        if (dto == null) {
            return null;
        }

        Product product = new Product();
        product.setId(dto.getId());
        product.setName(dto.getName());
        product.setCategory(dto.getCategory());
        product.setBrand(dto.getBrand());
        product.setModel(dto.getModel());
        product.setDetails(dto.getDetails());
        product.setQuantity(dto.getQuantity());
        product.setPrice(dto.getPrice());

        return product;
    }
}
