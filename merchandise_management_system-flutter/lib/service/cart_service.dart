// lib/service/cart_service.dart

import 'package:flutter/foundation.dart';

import '../entity/product.dart';


class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final Map<int, Product> _items = {};

  List<Product> get items => _items.values.toList();

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => _items.isEmpty;

  void addItem(Product product, {int quantity = 1}) {
    final id = product.id;
    if (id == null) return;

    final existing = _items[id];
    final currentCartQty = existing?.quantity ?? 0;

    final maxStock = product.quantity; // Available in warehouse/inventory

    final newQuantity = currentCartQty + quantity;

    if (newQuantity > maxStock) {
      // Optional: show warning (currently just stops)
      return;
    }

    _items[id] = product.copyWith(quantity: newQuantity);
    notifyListeners();
  }


  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int newQuantity) {
    if (!_items.containsKey(productId)) return;

    final existing = _items[productId]!;
    if (newQuantity <= 0) {
      removeItem(productId);
    } else {
      _items[productId] = existing.copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
