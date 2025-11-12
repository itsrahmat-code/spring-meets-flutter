package com.rahmatullahsaruk.stock_management.repository;

import com.rahmatullahsaruk.stock_management.entity.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SupplierRepo extends JpaRepository<Supplier, Long> {
}
