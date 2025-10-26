import 'package:flutter/foundation.dart';
import 'package:merchandise_management_system/models/product_model.dart';

class StockAlertService extends ChangeNotifier {
  final int defaultLowThreshold;
  final int defaultMaxCapacity;

  StockAlertService({
    this.defaultLowThreshold = 5,
    this.defaultMaxCapacity = 100,
  });

  final List<Product> _all = [];
  List<Product> get all => List.unmodifiable(_all);

  List<Product> get lowStock =>
      _all.where((p) => p.quantity <= _lowThresholdFor(p)).toList();

  List<Product> get fullStock =>
      _all.where((p) => p.quantity >= _maxCapacityFor(p)).toList();

  bool get hasLow => lowStock.isNotEmpty;
  bool get hasFull => fullStock.isNotEmpty;

  void setProducts(List<Product> products) {
    _all
      ..clear()
      ..addAll(products);
    notifyListeners();
  }

  // ✅ Add this now (no-op for the moment). Later you can fetch fresh products here.
  Future<void> refresh() async {
    // TODO: plug ProductService here and call setProducts(fetched)
    notifyListeners(); // at least triggers UI rebuild for now
  }

  int _lowThresholdFor(Product p) => defaultLowThreshold;
  int _maxCapacityFor(Product p) => defaultMaxCapacity;

  bool isLow(Product p) => p.quantity <= _lowThresholdFor(p);
  bool isFull(Product p) => p.quantity >= _maxCapacityFor(p);
}
