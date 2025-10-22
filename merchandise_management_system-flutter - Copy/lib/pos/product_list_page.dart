import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:merchandise_management_system/models/product_model.dart';
import 'package:merchandise_management_system/service/product_service.dart';
import 'package:merchandise_management_system/service/cart_service.dart';
import 'package:merchandise_management_system/pos/cart_page.dart';
import 'package:merchandise_management_system/pos/checkout_page.dart';

class ProductListPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ProductListPage({super.key, required this.profile});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _productService = ProductService();
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _productService.getAllProducts();
  }

  Future<void> _refresh() async {
    setState(() => _future = _productService.getAllProducts());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    // Provider<CartService> MUST exist above this widget (main.dart sets it)
    final cart = context.watch<CartService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Stock'),
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
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return ListView(children: const [
                SizedBox(height: 80),
                Center(child: Text('No products found')),
              ]);
            }

            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, i) {
                final p = items[i];
                final available = cart.availableStock(p);

                return ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: !cart.canAdd(p)
                        ? null
                        : () {
                      context.read<CartService>().add(p);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${p.name} added to cart')),
                      );
                    },
                  ),
                  title: Text(p.name),
                  subtitle: Text('${p.brand} • ${p.category.name}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Stock: $available / ${p.quantity}'),
                      Text('৳ ${p.price.toStringAsFixed(2)}'),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Total: ৳ ${cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
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
    );
  }
}
