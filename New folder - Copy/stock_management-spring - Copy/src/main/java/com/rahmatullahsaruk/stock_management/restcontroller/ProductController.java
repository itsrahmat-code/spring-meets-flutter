package com.rahmatullahsaruk.stock_management.restcontroller;


import com.rahmatullahsaruk.stock_management.dto.ProductDTO;
import com.rahmatullahsaruk.stock_management.entity.Product;
import com.rahmatullahsaruk.stock_management.mapper.ProductMapper;
import com.rahmatullahsaruk.stock_management.service.ProductService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/product")
@CrossOrigin("*")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    // ✅ Create
    @PostMapping("/add")
    public ResponseEntity<ProductDTO> addProduct(@RequestBody ProductDTO dto) {
        Product product = ProductMapper.toEntity(dto);
        Product savedProduct = productService.saveProduct(product);
        return ResponseEntity.ok(ProductMapper.toDTO(savedProduct));
    }

    // ✅ Read all
    @GetMapping("/all")
    public List<ProductDTO> getAllProducts() {
        return productService.getAllProducts().stream()
                .map(ProductMapper::toDTO)
                .collect(Collectors.toList());
    }

    // ✅ Read one by ID
    @GetMapping("/{id}")
    public ResponseEntity<ProductDTO> getProductById(@PathVariable Long id) {
        Optional<Product> productOpt = productService.getProductById(id);
        return productOpt.map(product -> ResponseEntity.ok(ProductMapper.toDTO(product)))
                .orElse(ResponseEntity.notFound().build());
    }

    // ✅ Update
    @PutMapping("/{id}")
    public ResponseEntity<ProductDTO> updateProduct(@PathVariable Long id, @RequestBody ProductDTO dto) {
        Optional<Product> existingOpt = productService.getProductById(id);

        if (existingOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Product existing = existingOpt.get();
        existing.setName(dto.getName());
        existing.setCategory(dto.getCategory());
        existing.setBrand(dto.getBrand());
        existing.setModel(dto.getModel());
        existing.setDetails(dto.getDetails());
        existing.setQuantity(dto.getQuantity());
        existing.setPrice(dto.getPrice());

        Product updated = productService.saveProduct(existing);
        return ResponseEntity.ok(ProductMapper.toDTO(updated));
    }

    // ✅ Delete
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteProduct(@PathVariable Long id) {
        if (productService.getProductById(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        productService.deleteProduct(id);
        return ResponseEntity.ok().build();
    }
}
