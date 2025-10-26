package com.rahmatullahsaruk.stock_management.service;

import com.rahmatullahsaruk.stock_management.entity.Expense;
import com.rahmatullahsaruk.stock_management.repository.ExpenseRepo;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
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

    // Aggregations (all Double for consistency with entity/repo)
    public Double getTodayExp() {
        LocalDate today = LocalDate.now();
        return coalesce(expenseRepository.sumByDateBetween(today, today));
    }

    public Double getLast7DaysExp() {
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(6); // inclusive range of 7 days
        return coalesce(expenseRepository.sumByDateBetween(start, end));
    }

    public Double getLast30DaysExp() {
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(29); // inclusive range of 30 days
        return coalesce(expenseRepository.sumByDateBetween(start, end));
    }

    private Double coalesce(Double v) {
        return v == null ? 0.0d : v;
    }
}
