import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merchandise_management_system/models/supplier_model.dart';

class SupplierApiService {
  // Change to your backend base URL
  static const String _baseUrl = 'http://localhost:8085/api/suppliers';

  final http.Client _client;
  SupplierApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Supplier>> fetchSuppliers() async {
    final res = await _client.get(Uri.parse(_baseUrl));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body) as List;
      return data.map((e) => Supplier.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load suppliers: ${res.statusCode} ${res.body}');
  }

  Future<Supplier> createSupplier(Supplier supplier) async {
    final res = await _client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(supplier.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Supplier.fromJson(json.decode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create supplier: ${res.statusCode} ${res.body}');
  }

  Future<void> deleteSupplier(int id) async {
    final res = await _client.delete(Uri.parse('$_baseUrl/$id'));
    if (res.statusCode != 204) {
      throw Exception('Delete failed: ${res.statusCode} ${res.body}');
    }
  }
}
