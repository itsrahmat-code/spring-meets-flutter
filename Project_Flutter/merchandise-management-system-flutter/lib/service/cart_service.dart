import 'package:flutter/foundation.dart';
import 'package:merchandise_management_system/models/cart_line.dart';
import 'package:merchandise_management_system/models/product_model.dart';

class CartService extends ChangeNotifier {
  // id -> CartLine (quantity reserved in cart)
  final Map<int, CartLine> _items = {};

  List<CartLine> get items => _items.values.toList();
  int get totalItems => _items.values.fold(0, (a, b) => a + b.quantity);
  double get totalAmount => _items.values.fold(0.0, (a, b) => a + b.lineTotal);

  int reservedQty(Product p) => (p.id == null) ? 0 : (_items[p.id!]?.quantity ?? 0);

  int availableStock(Product p) {
    final avail = p.quantity - reservedQty(p);
    return avail < 0 ? 0 : avail;
    // This avoids mutating Product.quantity (immutable).
  }

  bool canAdd(Product p) => availableStock(p) > 0;

  void add(Product p) {
    if (p.id == null) return;
    if (!canAdd(p)) return;
    final id = p.id!;
    final line = _items[id];
    if (line == null) {
      _items[id] = CartLine(product: p, quantity: 1);
    } else {
      line.quantity += 1;
    }
    notifyListeners();
  }

  void decrement(Product p) {
    if (p.id == null) return;
    final id = p.id!;
    final line = _items[id];
    if (line == null) return;

    line.quantity -= 1;
    if (line.quantity <= 0) {
      _items.remove(id);
    }
    notifyListeners();
  }

  void deleteItem(Product p) {
    if (p.id == null) return;
    _items.remove(p.id!);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
