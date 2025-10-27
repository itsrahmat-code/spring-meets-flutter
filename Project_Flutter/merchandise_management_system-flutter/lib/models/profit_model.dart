// lib/models/profit_models.dart
class MonthlyProfit {
  final int month; // 1..12
  final double revenue;
  final double expenses;
  final double profit;

  MonthlyProfit({required this.month, required this.revenue, required this.expenses, required this.profit});

  factory MonthlyProfit.fromJson(Map<String, dynamic> j) => MonthlyProfit(
    month: (j['month'] as num).toInt(),
    revenue: (j['revenue'] as num).toDouble(),
    expenses: (j['expenses'] as num).toDouble(),
    profit: (j['profit'] as num).toDouble(),
  );
}

class YearProfitSummary {
  final int year;
  final double revenue;
  final double expenses;
  final double profit;

  YearProfitSummary({required this.year, required this.revenue, required this.expenses, required this.profit});

  factory YearProfitSummary.fromJson(Map<String, dynamic> j) => YearProfitSummary(
    year: (j['year'] as num).toInt(),
    revenue: (j['revenue'] as num).toDouble(),
    expenses: (j['expenses'] as num).toDouble(),
    profit: (j['profit'] as num).toDouble(),
  );
}
