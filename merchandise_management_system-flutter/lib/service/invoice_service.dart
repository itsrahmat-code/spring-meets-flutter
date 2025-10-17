import 'dart:convert';
import 'package:http/http.dart' as http;

import '../entity/invoice.dart';
import '../entity/product.dart';

class InvoiceService {
  final String baseUrl = 'http://localhost:8085/api/invoices';

  // --- CREATE ---
  Future<Invoice> createInvoice({
    required String customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAddress,
    required double subtotal,
    required double discount,
    required double taxRate,
    required double taxAmount,
    required double total,
    required double paid,
    required List<InvoiceProductItem> items, // or Product if your list is based on Product
  }) async {
    // Convert product list to JSON (you can change this if using Product model instead)
    List<Map<String, dynamic>> productsJson = items.map((item) => item.toJson()).toList();

    final body = jsonEncode({
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'subtotal': subtotal,
      'discount': discount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'total': total,
      'paid': paid,
      'products': productsJson,
    });

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return Invoice.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create invoice. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // --- READ ALL ---
  Future<List<Invoice>> getAllInvoices() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Invoice.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load invoices. Status: ${response.statusCode}');
    }
  }

  // --- READ BY ID ---
  Future<Invoice> getInvoiceById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Invoice.fromJson(jsonDecode(response.body));
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
