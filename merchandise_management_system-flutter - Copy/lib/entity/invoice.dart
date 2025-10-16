// invoice_model.dart

class Product {
  final int id;
  final String? name;
  final String? category;
  final String? brand;
  final String? model;
  final String? details;
  int quantity;
  double price;

  Product({
    required this.id,
    this.name,
    this.category,
    this.brand,
    this.model,
    this.details,
    required this.quantity,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    brand: json['brand'],
    model: json['model'],
    details: json['details'],
    quantity: json['quantity'],
    price: (json['price'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'quantity': quantity,
    // Optional fields can be included if needed
  };
}

class Invoice {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  double discount;
  double paid;
  double subtotal;
  double taxRate;
  double taxAmount;
  double total;
  double due;
  String? invoiceNumber;
  DateTime? date;
  List<Product> products;

  Invoice({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    required this.discount,
    required this.paid,
    required this.products,
    this.subtotal = 0,
    this.taxRate = 5,
    this.taxAmount = 0,
    this.total = 0,
    this.due = 0,
    this.invoiceNumber,
    this.date,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    address: json['address'],
    discount: (json['discount'] as num).toDouble(),
    paid: (json['paid'] as num).toDouble(),
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0,
    taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
    total: (json['total'] as num?)?.toDouble() ?? 0,
    due: (json['due'] as num?)?.toDouble() ?? 0,
    invoiceNumber: json['invoiceNumber'],
    date: DateTime.tryParse(json['date'] ?? ''),
    products: (json['products'] as List<dynamic>)
        .map((p) => Product.fromJson(p))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'discount': discount,
    'paid': paid,
    'products': products.map((p) => p.toJson()).toList(),
  };
}
