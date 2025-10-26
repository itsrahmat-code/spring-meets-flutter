import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merchandise_management_system/models/expense_model.dart';

class ExpenseService {
  // Default base for local backend
  static const String _base = 'http://localhost:8085';

  final String baseUrl;

  /// Make baseUrl OPTIONAL so callers can just do `ExpenseService()`.
  /// You can still override it: ExpenseService(baseUrl: 'http://10.0.2.2:8085')
  ExpenseService({String? baseUrl}) : baseUrl = baseUrl ?? _base;

  String get _resource => '$baseUrl/api/expenses';

  Map<String, String> get _headers => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<Expense>> getAll() async {
    final res = await http.get(Uri.parse(_resource), headers: _headers);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch expenses: ${res.statusCode}');
  }

  Future<Expense?> getById(int id) async {
    final res = await http.get(Uri.parse('$_resource/$id'), headers: _headers);
    if (res.statusCode == 200) {
      return Expense.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 404) {
      return null;
    }
    throw Exception('Failed to fetch expense $id: ${res.statusCode}');
  }

  Future<Expense> create(Expense expense) async {
    final res = await http.post(
      Uri.parse(_resource),
      headers: _headers,
      body: jsonEncode(expense.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Expense.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create expense: ${res.statusCode}\n${res.body}');
  }

  Future<Expense?> update(int id, Expense expense) async {
    final res = await http.put(
      Uri.parse('$_resource/$id'),
      headers: _headers,
      body: jsonEncode(expense.toJson()),
    );
    if (res.statusCode == 200) {
      return Expense.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 404) {
      return null;
    }
    throw Exception('Failed to update expense $id: ${res.statusCode}\n${res.body}');
  }

  Future<bool> delete(int id) async {
    final res = await http.delete(Uri.parse('$_resource/$id'), headers: _headers);
    if (res.statusCode == 204 || res.statusCode == 200) return true;
    if (res.statusCode == 404) return false;
    throw Exception('Failed to delete expense $id: ${res.statusCode}');
  }
}
