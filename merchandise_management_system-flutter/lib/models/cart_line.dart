import 'product_model.dart';

class CartLine {
  final Product product;
  int quantity;

  CartLine({required this.product, this.quantity = 1});

  double get lineTotal => product.price * quantity;

  Map<String, dynamic> toInvoiceItemJson() => {
    "product": {"id": product.id},
    "quantity": quantity,
    "priceAtSale": product.price,
  };
}
