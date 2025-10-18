package com.rahmatullahsaruk.stock_management.repository;

import com.rahmatullahsaruk.stock_management.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;

    public interface ProductRepo extends JpaRepository<Product, Long> {
    }


