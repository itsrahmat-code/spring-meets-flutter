// import 'package:flutter/material.dart';
// import 'package:merchandise_management_system/models/category_model.dart';
// import 'package:merchandise_management_system/models/product_model.dart';
//
// import 'package:merchandise_management_system/pages/manager_page.dart';
// import 'package:merchandise_management_system/pos/add_product.dart';
// import 'package:merchandise_management_system/pos/cart_page.dart';
// import 'package:merchandise_management_system/pos/product_detail_page.dart';
// import 'package:merchandise_management_system/service/cart_service.dart';
// import 'package:merchandise_management_system/service/product_service.dart';
//
// class ProductListPage extends StatefulWidget {
//   final Map<String, dynamic> profile;
//
//   const ProductListPage({super.key, required this.profile});
//
//   @override
//   State<ProductListPage> createState() => _ProductListPageState();
// }
//
// class _ProductListPageState extends State<ProductListPage>
//     with SingleTickerProviderStateMixin {
//   final ProductService _productService = ProductService();
//   final CartService _cartService = CartService();
//
//   late Future<List<Product>> _productsFuture;
//
//   final TextEditingController _searchController = TextEditingController();
//   List<Product> _allProducts = [];
//   List<Product> _filteredProducts = [];
//
//   late TabController _tabController;
//   final List<Category> _categories = Category.values;
//
//   String _currentSearchQuery = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _categories.length, vsync: this);
//     _tabController.addListener(_applyFilters);
//     _searchController.addListener(_onSearchChanged);
//     _fetchProducts();
//   }
//
//   @override
//   void dispose() {
//     _tabController.removeListener(_applyFilters);
//     _tabController.dispose();
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _fetchProducts() {
//     setState(() {
//       _productsFuture = _productService.getAllProducts();
//     });
//
//     _productsFuture.then((products) {
//       _allProducts = products;
//       _applyFilters();
//     }).catchError((error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to fetch products: $error')),
//       );
//     });
//   }
//
//   void _onSearchChanged() {
//     setState(() {
//       _currentSearchQuery = _searchController.text.toLowerCase();
//       _applyFilters();
//     });
//   }
//
//   void _applyFilters() {
//     final currentCategory = _categories[_tabController.index];
//     setState(() {
//       _filteredProducts = _allProducts.where((product) {
//         final categoryMatch = product.category == currentCategory;
//         final searchMatch = product.name.toLowerCase().contains(_currentSearchQuery) ||
//             product.brand.toLowerCase().contains(_currentSearchQuery);
//         return categoryMatch && searchMatch;
//       }).toList();
//     });
//   }
//
//   void _navigateToDetail(Product product) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ProductDetailPage(product: product),
//       ),
//     );
//
//     if (result == true) {
//       _fetchProducts();
//     }
//   }
//
//   void _navigateToManagerPage() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => ManagerPage(profile: widget.profile)),
//           (route) => false,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _navigateToManagerPage();
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Product Stock'),
//           backgroundColor: Colors.blueAccent,
//           centerTitle: true,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: _navigateToManagerPage,
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: _fetchProducts,
//             ),
//             Stack(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.shopping_cart),
//                   onPressed: () async {
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const CartPage()),
//                     );
//                     setState(() {}); // Update badge count after return
//                   },
//                 ),
//                 if (_cartService.totalItems > 0)
//                   Positioned(
//                     right: 8,
//                     top: 8,
//                     child: CircleAvatar(
//                       radius: 10,
//                       backgroundColor: Colors.red,
//                       child: Text(
//                         '${_cartService.totalItems}',
//                         style: const TextStyle(
//                             fontSize: 12, color: Colors.white),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ],
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(100),
//             child: Column(
//               children: [
//                 Padding(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search product by name or brand...',
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon: _searchController.text.isNotEmpty
//                           ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           _applyFilters();
//                         },
//                       )
//                           : null,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Colors.white70,
//                     ),
//                   ),
//                 ),
//                 TabBar(
//                   controller: _tabController,
//                   isScrollable: true,
//                   labelColor: Colors.white,
//                   unselectedLabelColor: Colors.white70,
//                   indicatorColor: Colors.white,
//                   tabs: _categories
//                       .map((c) => Tab(text: c.toString().split('.').last))
//                       .toList(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         body: FutureBuilder<List<Product>>(
//           future: _productsFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState != ConnectionState.done) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else if (!snapshot.hasData || _allProducts.isEmpty) {
//               return const Center(child: Text('No products found.'));
//             } else {
//               return TabBarView(
//                 controller: _tabController,
//                 children: _categories.map((category) {
//                   final productsForTab = _allProducts.where((p) {
//                     final categoryMatch = p.category == category;
//                     final searchMatch = p.name.toLowerCase().contains(_currentSearchQuery) ||
//                         p.brand.toLowerCase().contains(_currentSearchQuery);
//                     return categoryMatch && searchMatch;
//                   }).toList();
//
//                   if (productsForTab.isEmpty) {
//                     return Center(
//                         child: Text(
//                             'No ${_currentSearchQuery.isEmpty ? "" : "matching "}products in ${category.toString().split('.').last}.'));
//                   }
//
//                   return ListView.builder(
//                     padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
//                     itemCount: productsForTab.length,
//                     itemBuilder: (context, index) {
//                       final product = productsForTab[index];
//                       return Card(
//                         elevation: 2,
//                         margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             backgroundColor: Colors.blueAccent,
//                             child: Text(
//                               product.quantity.toString(),
//                               style: const TextStyle(
//                                   color: Colors.white, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           title: Text(
//                             '${product.name}',
//                             style: const TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Brand: ${product.brand} | Model: ${product.model ?? 'N/A'}'),
//                               Text(
//                                 'Unit: \$${product.price.toStringAsFixed(2)} | Total: \$${product.totalPrice.toStringAsFixed(2)}',
//                                 style: const TextStyle(color: Colors.black54),
//                               ),
//                             ],
//                           ),
//                           trailing: IconButton(
//                             icon: const Icon(Icons.add_shopping_cart),
//                             onPressed: () {
//                               if (product.quantity > 0) {
//                                 setState(() {
//                                   _cartService.addToCart(product);
//                                   product.quantity--;
//                                 });
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('${product.name} added to cart')),
//                                 );
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(content: Text('Out of stock')),
//                                 );
//                               }
//                             },
//                           ),
//                           onTap: () => _navigateToDetail(product),
//                         ),
//                       );
//                     },
//                   );
//                 }).toList(),
//               );
//             }
//           },
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () async {
//             final result = await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ProductAdd(profile: widget.profile),
//               ),
//             );
//             if (result == true) {
//               _fetchProducts();
//             }
//           },
//           child: const Icon(Icons.add),
//         ),
//       ),
//     );
//   }
// }
// chat
// // lib/pages/product_list_page.dart
// import 'package:flutter/material.dart';
// import '../models/product.dart';
// import '../services/product_service.dart';
// import 'product_detail_page.dart';
// import 'product_upsert_page.dart';
//
// class ProductListPage extends StatefulWidget {
//   const ProductListPage({super.key});
//
//   @override
//   State<ProductListPage> createState() => _ProductListPageState();
// }
//
// class _ProductListPageState extends State<ProductListPage> {
//   final _service = ProductService();
//   late Future<List<Product>> _future;
//
//   @override
//   void initState() {
//     super.initState();
//     _future = _service.fetchAll();
//   }
//
//   Future<void> _refresh() async {
//     setState(() => _future = _service.fetchAll());
//     await _future;
//   }
//
//   void _openAdd() async {
//     final created = await Navigator.of(context).push<Product?>(
//       MaterialPageRoute(builder: (_) => ProductUpsertPage()),
//     );
//     if (created != null) {
//       // refresh list
//       _refresh();
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Product added')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Products')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _openAdd,
//         child: const Icon(Icons.add),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: FutureBuilder<List<Product>>(
//           future: _future,
//           builder: (context, snap) {
//             if (snap.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (snap.hasError) {
//               return ListView(
//                 children: [
//                   const SizedBox(height: 80),
//                   Center(child: Text('Error: ${snap.error}')),
//                 ],
//               );
//             }
//             final items = snap.data ?? [];
//             if (items.isEmpty) {
//               return ListView(
//                 children: const [
//                   SizedBox(height: 80),
//                   Center(child: Text('No products yet')),
//                 ],
//               );
//             }
//             return ListView.separated(
//               itemCount: items.length,
//               separatorBuilder: (_, __) => const Divider(height: 0),
//               itemBuilder: (context, i) {
//                 final p = items[i];
//                 return ListTile(
//                   title: Text(p.name),
//                   subtitle: Text('${p.brand} • ${p.category.name}'),
//                   trailing: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text('Qty: ${p.quantity}'),
//                       Text('৳ ${p.price.toStringAsFixed(2)}'),
//                     ],
//                   ),
//                   onTap: () async {
//                     await Navigator.of(context).push(
//                       MaterialPageRoute(builder: (_) => ProductDetailPage(id: p.id!)),
//                     );
//                     if (!mounted) return;
//                     _refresh();
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//gimini
// lib/screens/product_list_page.dart


import 'package:flutter/material.dart';
import 'package:merchandise_management_system/models/product_model.dart';
import 'package:merchandise_management_system/pos/add_product.dart';

import 'package:merchandise_management_system/pos/product_detail_page.dart';
import 'package:merchandise_management_system/service/product_service.dart';

class ProductListPage extends StatefulWidget {
  // ******* Added profile parameter *******
  final Map<String, dynamic> profile;

  const ProductListPage({super.key, required this.profile});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getAllProducts();
  }

  // Function to refresh the list of products
  void _refreshProducts() {
    setState(() {
      _productsFuture = _productService.getAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Stock 📦'),
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
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text('${product.name} (${product.brand})'),
                    subtitle: Text(
                        'Category: ${product.category.toShortString()} | Stock: ${product.quantity}'),
                    trailing: Text('\$${product.price.toStringAsFixed(2)}'),
                    onTap: () async {
                      // Navigate to detail page and wait for a refresh signal
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailPage(productId: product.id!),
                        ),
                      );
                      // Refresh the list when returning from detail/edit
                      _refreshProducts();
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ******* Navigation FIX: Passing profile to AddProductPage *******
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductAdd(profile: widget.profile), // Pass profile here
            ),
          );
          // Refresh the list when returning from adding a product
          _refreshProducts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}