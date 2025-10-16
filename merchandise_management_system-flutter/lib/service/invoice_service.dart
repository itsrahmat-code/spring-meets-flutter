// invoice_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../entity/invoice.dart';


class InvoiceService {
  final String baseUrl = 'http://localhost:8080/api/invoice';

  Future<List<Invoice>> fetchAllInvoices() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Invoice.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load invoices');
    }
  }

  Future<Invoice> createInvoice(Invoice invoice) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(invoice.toJson()),
    );

    if (response.statusCode == 200) {
      return Invoice.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create invoice');
    }
  }

  Future<Invoice> getInvoiceById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Invoice.fromJson(json.decode(response.body));
    } else {
      throw Exception('Invoice not found');
    }
  }

  Future<void> deleteInvoice(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete invoice');
    }
  }

  Future<Invoice> updateInvoice(int id, Invoice invoice) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(invoice.toJson()),
    );
    if (response.statusCode == 200) {
      return Invoice.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update invoice');
    }
  }
}
