// lib/models/invoice_model.dart

import 'package:merchandise_management_system/entity/product.dart';

class InvoiceProductItem {
  final int productId;
  final int quantity;

  InvoiceProductItem({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': productId, // ✅ Matches backend JSON expectation
      'quantity': quantity,
    };
  }
}

class Invoice {
  final int? id;
  final String? invoiceNumber;
  final DateTime? date;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? customerAddress;

  final double subtotal;
  final double discount;
  final double taxRate;
  final double taxAmount;
  final double total;
  final double paid;

  final double due;
  final List<Product> products;

  Invoice({
    this.id,
    this.invoiceNumber,
    this.date,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.customerAddress,
    this.subtotal = 0.0,
    this.discount = 0.0,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    this.total = 0.0,
    this.paid = 0.0,
    required this.products,
  }) : due = total - paid;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    var productsList = (json['products'] as List?)
        ?.map((e) => Product.fromJson(e))
        .toList() ??
        <Product>[];

    DateTime? parsedDate;
    if (json['date'] != null) {
      try {
        parsedDate = DateTime.parse(json['date']);
      } catch (e) {
        print('Failed to parse date: ${json['date']}');
      }
    }

    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      date: parsedDate,
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      customerAddress: json['customerAddress'],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      paid: (json['paid'] as num?)?.toDouble() ?? 0.0,
      products: productsList,
    );
  }
}
