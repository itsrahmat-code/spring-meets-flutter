// File: lib/pages/manager_page.dart

import 'package:flutter/material.dart';
import 'package:merchandise_management_system/entity/dashboard.dart';
import 'package:merchandise_management_system/pages/login_page.dart';
import 'package:merchandise_management_system/pages/manager_profile_page.dart';
import 'package:merchandise_management_system/pos/product_list_page.dart';
import 'package:merchandise_management_system/service/authservice.dart';
import 'package:merchandise_management_system/pos/add_product.dart'; // ProductAdd is here
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
    // The ProductAdd widget will handle navigation to ProductListPage
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
// ... (omitted helper methods for brevity) ...

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
                // FIX 3a: Pass the profile to ProductAdd
                onTap: () => _navigateToPage(ProductAdd(profile: widget.profile)),
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Product List'),
                onTap: () => _navigateToPage(ProductListPage(profile: widget.profile)),
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
// ... (omitted FutureBuilder for dashboard content) ...

              // Product Action Buttons (quick access)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    "Add Product",
                    Icons.add,
                    Colors.deepPurple,
                    // FIX 3b: Pass the profile to ProductAdd
                        () => _navigateToPage(ProductAdd(profile: widget.profile)),
                  ),
                  _buildActionButton(
                    "Product List",
                    Icons.list,
                    Colors.deepPurple,
                        () => _navigateToPage(ProductListPage(profile: widget.profile)),
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