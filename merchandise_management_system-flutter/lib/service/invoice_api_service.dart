// File: lib/service/invoice_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../entity/product.dart'; // Ensure this path is correct

class InvoiceApiService {
  final String baseUrl = 'http://YOUR_API_BASE_URL/api/invoices'; // ⚠️ IMPORTANT: REPLACE THIS with your actual Spring Boot URL!

  Future<int?> createInvoice({
    required String customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAddress,
    // ⬇️ ADDED FINANCIAL FIELDS to match the Invoice entity
    required double subtotal,
    required double discount,
    required double taxRate,
    required double taxAmount,
    required double total,
    required double paid,
    required List<Product> products,
  }) async {
    final url = Uri.parse(baseUrl);

    // Construct the payload matching the Java InvoiceController's expected DTO
    List<Map<String, dynamic>> productPayload = products.map((p) => {
      // The backend needs the ID and the quantity for sale
      "id": p.id,
      "quantity": p.quantity,
    }).toList();

    final payload = {
      "customerName": customerName,
      "customerEmail": customerEmail,
      "customerPhone": customerPhone,
      "customerAddress": customerAddress,
      // ⬇️ ADDED FINANCIAL FIELDS to the payload
      "subtotal": subtotal,
      "discount": discount,
      "taxRate": taxRate,
      "taxAmount": taxAmount,
      "total": total,
      "paid": paid,
      "products": productPayload,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        // Assuming the backend returns the created Invoice object, including its ID
        final jsonResponse = jsonDecode(response.body);
        // Assuming the ID is a Long in Java, it will be an int in Dart's JSON response
        return jsonResponse['id'] as int?;
      } else {
        // Log or print the response body for debugging failed requests
        print('Invoice creation failed. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to create invoice. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      // Log or print the network error
      print('Network or server error: $e');
      throw Exception('Network or server error: $e');
    }
  }
}