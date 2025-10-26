package com.rahmatullahsaruk.stock_management.dto;

public class MonthlyProfitDTO {

    private int month;       // 1..12
    private double revenue;
    private double expenses;
    private double profit;

    public MonthlyProfitDTO() {}

    public MonthlyProfitDTO(int month, double revenue, double expenses, double profit) {
        this.month = month;
        this.revenue = revenue;
        this.expenses = expenses;
        this.profit = profit;
    }

    public int getMonth() {
        return month;
    }

    public double getRevenue() {
        return revenue;
    }

    public double getExpenses() {
        return expenses;
    }

    public double getProfit() {
        return profit;
    }

    public void setMonth(int month) {
        this.month = month;
    }

    public void setRevenue(double revenue) {
        this.revenue = revenue;
    }

    public void setExpenses(double expenses) {
        this.expenses = expenses;
    }

    public void setProfit(double profit) {
        this.profit = profit;
    }
}
