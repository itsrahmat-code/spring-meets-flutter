import 'package:flutter/material.dart';
import '../entity/product.dart';
import '../entity/Category.dart'; // Ensure Category.dart is available
import '../service/cart_service.dart';
// ⚠️ Ensure this path is correct based on your previous file:
import 'add_invoice.dart';



class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _currentProduct;
  // IMPORTANT: Since CartService is a Singleton, using the factory constructor is fine,
  // but for consistency with Provider setup, we will access it via Provider
  // in _addToCart, so we remove the local instance.
  // final CartService _cartService = CartService();
  int _quantityToSell = 1; // State for quantity to add to cart

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  // Helper method to build a detail row
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

  void _startEditMode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon!')),
    );
  }

  // ⚠️ Updated to use Provider context for better practice
  void _addToCart() {
    final cartService = CartService(); // Using Singleton access for simplicity here

    if (_quantityToSell > _currentProduct.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity exceeds stock!')),
      );
      return;
    }

    // Create a product instance with the *sale* quantity
    final itemForCart = _currentProduct.copyWith(quantity: _quantityToSell);

    // Add to cart service
    // The cart service handles aggregating items; we pass the single item with its desired quantity.
    cartService.addItem(itemForCart, quantity: _quantityToSell);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_quantityToSell}x ${_currentProduct.name} added to cart!'),
        action: SnackBarAction(
          label: 'Checkout',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InvoicePage()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 🚨 MODIFIED: Changed title to "Product Details"
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
        padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0, top: 16.0),
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
                // Correctly handles Category enum display
                _buildDetailRow('Category', _currentProduct.category.toString().split('.').last),
                _buildDetailRow('Model', _currentProduct.model ?? 'N/A'),
                const Divider(height: 20),
                _buildDetailRow('Invoice ID', _currentProduct.invoiceId?.toString() ?? 'N/A'),
                const SizedBox(height: 10),
                const Text(
                  'Details/Description:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
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
                    // Quantity Control
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
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Text(
                              _quantityToSell.toString(),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          // Disable button if quantity is maxed or stock is 0
                          onPressed: _quantityToSell < _currentProduct.quantity
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

      // Bottom bar for persistent Checkout button
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
            // Navigate to the Invoice Page (Checkout)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InvoicePage()),
            );
          },
          icon: const Icon(Icons.receipt_long, size: 28),
          label: const Text('VIEW CHECKOUT / CART', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple, // Distinct color for checkout
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
