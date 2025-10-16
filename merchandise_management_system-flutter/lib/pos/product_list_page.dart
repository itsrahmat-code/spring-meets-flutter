import 'package:flutter/material.dart';

import '../entity/product.dart';
import '../service/product_service.dart';


class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> _productsFuture;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getAllProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _productService.getAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Stock'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProducts,
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          } else {
            // Data loaded successfully
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(product.quantity.toString()),
                  ),
                  title: Text('${product.name} (${product.brand})'),
                  subtitle: Text(
                      'Price: \$${product.price.toStringAsFixed(2)} | Total: \$${product.totalPrice.toStringAsFixed(2)}'),
                  trailing: Text(product.category.toString().split('.').last),
                  onTap: () {
                    // TODO: Implement navigation to a Product Detail/Edit Page
                    print('Tapped on product ID: ${product.id}');
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement navigation to an Add New Product Page
          print('Add new product button pressed');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}