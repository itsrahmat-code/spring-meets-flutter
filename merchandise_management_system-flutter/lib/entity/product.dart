

class Product {
  final int id;
  final String name;
  final String category;  // or an enum
  final String brand;
  final String? model;
  final String? details;
  final int quantity;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    this.model,
    this.details,
    required this.quantity,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String?,
      details: json['details'] as String?,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'brand': brand,
      'model': model,
      'details': details,
      'quantity': quantity,
      'price': price,
    };
  }
}
