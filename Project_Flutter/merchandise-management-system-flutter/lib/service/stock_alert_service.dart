import 'package:flutter/foundation.dart';
import 'package:merchandise_management_system/models/product_model.dart';

/// Minimal order-line model so this service compiles out-of-the-box.
/// Replace with your real order line / sales line model if you already have one.
class OrderItem {
  final String productId;
  final int quantity;
  final DateTime createdAt;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.createdAt,
  });
}

class StockAlertService extends ChangeNotifier {
  // ----------------------------
  // Configuration
  // ----------------------------
  final int defaultLowThreshold;
  final int defaultMaxCapacity;

  /// Rolling sales window in days (used by bestSellers/slowMovers).
  /// You can change this at runtime via [setSalesWindowDays].
  int _salesWindowDays;

  StockAlertService({
    this.defaultLowThreshold = 5,
    this.defaultMaxCapacity = 100,
    int salesWindowDays = 30,
  }) : _salesWindowDays = salesWindowDays;

  // ----------------------------
  // Product state
  // ----------------------------
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

  // ----------------------------
  // Sales state
  // ----------------------------

  /// If you want the service to aggregate raw order items for you,
  /// set them here (e.g., last 90 days). The service will filter to the current window.
  final List<OrderItem> _orderItems = [];

  /// Optional, already-aggregated sales counts for the current window.
  /// Key: productId, Value: units sold in the (_salesWindowDays) window.
  Map<String, int> _salesCounts = {};

  /// When the current sales counts were computed. purely informational.
  DateTime? _salesCountsComputedAt;

  /// Set a new rolling window (days) and re-aggregate from [_orderItems] if present.
  void setSalesWindowDays(int days) {
    if (days <= 0) return;
    _salesWindowDays = days;
    // Rebuild counts from _orderItems if we have them
    if (_orderItems.isNotEmpty) {
      _salesCounts = _aggregateFromOrderItems(_orderItems, _salesWindowDays);
      _salesCountsComputedAt = DateTime.now();
    }
    notifyListeners();
  }

  /// Provide raw order items; service will aggregate per product for the current window.
  /// You can pass a superset of dates; the window filter will be applied.
  void setOrderItems(List<OrderItem> items) {
    _orderItems
      ..clear()
      ..addAll(items);
    _salesCounts = _aggregateFromOrderItems(_orderItems, _salesWindowDays);
    _salesCountsComputedAt = DateTime.now();
    notifyListeners();
  }

  /// Provide already-aggregated counts for the window (e.g., from your repo/DB).
  /// If your backend already gives you "units sold (last N days) by product", this is ideal.
  void setSalesCounts(Map<String, int> counts, {int? days}) {
    if (days != null && days > 0 && days != _salesWindowDays) {
      _salesWindowDays = days;
    }
    _salesCounts = Map<String, int>.from(counts);
    _salesCountsComputedAt = DateTime.now();
    notifyListeners();
  }

  // ----------------------------
  // Public API (unchanged + new)
  // ----------------------------

  // ✅ Existing: simple refresh hook
  Future<void> refresh() async {
    // TODO: plug your ProductService/Orders repository here:
    // final fetchedProducts = await productService.fetchProducts();
    // setProducts(fetchedProducts);
    //
    // final recentOrderItems = await ordersRepo.fetchOrderItems(since: DateTime.now().subtract(Duration(days: 90)));
    // setOrderItems(recentOrderItems);
    notifyListeners(); // at least triggers UI rebuild
  }

  int _lowThresholdFor(Product p) => defaultLowThreshold;
  int _maxCapacityFor(Product p) => defaultMaxCapacity;

  bool isLow(Product p) => p.quantity <= _lowThresholdFor(p);
  bool isFull(Product p) => p.quantity >= _maxCapacityFor(p);

  /// Units sold over a rolling window.
  /// If you fed sales via [setSalesCounts], this is O(1).
  /// If not, it aggregates from [_orderItems] (O(n) but cached whenever you set orders/window).
  int unitsSold(Product p, {int? days}) {
    final window = (days != null && days > 0) ? days : _salesWindowDays;

    // Fast path: if the requested window equals the cached window, use the map.
    if (window == _salesWindowDays && _salesCounts.isNotEmpty) {
      return _salesCounts[p.id] ?? 0;
    }

    // Otherwise, aggregate on the fly from raw order items (still fine for small lists).
    if (_orderItems.isEmpty) return 0;
    final since = DateTime.now().subtract(Duration(days: window));
    var total = 0;
    for (final oi in _orderItems) {
      if (oi.productId == p.id && oi.createdAt.isAfter(since)) {
        total += oi.quantity;
      }
    }
    return total;
  }

  /// Optional metric: turnover within the window (units sold / average on-hand).
  /// If you don’t track average on-hand, this falls back to current quantity as a crude proxy.
  double? turnoverRate(Product p, {int? days}) {
    final sold = unitsSold(p, days: days);
    final avgOnHand = _avgOnHand(p, days: days);
    if (avgOnHand <= 0) return null;
    return sold / avgOnHand;
  }

  /// Ranked descending by units sold in current window.
  /// Filters out products with 0 sales by default (toggle includeZero if you want them).
  List<Product> bestSellers({bool includeZero = false}) {
    final list = List<Product>.of(_all);
    list.sort((a, b) => unitsSold(b, days: _salesWindowDays)
        .compareTo(unitsSold(a, days: _salesWindowDays)));
    return includeZero ? list : list.where((p) => unitsSold(p, days: _salesWindowDays) > 0).toList();
  }

  /// Ranked ascending by units sold in current window (zeros first).
  /// By default excludes products with no stock on hand (set includeOutOfStock = true to keep them).
  List<Product> slowMovers({bool includeOutOfStock = false}) {
    final list = List<Product>.of(_all);
    if (!includeOutOfStock) {
      list.removeWhere((p) => (p.quantity <= 0));
    }
    list.sort((a, b) => unitsSold(a, days: _salesWindowDays)
        .compareTo(unitsSold(b, days: _salesWindowDays)));
    return list;
  }

  bool get hasBestSellers => bestSellers(includeZero: false).isNotEmpty;
  bool get hasSlowMovers => slowMovers(includeOutOfStock: false).isNotEmpty;

  // ----------------------------
  // Internals
  // ----------------------------

  Map<String, int> _aggregateFromOrderItems(List<OrderItem> items, int windowDays) {
    final since = DateTime.now().subtract(Duration(days: windowDays));
    final Map<String, int> out = {};
    for (final oi in items) {
      if (oi.createdAt.isAfter(since)) {
        out.update(oi.productId, (v) => v + oi.quantity, ifAbsent: () => oi.quantity);
      }
    }
    return out;
  }

  /// Replace with your own snapshot logic if you track daily on-hand values.
  /// A simple and safe first pass is the *current* qty.
  double _avgOnHand(Product p, {int? days}) {
    return (p.quantity).toDouble();
  }
}
