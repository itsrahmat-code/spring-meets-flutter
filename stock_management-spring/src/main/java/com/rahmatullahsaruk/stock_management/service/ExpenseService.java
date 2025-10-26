package com.rahmatullahsaruk.stock_management.service;

import com.rahmatullahsaruk.stock_management.entity.Expense;
import com.rahmatullahsaruk.stock_management.repository.ExpenseRepo;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class ExpenseService {

    private final ExpenseRepo expenseRepository;

    public ExpenseService(ExpenseRepo expenseRepository) {
        this.expenseRepository = expenseRepository;
    }

    public List<Expense> getAllExpenses() {
        return expenseRepository.findAll();
    }

    public Optional<Expense> getExpenseById(Long id) {
        return expenseRepository.findById(id);
    }

    public Expense saveExpense(Expense expense) {
        if (expense.getId() != null) expense.setId(null);
        return expenseRepository.save(expense);
    }

    public Optional<Expense> updateExpense(Long id, Expense updatedExpense) {
        return expenseRepository.findById(id).map(expense -> {
            expense.setDate(updatedExpense.getDate());
            expense.setTitle(updatedExpense.getTitle());
            expense.setDescription(updatedExpense.getDescription());
            expense.setAmount(updatedExpense.getAmount());
            // If you want to allow changing who added it:
            // expense.setAddedBy(updatedExpense.getAddedBy());
            return expenseRepository.save(expense);
        });
    }

    public void deleteExpense(Long id) {
        expenseRepository.deleteById(id);
    }

    // ---- Aggregations ----

    public Double getTodayExp() {
        LocalDate today = LocalDate.now();
        LocalDateTime start = today.atStartOfDay();
        LocalDateTime end   = today.atTime(23, 59, 59);
        return coalesce(expenseRepository.getExpensesBetween(start, end));
    }

    public Double getLast7DaysExp() {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(6); // inclusive: 7 days total
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end   = endDate.atTime(23, 59, 59);
        return coalesce(expenseRepository.getExpensesBetween(start, end));
    }

    public Double getLast30DaysExp() {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(29); // inclusive: 30 days total
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end   = endDate.atTime(23, 59, 59);
        return coalesce(expenseRepository.getExpensesBetween(start, end));
    }

    private Double coalesce(Double v) {
        return v == null ? 0.0d : v;
    }
}
