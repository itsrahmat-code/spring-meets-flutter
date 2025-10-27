package com.rahmatullahsaruk.stock_management.service;

import com.rahmatullahsaruk.stock_management.dto.MonthlyProfitDTO;
import com.rahmatullahsaruk.stock_management.dto.YearProfitSummaryDTO;
import com.rahmatullahsaruk.stock_management.repository.ExpenseRepo;
import com.rahmatullahsaruk.stock_management.repository.InvoiceRepo;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class ProfitService {

    private final InvoiceRepo invoiceRepo;
    private final ExpenseRepo expenseRepo;

    public ProfitService(InvoiceRepo invoiceRepo, ExpenseRepo expenseRepo) {
        this.invoiceRepo = invoiceRepo;
        this.expenseRepo = expenseRepo;
    }

    private static LocalDateTime startOfYear(int year) {
        return LocalDate.of(year, 1, 1).atStartOfDay();
    }

    private static LocalDateTime endOfYear(int year) {
        return LocalDate.of(year, 12, 31).atTime(23, 59, 59);
    }

    public List<MonthlyProfitDTO> getMonthlyProfit(int year) {
        LocalDateTime start = startOfYear(year);
        LocalDateTime end   = endOfYear(year);

        Map<Integer, Double> revenueByMonth = new HashMap<>();
        for (Object[] row : invoiceRepo.sumByMonthBetween(start, end)) {
            int m = ((Number) row[0]).intValue();
            double sum = ((Number) row[1]).doubleValue();
            revenueByMonth.put(m, sum);
        }

        Map<Integer, Double> expenseByMonth = new HashMap<>();
        for (Object[] row : expenseRepo.sumByMonthBetween(start, end)) {
            int m = ((Number) row[0]).intValue();
            double sum = ((Number) row[1]).doubleValue();
            expenseByMonth.put(m, sum);
        }

        List<MonthlyProfitDTO> out = new ArrayList<>(12);
        for (int m = 1; m <= 12; m++) {
            double rev = revenueByMonth.getOrDefault(m, 0.0);
            double exp = expenseByMonth.getOrDefault(m, 0.0);
            out.add(new MonthlyProfitDTO(m, rev, exp, rev - exp));
        }
        return out;
    }

    public YearProfitSummaryDTO getYearSummary(int year) {
        LocalDateTime start = startOfYear(year);
        LocalDateTime end   = endOfYear(year);

        double revenue  = Optional.ofNullable(invoiceRepo.getSalesBetween(start, end)).orElse(0.0);
        double expenses = Optional.ofNullable(expenseRepo.getExpensesBetween(start, end)).orElse(0.0);

        return new YearProfitSummaryDTO(year, revenue, expenses, revenue - expenses);
    }
}
