package com.rahmatullahsaruk.stock_management.repository;

import com.rahmatullahsaruk.stock_management.entity.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ExpenseRepo extends JpaRepository<Expense, Long> {

    // Monthly sums within a datetime range
    @Query("""
           SELECT MONTH(e.date) AS m, COALESCE(SUM(e.amount), 0)
           FROM Expense e
           WHERE e.date BETWEEN :start AND :end
           GROUP BY MONTH(e.date)
           ORDER BY MONTH(e.date)
           """)
    List<Object[]> sumByMonthBetween(@Param("start") LocalDateTime start,
                                     @Param("end") LocalDateTime end);

    // Total expenses within a datetime range
    @Query("""
           SELECT COALESCE(SUM(e.amount), 0)
           FROM Expense e
           WHERE e.date BETWEEN :start AND :end
           """)
    Double getExpensesBetween(@Param("start") LocalDateTime start,
                              @Param("end") LocalDateTime end);
}
