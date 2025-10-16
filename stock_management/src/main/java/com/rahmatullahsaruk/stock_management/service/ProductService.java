package com.rahmatullahsaruk.stock_management.service;

import com.rahmatullahsaruk.stock_management.dto.ProductDTO;
import com.rahmatullahsaruk.stock_management.entity.Product;
import com.rahmatullahsaruk.stock_management.mapper.ProductMapper;
import com.rahmatullahsaruk.stock_management.repository.ProductRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class ProductService {

    private final ProductRepo productRepo;

    @Autowired
    public ProductService(ProductRepo productRepo) {
        this.productRepo = productRepo;
    }

    public Product saveProduct(Product product) {
        return productRepo.save(product);
    }

    public List<Product> getAllProducts() {
        return productRepo.findAll();
    }

    public Optional<Product> getProductById(Long id) {
        return productRepo.findById(id);
    }

    public void deleteProduct(Long id) {
        productRepo.deleteById(id);
    }

    // Convert all entities to DTOs
    public List<ProductDTO> getAllProductDTOs() {
        return productRepo.findAll().stream()
                .map(ProductMapper::toDTO)
                .collect(Collectors.toList());
    }
}
