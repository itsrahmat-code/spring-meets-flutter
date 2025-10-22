import 'package:flutter/material.dart';
import 'package:merchandise_management_system/models/product_model.dart';
import 'package:merchandise_management_system/pos/add_product.dart';
import 'package:merchandise_management_system/service/product_service.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
  final Map<String, dynamic>? profile;

  const ProductDetailPage({super.key, required this.productId, this.profile});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ProductService _productService = ProductService();
  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProductById(widget.productId);
  }

  void _refreshProduct() {
    setState(() {
      _productFuture = _productService.getProductById(widget.productId);
    });
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(widget.productId);
        if (context.mounted) Navigator.pop(context, true);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete product: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          FutureBuilder<Product>(
            future: _productFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductAdd(
                          productToEdit: snapshot.data!,
                          profile: widget.profile ?? const {}, // safe default
                        ),
                      ),
                    );
                    _refreshProduct();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Product not found.'));
          } else {
            final product = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                _buildDetailRow('ID', product.id.toString()),
                _buildDetailRow('Name', product.name),
                // 🔧 Use .name instead of toShortString()
                _buildDetailRow('Category', product.category.name),
                _buildDetailRow('Brand', product.brand),
                _buildDetailRow('Model', product.model ?? 'N/A'),
                _buildDetailRow('Quantity', product.quantity.toString()),
                _buildDetailRow('Price', '৳${product.price.toStringAsFixed(2)}'),
                _buildDetailRow('Total Value', '৳${product.totalPrice.toStringAsFixed(2)}'),
                _buildDetailRow('Details', product.details ?? 'No details provided'),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }
}
