// File: lib/models/invoice_model.dart


// File: lib/models/invoice_model.dart

import '../entity/product.dart'; // Re-use your Product entity for the product snapshot in the invoice

/// Model used to represent a product being SOLD/ADDED to a new invoice.
/// It only requires the product ID and the quantity being sold.
class InvoiceProductItem {
  final int id;         // The actual product ID (for stock deduction on the backend)
  final int quantity;   // The quantity being sold/invoiced

  InvoiceProductItem({
    required this.id,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
    };
  }
}

/// Model representing the full Invoice data received from the API (InvoiceDTO).
class InvoiceModel {
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

  // Calculated client-side for display convenience
  final double due;

  // Products received from the API (a snapshot of sold products)
  final List<Product> products;

  InvoiceModel({
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


  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    // Deserialize products list (using the existing Product model/entity)
    var productsList = json['products'] as List? ?? [];
    List<Product> productsSnapshot = productsList.map((i) => Product.fromJson(i)).toList();

    // Parse Java's LocalDateTime string safely
    DateTime? parsedDate;
    if (json['date'] != null) {
      try {
        parsedDate = DateTime.parse(json['date']);
      } catch (e) {
        // Log the error but proceed with null date
        print('Error parsing date: ${json['date']}');
      }
    }

    // Ensure all numeric values are handled as double
    double subtotal = json['subtotal']?.toDouble() ?? 0.0;
    double discount = json['discount']?.toDouble() ?? 0.0;
    double total = json['total']?.toDouble() ?? 0.0;
    double paid = json['paid']?.toDouble() ?? 0.0;

    return InvoiceModel(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      date: parsedDate,
      customerName: json['customerName'] ?? 'N/A',
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      customerAddress: json['customerAddress'],
      subtotal: subtotal,
      discount: discount,
      taxRate: json['taxRate']?.toDouble() ?? 0.0,
      taxAmount: json['taxAmount']?.toDouble() ?? 0.0,
      total: total,
      paid: paid,
      products: productsSnapshot,
    );
  }
}