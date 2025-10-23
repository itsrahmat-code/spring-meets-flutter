import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:merchandise_management_system/models/product_model.dart';
import 'package:merchandise_management_system/service/cart_service.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final Map<String, dynamic> profile;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    final available = cart.availableStock(product);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero-ish header card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        product.category.name.substring(0, 1),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('${product.brand} ${product.model ?? ''}'.trim(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            )),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(product.category.name),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _kv(context, 'ID', '${product.id ?? '-'}'),
          _kv(context, 'Category', product.category.name),
          _kv(context, 'Brand', product.brand),
          _kv(context, 'Model', product.model ?? 'N/A'),
          _kv(context, 'Stock (available / total)', '$available / ${product.quantity}'),
          _kv(context, 'Unit Price', '৳ ${product.price.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _sectionTitle(context, 'Details'),
          Text(
            product.details?.trim().isEmpty ?? true
                ? 'No details provided'
                : product.details!,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                  onPressed: !cart.canAdd(product)
                      ? null
                      : () {
                    context.read<CartService>().add(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} added to cart')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              k,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(fontSize: 15.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        t,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }
}
