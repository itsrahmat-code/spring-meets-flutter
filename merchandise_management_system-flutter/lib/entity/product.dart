// File: lib/models/product_model.dart

import 'Category.dart';

// ⚠️ Note: If you are using this file, ensure your CartService and ProductDetailPage
// are updated to import from '../models/product_model.dart' instead of '../entity/product.dart'.

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

  // Utility method from ProductDTO
  double get totalPrice => price * quantity;

  // Factory constructor for creating a new Product object from a JSON map (for reading from API)
  factory Product.fromJson(Map<String, dynamic> json) {
    // ⚠️ IMPORTANT: These utility methods (stringToCategory) must be defined in 'Category.dart' or elsewhere.
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      // Assuming stringToCategory can handle null or missing values gracefully
      category: stringToCategory(json['category']),
      brand: json['brand'] ?? '',
      model: json['model'],
      details: json['details'],
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      invoiceId: json['invoiceId'],
    );
  }

  // Method for converting a ProductModel object to a JSON map (for writing to API)
  Map<String, dynamic> toJson() {
    // ⚠️ IMPORTANT: These utility methods (categoryToString) must be defined in 'Category.dart' or elsewhere.
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

  // ⭐️ CRITICAL FIX: The copyWith method required by CartService
  Product copyWith({
    int? id,
    String? name,
    String? brand,
    Category? category,
    String? model,
    String? details,
    double? price,
    int? quantity,
    int? invoiceId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      model: model ?? this.model,
      details: details ?? this.details,
      price: price ?? this.price,
      // This is the field CartService specifically needs to update:
      quantity: quantity ?? this.quantity,
      invoiceId: invoiceId ?? this.invoiceId,
    );
  }
}
