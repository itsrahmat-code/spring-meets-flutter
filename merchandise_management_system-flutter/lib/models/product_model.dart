enum Category { Laptop, Accessory }

extension CategoryExt on Category {
  String get name => toString().split('.').last;
}

Category categoryFromString(String s) {
  return Category.values.firstWhere(
        (e) => e.name.toLowerCase() == s.toLowerCase(),
    orElse: () => Category.Laptop,
  );
}

class Product {
  final int? id;
  final String name;
  final Category category;
  final String brand;
  final String? model;
  final String? details;
  final int quantity; // backend stock (immutable)
  final double price;

  const Product({
    this.id,
    required this.name,
    required this.category,
    required this.brand,
    this.model,
    this.details,
    required this.quantity,
    required this.price,
  });

  double get totalPrice => price * quantity;

  Product copyWith({
    int? id,
    String? name,
    Category? category,
    String? brand,
    String? model,
    String? details,
    int? quantity,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      details: details ?? this.details,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      category: categoryFromString(json['category'] as String),
      brand: json['brand'] as String,
      model: json['model'] as String?,
      details: json['details'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category.name,
      'brand': brand,
      'model': model,
      'details': details,
      'quantity': quantity,
      'price': price,
    };
  }
}
