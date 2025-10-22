import 'package:flutter/material.dart';
import 'package:merchandise_management_system/models/product_model.dart';
import 'package:merchandise_management_system/pages/manager_page.dart';
import 'package:merchandise_management_system/pos/cart_page.dart';
import 'package:merchandise_management_system/pos/checkout_page.dart';
import 'package:merchandise_management_system/pos/product_detail_page.dart';
import 'package:merchandise_management_system/service/cart_service.dart';
import 'package:merchandise_management_system/service/product_service.dart';
import 'package:provider/provider.dart';


class ProductListPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ProductListPage({super.key, required this.profile});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with SingleTickerProviderStateMixin {
  final _productService = ProductService();
  late Future<List<Product>> _future;

  final _searchCtrl = TextEditingController();
  String _query = '';

  late TabController _tabController;
  final List<Category> _cats = Category.values;

  @override
  void initState() {
    super.initState();
    _future = _productService.getAllProducts();
    _tabController = TabController(length: _cats.length, vsync: this);
    _tabController.addListener(_triggerRebuild);
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_triggerRebuild);
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _triggerRebuild() => setState(() {});

  Future<void> _refresh() async {
    setState(() => _future = _productService.getAllProducts());
    await _future;
  }

  void _goBackToManager() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => ManagerPage(profile: widget.profile)),
          (route) => false,
    );
  }

  List<Product> _applyFilters(List<Product> items) {
    final selected = _cats[_tabController.index];
    return items.where((p) {
      final byCat = p.category == selected;
      if (!byCat) return false;
      if (_query.isEmpty) return true;
      final hay = '${p.name} ${p.brand} ${p.model ?? ""}'.toLowerCase();
      return hay.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();

    return WillPopScope(
      onWillPop: () async {
        _goBackToManager();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Stock'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBackToManager,
            tooltip: 'Back to Manager',
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  ),
                  tooltip: 'Cart',
                ),
                if (cart.totalItems > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.totalItems}',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(96),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by name, brand, or model...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchCtrl.clear(),
                        tooltip: 'Clear',
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: _cats
                      .map((c) => Tab(text: c.name))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Product>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return ListView(children: [
                  const SizedBox(height: 80),
                  Center(child: Text('Error: ${snap.error}')),
                ]);
              }
              final all = snap.data ?? [];
              final filtered = _applyFilters(all);

              if (filtered.isEmpty) {
                return ListView(children: const [
                  SizedBox(height: 80),
                  Center(child: Text('No products match your filters')),
                ]);
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final p = filtered[i];
                  final available = cart.availableStock(p);

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(
                            product: p,
                            profile: widget.profile,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // leading badge
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  p.category.name.substring(0, 1),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // main info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          p.category.name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${p.brand}${p.model == null || p.model!.isEmpty ? '' : ' • ${p.model}'}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.inventory_2_outlined,
                                          size: 18,
                                          color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(width: 6),
                                      Text('Stock: $available / ${p.quantity}'),
                                      const Spacer(),
                                      Text(
                                        '৳ ${p.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.info_outline),
                                        label: const Text('Details'),
                                        onPressed: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ProductDetailPage(
                                              product: p,
                                              profile: widget.profile,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      FilledButton.icon(
                                        icon: const Icon(Icons.add_shopping_cart),
                                        label: const Text('Add'),
                                        onPressed: !cart.canAdd(p)
                                            ? null
                                            : () {
                                          context.read<CartService>().add(p);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${p.name} added to cart')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // sticky checkout bar
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Total: ৳ ${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: const Text('Checkout'),
                onPressed: cart.totalItems == 0
                    ? null
                    : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckoutPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
