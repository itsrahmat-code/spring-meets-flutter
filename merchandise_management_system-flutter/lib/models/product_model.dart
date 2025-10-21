// // lib/models/product.dart
// import 'dart:convert';
//
// enum Category { Laptop, Accessory }
//
// Category categoryFromString(String s) {
//   return Category.values.firstWhere(
//         (e) => e.name.toLowerCase() == s.toLowerCase(),
//     orElse: () => Category.Laptop,
//   );
// }
//
// String categoryToString(Category c) => c.name;
//
// class Product {
//   final int? id;
//   final String name;
//   final Category category;
//   final String brand;
//   final String? model;
//   final String? details;
//   final int quantity;
//   final double price;
//
//   const Product({
//     this.id,
//     required this.name,
//     required this.category,
//     required this.brand,
//     this.model,
//     this.details,
//     required this.quantity,
//     required this.price,
//   });
//
//   double get totalPrice => price * quantity;
//
//   Product copyWith({
//     int? id,
//     String? name,
//     Category? category,
//     String? brand,
//     String? model,
//     String? details,
//     int? quantity,
//     double? price,
//   }) {
//     return Product(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       category: category ?? this.category,
//       brand: brand ?? this.brand,
//       model: model ?? this.model,
//       details: details ?? this.details,
//       quantity: quantity ?? this.quantity,
//       price: price ?? this.price,
//     );
//   }
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: (json['id'] as num?)?.toInt(),
//       name: json['name'] as String,
//       category: categoryFromString(json['category'] as String),
//       brand: json['brand'] as String,
//       model: json['model'] as String?,
//       details: json['details'] as String?,
//       quantity: (json['quantity'] as num).toInt(),
//       price: (json['price'] as num).toDouble(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       if (id != null) 'id': id,
//       'name': name,
//       'category': categoryToString(category),
//       'brand': brand,
//       'model': model,
//       'details': details,
//       'quantity': quantity,
//       'price': price,
//     };
//   }
//
//   @override
//   String toString() => jsonEncode(toJson());
// }


// gimini


// lib/models/product.dart
enum Category {
  Laptop,
  Accessory,
}

// Extension to handle serialization/deserialization of the enum
extension CategoryExtension on Category {
  String toShortString() {
    return toString().split('.').last;
  }
}

class Product {
  final int? id;
  final String name;
  final Category category;
  final String brand;
  final String? model;
  final String? details;
  final int quantity;
  final double price;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.brand,
    this.model,
    this.details,
    required this.quantity,
    required this.price,
  });

  // Factory constructor to create a Product from a JSON map (API response)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String,
      // Convert String back to Category enum
      category: Category.values.firstWhere(
            (e) => e.toShortString() == json['category'],
        orElse: () => Category.Accessory, // Default/fallback category
      ),
      brand: json['brand'] as String,
      model: json['model'] as String?,
      details: json['details'] as String?,
      quantity: json['quantity'] as int,
      price: json['price'] is int // API might return int for price
          ? (json['price'] as int).toDouble()
          : json['price'] as double,
    );
  }

  // Method to convert the Product to a JSON map (for sending to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // Convert Category enum to String
      'category': category.toShortString(),
      'brand': brand,
      'model': model,
      'details': details,
      'quantity': quantity,
      'price': price,
    };
  }

  double get totalPrice => price * quantity;
}