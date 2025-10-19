// File: lib/service/invoice_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merchandise_management_system/entity/invoice.dart';



class InvoiceService {
  // Replace with your actual base URL
  static const String _baseUrl = 'http://localhost:8085/api/invoices';
  // Note: 10.0.2.2 is often used for Android Emulator to connect to a local host.

  // Fetch all invoices
  Future<List<Invoice>> getAllInvoices() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      // Decode the JSON list response
      List<dynamic> body = json.decode(response.body);
      // Map the decoded list to a List<Invoice>
      return body.map((dynamic item) => Invoice.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load invoices. Status code: ${response.statusCode}');
    }
  }

  // Fetch a single invoice by ID
  Future<Invoice> getInvoiceById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return Invoice.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load invoice $id. Status code: ${response.statusCode}');
    }
  }

  // Create a new invoice
  Future<Invoice> createInvoice(Invoice invoice) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(invoice.toJson()),
    );

    if (response.statusCode == 200) {
      // API returns 200 on success, as seen in your controller: ResponseEntity.ok(InvoiceMapper.toDTO(saved))
      return Invoice.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create invoice. Status code: ${response.statusCode}');
    }
  }
}