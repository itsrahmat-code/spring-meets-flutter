import 'package:flutter/material.dart';
import 'package:merchandise_management_system/others_page/add_expense_page.dart';
import 'package:merchandise_management_system/others_page/expense_list_page.dart';
import 'package:merchandise_management_system/others_page/supplier_list_page.dart';
import 'package:merchandise_management_system/pages/login_page.dart';
import 'package:merchandise_management_system/pages/manager_profile_page.dart';
import 'package:merchandise_management_system/pos/add_product.dart';
import 'package:merchandise_management_system/pos/product_list_page.dart';
import 'package:merchandise_management_system/pos/invoice_list_page.dart';
import 'package:merchandise_management_system/pos/stock_alert_page.dart';
import 'package:merchandise_management_system/service/authservice.dart';
import 'package:merchandise_management_system/service/expense_service.dart';

import 'package:merchandise_management_system/service/supplier_api_service.dart';

class ManagerPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ManagerPage({Key? key, required this.profile}) : super(key: key);

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  final AuthService _authService = AuthService();
  final SupplierApiService _supplierApi = SupplierApiService();

  // Expense service instance (now valid because baseUrl is optional)
  final ExpenseService _expenseService = ExpenseService();

  void _navigateToPage(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showComingSoon(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$featureName feature coming soon!')),
    );
  }

  Widget _buildActionButton(
      String label,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String baseUrl = "http://localhost:8085/images/roleManager/";
    final String? photoName = widget.profile['photo'];
    final String? photoUrl = (photoName != null && photoName.isNotEmpty) ? "$baseUrl$photoName" : null;

    final String name = widget.profile['name'] ?? 'Manager';
    final String email = widget.profile['email'] ?? 'N/A';

    const int demoSoldCount = 340;

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please use the Logout button to exit.')),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manager Dashboard', style: TextStyle(color: Colors.white)),
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
                accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: (photoUrl != null)
                      ? NetworkImage(photoUrl)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
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
                onTap: () => _navigateToPage(ManagerProfilePage(profile: widget.profile)),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: const Text('Add Product'),
                onTap: () => _navigateToPage(ProductAdd(profile: widget.profile)),
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Product List'),
                onTap: () => _navigateToPage(ProductListPage(profile: widget.profile)),
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Invoice List'),
                onTap: () => _navigateToPage(InvoiceListPage(profile: widget.profile)),
              ),
              ListTile(
                leading: const Icon(Icons.groups_3),
                title: const Text('Suppliers'),
                onTap: () => _navigateToPage(SupplierListPage(api: _supplierApi)),
              ),

              // Expenses in drawer
              ListTile(
                leading: const Icon(Icons.payments),
                title: const Text('Expense List'),
                onTap: () => _navigateToPage(
                  ExpenseListPage(service: _expenseService, profile: widget.profile),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add_card),
                title: const Text('Add Expense'),
                onTap: () => _navigateToPage(
                  AddExpensePage(service: _expenseService, profile: widget.profile),
                ),
              ),

              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.deepOrange),
                title: const Text('Logout', style: TextStyle(color: Colors.deepOrange)),
                onTap: () async {
                  await _authService.logout();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
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
              // Highlight card
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
                      "💰 Great profit and a bonus for your effort.\n\n"
                      "🙌 Keep pushing boundaries!",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              // Row 1: Add Product / Product List
              Row(
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

              // Row 2: Invoice List / Supplier List
              Row(
                children: [
                  _buildActionButton(
                    "Invoice List",
                    Icons.receipt_long,
                    Colors.indigo,
                        () => _navigateToPage(InvoiceListPage(profile: widget.profile)),
                  ),
                  _buildActionButton(
                    "Supplier List",
                    Icons.groups_3,
                    Colors.teal,
                        () => _navigateToPage(SupplierListPage(api: _supplierApi)),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Row 3: Stock Status
              Row(
                children: [
                  _buildActionButton(
                    "Stock Status",
                    Icons.warning_amber,
                    Colors.redAccent,
                        () => _navigateToPage(StockAlertPage(profile: widget.profile)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text("Other Features",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Quick actions for expenses
              Row(
                children: [
                  _buildActionButton(
                    "Add Expense",
                    Icons.add_card,
                    Colors.orange,
                        () => _navigateToPage(
                      AddExpensePage(service: _expenseService, profile: widget.profile),
                    ),
                  ),
                  _buildActionButton(
                    "Expense List",
                    Icons.payments,
                    Colors.blueGrey,
                        () => _navigateToPage(
                      ExpenseListPage(service: _expenseService, profile: widget.profile),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Placeholder
              Row(
                children: [
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
