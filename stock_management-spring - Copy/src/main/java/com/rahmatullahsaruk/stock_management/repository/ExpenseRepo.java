package com.rahmatullahsaruk.stock_management.repository;

import com.rahmatullahsaruk.stock_management.entity.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;

@Repository
public interface ExpenseRepo extends JpaRepository<Expense, Long> {

    @Query("""
      SELECT EXTRACT(MONTH FROM i.date) AS m, COALESCE(SUM(i.total), 0)
      FROM Invoice i
      WHERE i.date BETWEEN :start AND :end
      GROUP BY EXTRACT(MONTH FROM i.date)
      ORDER BY m
      """)
    List<Object[]> sumByMonthBetween(LocalDate start, LocalDate end);

    @Query("""
      SELECT COALESCE(SUM(i.total), 0)
      FROM Invoice i
      WHERE i.date BETWEEN :start AND :end
      """)
    Double sumTotalBetween(LocalDate start, LocalDate end);
}

