// lib/pages/product_page.dart

import 'package:flutter/material.dart';

import '../entity/product.dart';
import '../service/product_service.dart';



class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productList;

  @override
  void initState() {
    super.initState();
    _productList = _productService.getAllProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productList = _productService.getAllProducts();
    });
  }

  void _deleteProduct(int id) async {
    await _productService.deleteProduct(id);
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product List")),
      body: FutureBuilder<List<Product>>(
        future: _productList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(product.productName),
                    subtitle: Text(
                      "Price: \$${product.price.toStringAsFixed(2)}\n"
                          "Quantity: ${product.quantity}\n"
                          "Total: \$${product.totalPrice.toStringAsFixed(2)}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteProduct(product.id!),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: _refreshProducts,
      ),
    );
  }
}
