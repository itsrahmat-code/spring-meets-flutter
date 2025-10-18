package com.rahmatullahsaruk.stock_management.repository;

import com.rahmatullahsaruk.stock_management.entity.Cashier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

    @Repository
    public interface CashierRepo extends JpaRepository<Cashier, Long> {


        Optional<Cashier> findByUserId(int userId);

        Optional<Cashier> findByEmail(String email);

    }

