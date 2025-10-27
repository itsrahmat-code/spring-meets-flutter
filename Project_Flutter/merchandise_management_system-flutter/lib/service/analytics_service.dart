// lib/service/analytics_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merchandise_management_system/models/profit_model.dart';

class AnalyticsService {
  static const String _base = 'http://localhost:8085';
  final String baseUrl;


  AnalyticsService({required this.baseUrl});

  Future<List<MonthlyProfit>> getMonthlyProfit(int year) async {
    final uri = Uri.parse('$baseUrl/profit/monthly?year=$year');
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Failed: ${res.body}');
    final List list = jsonDecode(res.body);
    return list.map((e) => MonthlyProfit.fromJson(e)).toList();
  }

  Future<YearProfitSummary> getYearSummary(int year) async {
    final uri = Uri.parse('$baseUrl/profit/summary?year=$year');
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Failed: ${res.body}');
    return YearProfitSummary.fromJson(jsonDecode(res.body));
  }
}
