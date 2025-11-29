package com.rahmatullahsaruk.stock_management.dto;

public class YearProfitSummaryDTO {

    private int year;
    private double revenue;
    private double expenses;
    private double profit;

    public YearProfitSummaryDTO() {}

    public YearProfitSummaryDTO(int year, double revenue, double expenses, double profit) {
        this.year = year;
        this.revenue = revenue;
        this.expenses = expenses;
        this.profit = profit;
    }

    public int getYear() {
        return year;
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

    public void setYear(int year) {
        this.year = year;
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
