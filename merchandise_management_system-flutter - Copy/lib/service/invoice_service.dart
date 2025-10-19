// File: lib/service/invoice_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../entity/invoice.dart';
import '../entity/product.dart'; // Ensure you have this import

class InvoiceService {
  final String baseUrl = "http://localhost:8085/api/invoices"; // Adjust URL to your backend

  // --- CREATE ---
  Future<InvoiceModel> createInvoice(
      String customerName,
      String? customerEmail,
      String? customerPhone,
      String? customerAddress,
      double discount,
      double paid,
      List<InvoiceProductItem> items) async {

    // Format the products list for the backend (using ProductDTO which needs ID and quantity)
    List<Map<String, dynamic>> productsJson = items.map((item) => item.toJson()).toList();

    final body = jsonEncode({
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'discount': discount,
      'paid': paid,
      'products': productsJson,
    });

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return InvoiceModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create invoice. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // --- READ ALL ---
  Future<List<InvoiceModel>> getAllInvoices() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => InvoiceModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load invoices. Status: ${response.statusCode}');
    }
  }

  // --- READ BY ID ---
  Future<InvoiceModel> getInvoiceById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return InvoiceModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load invoice $id. Status: ${response.statusCode}');
    }
  }

  // --- DELETE ---
  Future<void> deleteInvoice(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete invoice $id. Status: ${response.statusCode}');
    }
  }
}