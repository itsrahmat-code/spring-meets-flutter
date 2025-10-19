import 'package:merchandise_management_system/entity/product.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;

  final Map<Product, int> _cartItems = {};

  CartService._internal();

  Map<Product, int> get cartItems => Map.unmodifiable(_cartItems);

  void addToCart(Product product) {
    if (_cartItems.containsKey(product)) {
      _cartItems[product] = _cartItems[product]! + 1;
    } else {
      _cartItems[product] = 1;
    }

    if (product.quantity > 0) {
      product.quantity -= 1;
    }
  }

  void removeFromCart(Product product) {
    if (_cartItems.containsKey(product)) {
      final currentQty = _cartItems[product]!;
      if (currentQty > 1) {
        _cartItems[product] = currentQty - 1;
        product.quantity += 1;
      } else {
        _cartItems.remove(product);
        product.quantity += 1;
      }
    }
  }

  void deleteItem(Product product) {
    if (_cartItems.containsKey(product)) {
      final qty = _cartItems[product]!;
      product.quantity += qty;
      _cartItems.remove(product);
    }
  }

  void clearCart() {
    for (var entry in _cartItems.entries) {
      entry.key.quantity += entry.value;
    }
    _cartItems.clear();
  }

  /// ✅ Now a getter instead of a method
  int get totalItems => _cartItems.values.fold(0, (sum, qty) => sum + qty);

  /// ✅ Also convert totalPrice to getter
  double get totalPrice {
    double total = 0.0;
    _cartItems.forEach((product, qty) {
      total += product.price * qty;
    });
    return total;
  }
}
