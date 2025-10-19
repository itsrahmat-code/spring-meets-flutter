// lib/models/invoice.dart



class Invoice {
  final int? id;
  final DateTime? date;
  final String name;
  final String email;
  final String phone;
  final String address;

  final double subtotal;
  final double discount;
  final double taxRate;
  final double taxAmount;
  final double total;
  final double paid;

  final String invoiceNumber;
  final List<Product> products;

  Invoice({
    this.id,
    this.date,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.subtotal,
    required this.discount,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.paid,
    required this.invoiceNumber,
    required this.products,
  });

  // Factory constructor to create an Invoice from JSON (API response)
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      subtotal: json['subtotal']?.toDouble() ?? 0.0,
      discount: json['discount']?.toDouble() ?? 0.0,
      taxRate: json['taxRate']?.toDouble() ?? 0.0,
      taxAmount: json['taxAmount']?.toDouble() ?? 0.0,
      total: json['total']?.toDouble() ?? 0.0,
      paid: json['paid']?.toDouble() ?? 0.0,
      invoiceNumber: json['invoiceNumber'] ?? '',
      // Map the list of product JSON objects to Product models
      products: (json['products'] as List<dynamic>?)
          ?.map((p) => Product.fromJson(p))
          .toList() ??
          [],
    );
  }

  // Method to convert an Invoice object to JSON (for POST/PUT requests)
  Map<String, dynamic> toJson() {
    return {
      // 'id' is often omitted for creation (POST) but included for update (PUT)
      'id': id,
      'date': date?.toIso8601String(),
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      // Note: subtotal, taxAmount, total might be auto-calculated by the API
      // but they are included here for completeness/update.
      'subtotal': subtotal,
      'discount': discount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'total': total,
      'paid': paid,
      'invoiceNumber': invoiceNumber,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}

// You need this Product model too, based on your Product entity.
// For simplicity, a basic structure is provided here:
class Product {
  final int? id;
  final String name;
  final double price;
  final int quantity;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}