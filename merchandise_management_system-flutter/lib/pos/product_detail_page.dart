// File: lib/pos/product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:merchandise_management_system/entity/product.dart';


class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // We'll use this state to potentially hold updated product data 
  // if you implement an edit form later. For now, it just displays.
  late Product _currentProduct;

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

  // Placeholder for the Edit functionality (to be implemented later)
  void _startEditMode() {
    // TODO: Implement navigation to an editable form, or show a dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProduct.name),
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
                // --- Title/Header ---
                Text(
                  _currentProduct.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const Divider(height: 20, thickness: 2),

                // --- Key Stock/Pricing Details ---
                _buildDetailRow('Product ID', _currentProduct.id?.toString() ?? 'N/A', isHighlight: true),
                _buildDetailRow('Quantity in Stock', _currentProduct.quantity.toString(), isHighlight: true),
                _buildDetailRow('Unit Price', '\$${_currentProduct.price.toStringAsFixed(2)}', isHighlight: true),
                _buildDetailRow('Total Stock Value', '\$${_currentProduct.totalPrice.toStringAsFixed(2)}', isHighlight: true),

                const Divider(height: 20),

                // --- Classification Details ---
                _buildDetailRow('Brand', _currentProduct.brand),
                _buildDetailRow('Category', _currentProduct.category.toString().split('.').last),
                _buildDetailRow('Model', _currentProduct.model ?? 'N/A'),

                const Divider(height: 20),

                // --- Invoice & Other Details ---
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}