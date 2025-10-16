// File: lib/models/dashboard_model.dart

class DashboardModel {
  final Map<String, int> productsByCategory;
  final double totalSales;
  final double totalProfit;
  final double totalExpense;

  DashboardModel({
    required this.productsByCategory,
    required this.totalSales,
    required this.totalProfit,
    required this.totalExpense,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      // Assuming categories come as a Map<String, int> from the backend
      productsByCategory: Map<String, int>.from(json['productsByCategory'] ?? {}),
      totalSales: json['totalSales']?.toDouble() ?? 0.0,
      totalProfit: json['totalProfit']?.toDouble() ?? 0.0,
      totalExpense: json['totalExpense']?.toDouble() ?? 0.0,
    );
  }
}