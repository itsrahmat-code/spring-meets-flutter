package com.rahmatullahsaruk.stock_management.repository;

import com.rahmatullahsaruk.stock_management.entity.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.stereotype.Repository;

;

    @Repository
    public interface InvoiceRepo extends JpaRepository<Invoice,Long> {

    }

