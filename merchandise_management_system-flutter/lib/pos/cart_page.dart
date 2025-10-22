import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:merchandise_management_system/service/cart_service.dart';
import 'package:merchandise_management_system/pos/checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (_, i) {
          final line = items[i];
          final canAddMore = cart.availableStock(line.product) > 0;

          return ListTile(
            title: Text(line.product.name),
            subtitle: Text(
              'Unit: ৳ ${line.product.price.toStringAsFixed(2)} • '
                  'Subtotal: ৳ ${line.lineTotal.toStringAsFixed(2)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => context.read<CartService>().decrement(line.product),
                ),
                Text('${line.quantity}'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: canAddMore
                      ? () => context.read<CartService>().add(line.product)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => context.read<CartService>().deleteItem(line.product),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.blue.shade50,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Total: ৳ ${cart.totalAmount.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('Checkout'),
              onPressed: items.isEmpty
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
