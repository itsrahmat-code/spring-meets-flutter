import 'package:flutter/foundation.dart';
import 'package:merchandise_management_system/models/product_model.dart';

/// Central place to compute & expose stock alerts.
/// You can make thresholds come from backend later (minThreshold/maxCapacity).
class StockAlertService extends ChangeNotifier {
  /// Global fallback thresholds (override per product if backend provides).
  final int defaultLowThreshold;
  final int defaultMaxCapacity;

  StockAlertService({
    this.defaultLowThreshold = 5,
    this.defaultMaxCapacity = 100,
  });

  final List<Product> _all = [];
  List<Product> get all => List.unmodifiable(_all);

  /// Derived lists
  List<Product> get lowStock =>
      _all.where((p) => p.quantity <= _lowThresholdFor(p)).toList();

  List<Product> get fullStock =>
      _all.where((p) => p.quantity >= _maxCapacityFor(p)).toList();

  bool get hasLow => lowStock.isNotEmpty;
  bool get hasFull => fullStock.isNotEmpty;

  /// Update from latest fetch (ProductListPage, Manager dashboard, etc.)
  void setProducts(List<Product> products) {
    _all
      ..clear()
      ..addAll(products);
    notifyListeners();
  }

  /// Helpers — if your backend later sends minThreshold / maxCapacity in JSON,
  /// add nullable fields to Product and read them here instead of defaults.
  int _lowThresholdFor(Product p) {
    // e.g. return p.minThreshold ?? defaultLowThreshold;
    return defaultLowThreshold;
  }

  int _maxCapacityFor(Product p) {
    // e.g. return p.maxCapacity ?? defaultMaxCapacity;
    return defaultMaxCapacity;
  }

  /// Convenience checks for UI
  bool isLow(Product p) => p.quantity <= _lowThresholdFor(p);
  bool isFull(Product p) => p.quantity >= _maxCapacityFor(p);
}
