import 'package:flutter/material.dart';

import 'package:merchandise_management_system/pages/login_page.dart';
import 'package:merchandise_management_system/pages/manager_profile_page.dart';
import 'package:merchandise_management_system/pos/invoice_list_page.dart';
import 'package:merchandise_management_system/pos/product_list_page.dart';
import 'package:merchandise_management_system/service/authservice.dart';
import 'package:merchandise_management_system/pos/add_product.dart';


class ManagerPage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const ManagerPage({Key? key, required this.profile}) : super(key: key);

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  final AuthService _authService = AuthService();


  void _navigateToPage(Widget page) {
    Navigator.pop(context); // Close the drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showComingSoon(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
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

    final String name = widget.profile['name'] ?? 'Manager';
    final String email = widget.profile['email'] ?? 'N/A';

    const int demoSoldCount = 340; // 🔥 Fixed demo value for total sold

    return WillPopScope(
      onWillPop: () async {
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
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Profile'),
                onTap: () =>
                    _navigateToPage(ManagerProfilePage(profile: widget.profile)),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: const Text('Add Product'),
                onTap: () =>
                    _navigateToPage(ProductAdd(profile: widget.profile)),
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Product List'),
                onTap: () =>
                    _navigateToPage(ProductListPage(profile: widget.profile)),
              ),
              ListTile(
                leading: const Icon(Icons.receipt),
                title: const Text('Invoice List'),
                onTap: () => _navigateToPage(InvoiceListPage()),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🎉 Motivational Message Block
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.deepPurple, width: 1),
                ),
                child: Text(
                  "🎉 Well done, $name!\n\n"
                      "📦 Last month, your shop sold a total of **$demoSoldCount** products.\n"
                      "💰 We’ve made a great profit and you’ve earned a bonus for your amazing effort.\n\n"
                      "🙌 Keep pushing boundaries and inspiring your team.\n"
                      "Together, we will touch the sky!",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              // Product Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    "Add Product",
                    Icons.add,
                    Colors.deepPurple,
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
              const SizedBox(height: 10),

              // Invoice Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    "Invoice List",
                    Icons.receipt,
                    Colors.indigo,
                        () => _navigateToPage(InvoiceListPage()),
                  ),
                  _buildActionButton(
                    "Add Invoice",
                    Icons.shopping_cart_checkout,
                    Colors.teal,
                        () => _navigateToPage(const InvoiceListPage()),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Other Features
              const Text(
                "Other Features",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    "Sales Report",
                    Icons.bar_chart,
                    Colors.orange,
                        () => _showComingSoon("Sales Report"),
                  ),
                  _buildActionButton(
                    "Low Stock",
                    Icons.warning_amber,
                    Colors.redAccent,
                        () => _showComingSoon("Low Stock"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    "Important Contact",
                    Icons.contact_phone,
                    Colors.blueGrey,
                        () => _showComingSoon("Important Contact"),
                  ),
                  _buildActionButton(
                    "System Info",
                    Icons.info,
                    Colors.grey,
                        () => _showComingSoon("System Info"),
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
