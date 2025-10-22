import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merchandise_management_system/models/cart_line.dart';

class InvoiceService {
  // For Android Emulator use: 'http://10.0.2.2:8085'
  static const String _base = 'http://localhost:8085';
  final _client = http.Client();

  Future<Map<String, dynamic>> createInvoice({
    required String name,
    String? email,
    String? phone,
    required double discount,
    required double paid,
    required List<CartLine> items,
  }) async {
    final body = {
      "name": name,
      "email": email,
      "phone": phone,
      "discount": discount,
      "paid": paid,
      "items": items.map((e) => e.toInvoiceItemJson()).toList(),
    };

    final res = await _client.post(
      Uri.parse('$_base/api/invoices'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Invoice create failed (${res.statusCode}): ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
