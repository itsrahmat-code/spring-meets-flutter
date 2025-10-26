package com.rahmatullahsaruk.stock_management.dto;


public class SalesSummaryDTO {


    private Double today;
    private Double last7Days;
    private Double last30Days;

    public SalesSummaryDTO(Double today, Double last7Days, Double last30Days) {
        this.today = today;
        this.last7Days = last7Days;
        this.last30Days = last30Days;
    }

    public Double getToday() { return today; }
    public void setToday(Double today) { this.today = today; }

    public Double getLast7Days() { return last7Days; }
    public void setLast7Days(Double last7Days) { this.last7Days = last7Days; }

    public Double getLast30Days() { return last30Days; }
    public void setLast30Days(Double last30Days) { this.last30Days = last30Days; }


}