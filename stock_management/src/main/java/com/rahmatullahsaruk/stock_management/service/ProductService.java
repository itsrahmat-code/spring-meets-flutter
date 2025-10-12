package com.rahmatullahsaruk.stock_management.service;

import com.rahmatullahsaruk.stock_management.entity.Product;
import com.rahmatullahsaruk.stock_management.repository.ProductRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductService {

    private final ProductRepo productRepo;

    @Autowired
    public ProductService(ProductRepo productRepo) {
        this.productRepo = productRepo;
    }

    // Create or update a product
    public Product saveProduct(Product product) {
        return productRepo.save(product);
    }

    // Get all products
    public List<Product> getAllProducts() {
        return productRepo.findAll();
    }

    // Get product by ID
    public Optional<Product> getProductById(Long id) {
        return productRepo.findById(id);
    }

    // Delete product by ID
    public void deleteProduct(Long id) {
        productRepo.deleteById(id);
    }

    // Example method to get all products as DTOs (if needed)
    public List<Product> getAllProductDTOs() {
        return productRepo.findAll().stream().map(product -> {
            Product dto = new Product();
            dto.setId(product.getId());
            dto.setProductname(product.getProductname());
            dto.setDescription(product.getDescription());
            dto.setPrice(product.getPrice());
            return dto;
        }).toList();
    }
}
