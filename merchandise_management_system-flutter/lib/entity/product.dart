// File: lib/models/product_model.dart

 // Assuming you create this file



import 'package:merchandise_management_system/entity/Category.dart';

class Product {
  final int? id;
  final String name;
  final Category category;
  final String brand;
  final String? model;
  final String? details;
  final int quantity;
  final double price;
  final int? invoiceId;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.brand,
    this.model,
    this.details,
    required this.quantity,
    required this.price,
    this.invoiceId,
  });

  // Factory constructor for creating a new ProductModel object from a JSON map (for reading from API)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      // Convert String to Category enum
      category: stringToCategory(json['category']),
      brand: json['brand'],
      model: json['model'],
      details: json['details'],
      quantity: json['quantity'],
      price: json['price'],
      invoiceId: json['invoiceId'],
    );
  }

  // Method for converting a ProductModel object to a JSON map (for writing to API)
  Map<String, dynamic> toJson() {
    return {
      // 'id' is typically omitted for POST requests, but included for PUT
      if (id != null) 'id': id,
      'name': name,
      // Convert Category enum to String
      'category': categoryToString(category),
      'brand': brand,
      'model': model,
      'details': details,
      'quantity': quantity,
      'price': price,
      'invoiceId': invoiceId,
    };
  }

  // Utility method from ProductDTO
  double get totalPrice => price * quantity;
}