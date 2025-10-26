// Matches your Spring Boot InvoiceDTO & InvoiceItemDTO shapes

class InvoiceItem {
  final int? productId;
  final String productName;
  final int quantity;
  final double priceAtSale;

  const InvoiceItem({
    this.productId,
    required this.productName,
    required this.quantity,
    required this.priceAtSale,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    productId: (json['productId'] as num?)?.toInt(),
    productName: json['productName'] as String,
    quantity: (json['quantity'] as num).toInt(),
    priceAtSale: (json['priceAtSale'] as num).toDouble(),
  );
}

class Invoice {
  final int? id;
  final DateTime? date;
  final String invoiceNumber;
  final String name; // customer name
  final String? email;
  final String? phone;
  final double subtotal;
  final double discount;
  final double total;
  final double paid;
  final List<InvoiceItem> items;

  const Invoice({
    this.id,
    this.date,
    required this.invoiceNumber,
    required this.name,
    this.email,
    this.phone,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paid,
    required this.items,
  });

  double get due => (total - paid);
  bool get isPaid => paid >= total;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>? ?? []);
    return Invoice(
      id: (json['id'] as num?)?.toInt(),
      date: json['date'] == null ? null : DateTime.tryParse(json['date'] as String),
      invoiceNumber: (json['invoiceNumber'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      paid: (json['paid'] as num).toDouble(),
      items: itemsJson.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
