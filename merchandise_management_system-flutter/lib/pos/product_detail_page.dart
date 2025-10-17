import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entity/product.dart';
import '../entity/Category.dart';
import '../service/cart_service.dart';
import 'add_invoice.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _currentProduct;
  int _quantityToSell = 1;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  void _startEditMode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon!')),
    );
  }

  int getAvailableStock(CartService cart) {
    final cartItem = cart.items.firstWhere(
          (item) => item.id == _currentProduct.id,
      orElse: () => _currentProduct.copyWith(quantity: 0),
    );
    return _currentProduct.quantity - cartItem.quantity;
  }

  void _addToCart() {
    final cart = Provider.of<CartService>(context, listen: false);

    final availableStock = getAvailableStock(cart);

    if (_quantityToSell > availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity exceeds available stock!')),
      );
      return;
    }

    final itemForCart = _currentProduct.copyWith(quantity: _quantityToSell);
    cart.addItem(itemForCart, quantity: _quantityToSell);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_quantityToSell}x ${_currentProduct.name} added to cart!'),
        action: SnackBarAction(
          label: 'Checkout',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddInvoicePage()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isHighlight ? Colors.deepPurple : Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isHighlight ? Colors.deepPurple : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final availableStock = getAvailableStock(cart);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _startEditMode,
            tooltip: 'Edit Product',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentProduct.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const Divider(height: 20, thickness: 2),
                _buildDetailRow('Product ID', _currentProduct.id?.toString() ?? 'N/A', isHighlight: true),
                _buildDetailRow('Quantity in Stock', _currentProduct.quantity.toString(), isHighlight: true),
                _buildDetailRow('Unit Price', '\$${_currentProduct.price.toStringAsFixed(2)}', isHighlight: true),
                _buildDetailRow('Total Stock Value', '\$${_currentProduct.totalPrice.toStringAsFixed(2)}', isHighlight: true),
                const Divider(height: 20),
                _buildDetailRow('Brand', _currentProduct.brand),
                _buildDetailRow('Category', _currentProduct.category.toString().split('.').last),
                _buildDetailRow('Model', _currentProduct.model ?? 'N/A'),
                const Divider(height: 20),
                _buildDetailRow('Invoice ID', _currentProduct.invoiceId?.toString() ?? 'N/A'),
                const SizedBox(height: 10),
                const Text('Details/Description:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _currentProduct.details ?? 'No additional details provided.',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Selling Controls (Add to Cart Button is here) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Controls
                    Row(
                      children: [
                        const Text('Sell:', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          onPressed: _quantityToSell > 1
                              ? () => setState(() => _quantityToSell--)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _quantityToSell.toString(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          onPressed: _quantityToSell < availableStock
                              ? () => setState(() => _quantityToSell++)
                              : null,
                        ),
                      ],
                    ),

                    // Add to Cart Button
                    ElevatedButton.icon(
                      onPressed: _addToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddInvoicePage()),
            );
          },
          icon: const Icon(Icons.receipt_long, size: 28),
          label: const Text('VIEW CHECKOUT / CART', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
