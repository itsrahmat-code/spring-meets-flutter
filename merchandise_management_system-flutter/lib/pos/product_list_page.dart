// File: lib/pos/product_list_page.dart (or equivalent location)

import 'package:flutter/material.dart';

import '../entity/Category.dart';
import '../entity/product.dart';
import '../service/product_service.dart';
import 'product_detail_page.dart';
import 'package:merchandise_management_system/pos/add_product.dart'; // Import your Add Product Page

// Add the WillPopScope to restrict back navigation
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with SingleTickerProviderStateMixin {

  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  // State for search and filtering
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  // Tab Controller for category separation
  late TabController _tabController;
  final List<Category> _categories = Category.values;

  // State for the current search query
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_applyFilters);
    _searchController.addListener(_onSearchChanged);
    _fetchProducts();
  }

  @override
  void dispose() {
    _tabController.removeListener(_applyFilters);
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // --- Data Fetching and Filtering Logic ---
  void _fetchProducts() {
    setState(() {
      _productsFuture = _productService.getAllProducts();
    });

    _productsFuture.then((products) {
      _allProducts = products;
      _applyFilters();
    }).catchError((error) {
      // Error handled by FutureBuilder
      print('Failed to fetch products: $error');
    });
  }

  void _onSearchChanged() {
    setState(() {
      _currentSearchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    final currentCategory = _categories[_tabController.index];

    setState(() {
      _filteredProducts = _allProducts.where((product) {
        // Filter by Category
        final categoryMatch = product.category == currentCategory;

        // Filter by Search Query (Name or Brand)
        final searchMatch = product.name.toLowerCase().contains(_currentSearchQuery) ||
            product.brand.toLowerCase().contains(_currentSearchQuery);

        return categoryMatch && searchMatch;
      }).toList();
    });
  }

  void _navigateToDetail(Product product) async {
    // Navigate and await result if product was updated/deleted
    // The detail page should return 'true' if data was modified/deleted
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );

    // If result indicates a change, refresh the product list
    if (result == true) {
      _fetchProducts();
    }
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 🛑 ACTION 1: Back button navigate to Manager/Previous Page
      onWillPop: () async {
        // Pop the current page to return to the previous screen (ManagerPage)
        Navigator.pop(context);
        return false; // Prevent default system back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Stock'),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          // Since we are overriding WillPopScope, we should also add an explicit Back Button
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context), // Explicitly go back to ManagerPage
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchProducts, // Refreshes the original list
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100.0),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search product by name or brand...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                  ),
                ),

                // Category Tabs
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: _categories.map((c) => Tab(text: c.toString().split('.').last)).toList(),
                ),
              ],
            ),
          ),
        ),
        body: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || _allProducts.isEmpty) {
              return const Center(child: Text('No products found.'));
            } else {
              // Once data is loaded and filtered
              return TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  // Get products matching the current tab index and search query
                  final productsForTab = _allProducts.where((p) {
                    final categoryMatch = p.category == category;
                    final searchMatch = p.name.toLowerCase().contains(_currentSearchQuery) ||
                        p.brand.toLowerCase().contains(_currentSearchQuery);
                    return categoryMatch && searchMatch;
                  }).toList();

                  if (productsForTab.isEmpty) {
                    return Center(
                        child: Text(
                            'No ${_currentSearchQuery.isEmpty ? "" : "matching "}products in ${category.toString().split('.').last}.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 80.0), // Padding for FAB
                    itemCount: productsForTab.length,
                    itemBuilder: (context, index) {
                      final product = productsForTab[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              product.quantity.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            '${product.name}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Brand: ${product.brand} | Model: ${product.model ?? 'N/A'}'),
                              Text(
                                'Unit: \$${product.price.toStringAsFixed(2)} | Total: \$${product.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _navigateToDetail(product),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          // 🛑 ACTION 2: Navigate to Add Product Page
          onPressed: () async {
            // Use MaterialPageRoute with the actual imported widget (ProductAdd)
            final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductAdd())
            );
            if (result == true) {
              _fetchProducts(); // Refresh list if product was added successfully
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}