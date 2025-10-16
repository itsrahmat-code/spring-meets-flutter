// lib/pages/product_list_page.dart
import 'package:flutter/material.dart';
import '../entity/invoice.dart';
import '../service/product_service.dart';


class ProductListPage extends StatefulWidget {
  final ProductService service;

  ProductListPage({required this.service});
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = widget.service.fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, idx) {
                final p = products[idx];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('${p.brand} - ${p.category}'),
                  trailing: Text('\$${p.price.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          productService: widget.service,
                          productId: p.id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // open page to create new product
          final added = await Navigator.push<Product?>(
            context,
            MaterialPageRoute(
              builder: (context) => ProductEditPage(
                service: widget.service,
                product: null,
              ),
            ),
          );
          if (added != null) {
            setState(() {
              _futureProducts = widget.service.fetchAllProducts();
            });
          }
        },
      ),
    );
  }
}
