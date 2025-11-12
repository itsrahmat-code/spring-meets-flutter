import 'package:flutter/material.dart';
import 'package:merchandise_management_system/pos/product_edit_page.dart';
import 'package:provider/provider.dart';

import 'package:merchandise_management_system/models/product_model.dart';
import 'package:merchandise_management_system/service/cart_service.dart';
import 'package:merchandise_management_system/service/product_service.dart';


class ProductDetailPage extends StatelessWidget {
  final Product product;
  final Map<String, dynamic> profile;
  final ProductService api;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.profile,
    required this.api,
  });

  Future<void> _confirmAndDelete(BuildContext context) async {
    if (product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete: product has no ID')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.name}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await api.deleteProduct(product.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${product.name}"')),
        );
        Navigator.of(context).pop(true); // tell list: deleted
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _edit(BuildContext context) async {
    final updated = await Navigator.of(context).push<Product>(
      MaterialPageRoute(
        builder: (_) => ProductEditPage(
          original: product,
          api: api,
        ),
      ),
    );
    if (updated != null && context.mounted) {
      // Return the updated product to the list page
      Navigator.of(context).pop(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    final available = cart.availableStock(product);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') _edit(context);
              if (v == 'delete') _confirmAndDelete(context);
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
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

          // Bottom actions
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

          const SizedBox(height: 12),

          // Quick Edit / Delete buttons (optional)
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  onPressed: () => _confirmAndDelete(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
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
