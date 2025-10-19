// File: lib/pos/product_list_page.dart

import 'package:flutter/material.dart';
import 'package:merchandise_management_system/entity/Category.dart';
import 'package:merchandise_management_system/entity/product.dart';
import 'package:merchandise_management_system/pages/manager_page.dart';
import 'package:merchandise_management_system/pos/add_product.dart';
import 'package:merchandise_management_system/pos/product_detail_page.dart';
import 'package:merchandise_management_system/service/product_service.dart'; // Assuming this points to ProductAdd

class ProductListPage extends StatefulWidget {
  // FIX 1: Add the required 'profile' parameter to the constructor
  final Map<String, dynamic> profile;

  const ProductListPage({super.key, required this.profile});

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch products: $error')),
        );
      }
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

  // FIX 2: Custom Back Navigation that pushes ManagerPage
  void _navigateToManagerPage() {
    // Use pushAndRemoveUntil to ensure ManagerPage is the root after returning.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => ManagerPage(profile: widget.profile)),
          (route) => false,
    );
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // FIX 3: Back button uses the custom navigation method
      onWillPop: () async {
        _navigateToManagerPage();
        return false; // Prevent default system back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Stock'),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          // FIX 4: Explicit Back Button uses the custom navigation method
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateToManagerPage,
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
          // Navigate to Add Product Page
          onPressed: () async {
            // FIX 5: Pass the required 'profile' to ProductAdd and remove 'const'
            final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductAdd(profile: widget.profile))
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