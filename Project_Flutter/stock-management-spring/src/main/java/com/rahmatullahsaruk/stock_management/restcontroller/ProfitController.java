package com.rahmatullahsaruk.stock_management.restcontroller;

import com.rahmatullahsaruk.stock_management.dto.MonthlyProfitDTO;
import com.rahmatullahsaruk.stock_management.dto.YearProfitSummaryDTO;
import com.rahmatullahsaruk.stock_management.service.ProfitService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/analytics")
@CrossOrigin // allow Flutter dev host/ports during dev
public class ProfitController {

    private final ProfitService profitService;

    public ProfitController(ProfitService profitService) {
        this.profitService = profitService;
    }

    @GetMapping("/profit/monthly")
    public List<MonthlyProfitDTO> monthly(@RequestParam int year) {
        return profitService.getMonthlyProfit(year);
    }

    @GetMapping("/profit/summary")
    public YearProfitSummaryDTO summary(@RequestParam int year) {
        return profitService.getYearSummary(year);
    }
}
