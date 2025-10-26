package com.rahmatullahsaruk.stock_management.repository;

import com.rahmatullahsaruk.stock_management.entity.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface InvoiceRepo extends JpaRepository<Invoice, Long> {


    List<Invoice> findByDateBetween(LocalDateTime start, LocalDateTime end);





    @Query("SELECT COALESCE(SUM(i.total), 0) FROM Invoice i WHERE i.date BETWEEN :start AND :end")
    Double getSalesBetween(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);





}
