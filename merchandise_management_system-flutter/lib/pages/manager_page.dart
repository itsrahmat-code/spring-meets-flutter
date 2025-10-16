// File: lib/pages/manager_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchandise_management_system/pages/login_page.dart';
import 'package:merchandise_management_system/service/authservice.dart';
import '../entity/dashboard.dart';
import '../pos/product_list_page.dart';
import 'package:merchandise_management_system/pos/add_product.dart';
import 'manager_profile_page.dart'; // Import the new profile page

import '../service/dashboardservice.dart';

// ManagerPage is now a StatefulWidget to handle dashboard data fetching
class ManagerPage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const ManagerPage({Key? key, required this.profile}) : super(key: key);

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  final AuthService _authService = AuthService();
  final DashboardService _dashboardService = DashboardService();
  late Future<DashboardModel> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _dashboardService.getDashboardData();
  }

  void _navigateToPage(Widget page) {
    Navigator.pop(context); // Close the drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // Helper method to format date (moved from ManagerProfilePage for the drawer header)
  String _formatDate(dynamic date) {
    try {
      DateTime parsedDate;
      if (date is String) {
        parsedDate = DateTime.parse(date);
      } else if (date is DateTime) {
        parsedDate = date;
      } else {
        return 'N/A';
      }
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return 'N/A';
    }
  }

  // New helper for building Dashboard Cards (for brevity in the main build method)
  Widget _buildDashboardCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New helper for building Category Section (for brevity in the main build method)
  Widget _buildCategorySection(Map<String, int> categories) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Products by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const Divider(),
            ...categories.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${entry.value} units',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  // New helper for building Action Buttons (for brevity in the main build method)
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String baseUrl = "http://localhost:8085/images/roleManager/";
    final String? photoName = widget.profile['photo'];
    final String? photoUrl =
    (photoName != null && photoName.isNotEmpty) ? "$baseUrl$photoName" : null;

    final String name = widget.profile['name'] ?? 'N/A';
    final String email = widget.profile['email'] ?? 'N/A';

    return WillPopScope(
      onWillPop: () async {
        // Prevent back button from leaving the page unless it's the Logout button
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please use the Logout button to exit.')),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Manager Dashboard',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          elevation: 4,
        ),
        // --- UPDATED DRAWER ---
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.deepPurple),
                accountName: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: (photoUrl != null)
                      ? NetworkImage(photoUrl)
                      : const AssetImage('assets/default_avatar.png')
                  as ImageProvider,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () => Navigator.pop(context), // Close drawer and stay here
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Profile'),
                onTap: () => _navigateToPage(ManagerProfilePage(profile: widget.profile)),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: const Text('Add Product'),
                onTap: () => _navigateToPage(const ProductAdd()),
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Product List'),
                onTap: () => _navigateToPage(const ProductListPage()),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.deepOrange),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.deepOrange),
                ),
                onTap: () async {
                  await _authService.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        // --- DASHBOARD BODY ---
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Business Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const Divider(),

              FutureBuilder<DashboardModel>(
                future: _dashboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(color: Colors.deepPurple),
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading dashboard: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    return Column(
                      children: [
                        // Total Sales, Profit, Expense
                        Row(
                          children: [
                            _buildDashboardCard(
                              'Total Sales',
                              '\$${data.totalSales.toStringAsFixed(2)}',
                              Icons.trending_up,
                              Colors.green,
                            ),
                            _buildDashboardCard(
                              'Total Profit',
                              '\$${data.totalProfit.toStringAsFixed(2)}',
                              Icons.monetization_on,
                              Colors.blue,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildDashboardCard(
                              'Total Expense',
                              '\$${data.totalExpense.toStringAsFixed(2)}',
                              Icons.money_off,
                              Colors.red,
                            ),
                            _buildDashboardCard(
                              'Product Types',
                              data.productsByCategory.length.toString(),
                              Icons.category,
                              Colors.orange,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Products by Category
                        _buildCategorySection(data.productsByCategory),

                        const SizedBox(height: 30),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Product Action Buttons (quick access)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    "Add Product",
                    Icons.add,
                    Colors.deepPurple,
                        () => _navigateToPage(const ProductAdd()),
                  ),
                  _buildActionButton(
                    "Product List",
                    Icons.list,
                    Colors.deepPurple,
                        () => _navigateToPage(const ProductListPage()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}