// File: lib/service/cart_service.dart
import 'package:flutter/foundation.dart';
import '../entity/product.dart';

class CartService extends ChangeNotifier {
  // Singleton pattern
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  // Internal storage for cart items (Product ID -> Product instance with sale quantity)
  final Map<int, Product> _items = {};

  List<Product> get items => _items.values.toList();

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => _items.isEmpty;

  // Add a product to the cart or update its quantity
  void addItem(Product product, {int quantity = 1}) {
    final productId = product.id;
    if (productId == null) return; // Cannot add product without ID

    if (_items.containsKey(productId)) {
      // Product exists, update quantity
      final existingItem = _items[productId]!;
      _items[productId] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // New product
      _items[productId] = product.copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  // Remove a product entirely
  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Update quantity of an existing item
  void updateQuantity(int productId, int newQuantity) {
    if (_items.containsKey(productId) && newQuantity > 0) {
      final existingItem = _items[productId]!;
      _items[productId] = existingItem.copyWith(quantity: newQuantity);
    } else if (newQuantity <= 0) {
      removeItem(productId);
    }
    notifyListeners();
  }

  // Clear the cart after a successful sale
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}