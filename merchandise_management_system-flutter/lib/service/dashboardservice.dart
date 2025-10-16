// File: lib/service/dashboard_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../entity/dashboard.dart';


class DashboardService {
  final String baseUrl = 'http://10.0.2.2:8085/api/dashboard'; // Adjust URL

  Future<DashboardModel> getDashboardData() async {
    // This is a placeholder for actual API call
    // final response = await http.get(Uri.parse('$baseUrl/manager'));

    // if (response.statusCode == 200) {
    //   return DashboardModel.fromJson(jsonDecode(response.body));
    // } else {
    //   throw Exception('Failed to load dashboard data');
    // }

    // --- MOCK DATA FOR TESTING ---
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    return DashboardModel(
      productsByCategory: {
        'Laptop': 45,
        'Accessory': 150,
        'Monitor': 25,
      },
      totalSales: 15500.75,
      totalProfit: 4200.50,
      totalExpense: 11300.25,
    );
    // --- END MOCK DATA ---
  }
}