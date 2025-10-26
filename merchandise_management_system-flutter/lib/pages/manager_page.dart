// lib/pages/manager_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:merchandise_management_system/others_page/add_expense_page.dart';
import 'package:merchandise_management_system/others_page/expense_list_page.dart';
import 'package:merchandise_management_system/others_page/supplier_list_page.dart';
import 'package:merchandise_management_system/pages/login_page.dart';
import 'package:merchandise_management_system/pages/manager_profile_page.dart';
import 'package:merchandise_management_system/pages/profit_dashboard_page.dart';
import 'package:merchandise_management_system/pos/add_product.dart';
import 'package:merchandise_management_system/pos/product_list_page.dart';
import 'package:merchandise_management_system/pos/invoice_list_page.dart';
import 'package:merchandise_management_system/pos/stock_alert_page.dart';

import 'package:merchandise_management_system/service/analytics_service.dart';
import 'package:merchandise_management_system/service/authservice.dart';
import 'package:merchandise_management_system/service/expense_service.dart';
import 'package:merchandise_management_system/service/invoice_service.dart';
import 'package:merchandise_management_system/service/supplier_api_service.dart';

class ManagerPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ManagerPage({Key? key, required this.profile}) : super(key: key);

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

// ---------- PROFIT SUPPORT ----------

enum ProfitRange { today, month }

class ProfitSummary {
  final double sales;     // from invoices (sum of totals)
  final double collected; // sum of paid amounts
  final double expenses;  // from ExpenseService
  const ProfitSummary({
    required this.sales,
    required this.collected,
    required this.expenses,
  });

  double get profitOnSales => sales - expenses;
  double get profitOnCollected => collected - expenses;
}

// ------------------------------------

class _ManagerPageState extends State<ManagerPage> {
  // Services
  final AuthService _authService = AuthService();
  final SupplierApiService _supplierApi = SupplierApiService();
  final ExpenseService _expenseService = ExpenseService();
  final InvoiceService _invoiceService = InvoiceService();

  // Profit state
  ProfitRange _range = ProfitRange.month;
  late Future<ProfitSummary> _profitFuture;
  final _money = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _profitFuture = _loadProfitSummary();
  }

  // ---------- NAV & HELPERS ----------

  void _navigateToPage(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showComingSoon(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$featureName feature coming soon!')),
    );
  }

  // ---------- PROFIT CALCULATION ----------

  Future<ProfitSummary> _loadProfitSummary() async {
    final now = DateTime.now();
    late DateTime start, end;

    if (_range == ProfitRange.today) {
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    } else {
      start = DateTime(now.year, now.month, 1);
      // end-of-month (day 0 of next month)
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    }

    final invoices = await _invoiceService.getAllInvoices();
    final expenses = await _expenseService.getAll();

    bool within(DateTime? d) =>
        d != null && !d.isBefore(start) && !d.isAfter(end);

    final filteredInvoices = invoices.where((i) => within(i.date)).toList();
    final filteredExpenses = expenses.where((e) => within(e.date)).toList();

    final sales = filteredInvoices.fold<double>(0, (a, b) => a + b.total);
    final collected = filteredInvoices.fold<double>(0, (a, b) => a + b.paid);
    final expenseSum = filteredExpenses.fold<double>(0, (a, b) => a + b.amount);

    return ProfitSummary(sales: sales, collected: collected, expenses: expenseSum);
  }

  Widget _profitCard(ProfitSummary s) {
    final pSales = s.profitOnSales;
    final pCollected = s.profitOnCollected;
    final pos = (pSales >= 0);

    final trend = pos ? Colors.green : Colors.redAccent;
    final title = _range == ProfitRange.today ? 'Today' : 'This Month';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Profit — $title',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                SegmentedButton<ProfitRange>(
                  segments: const [
                    ButtonSegment(value: ProfitRange.today, label: Text('Today')),
                    ButtonSegment(value: ProfitRange.month, label: Text('Month')),
                  ],
                  selected: {_range},
                  onSelectionChanged: (sel) {
                    setState(() {
                      _range = sel.first;
                      _profitFuture = _loadProfitSummary();
                    });
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() {
                    _profitFuture = _loadProfitSummary();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _metricTile('Sales', '৳ ${_money.format(s.sales)}')),
                Expanded(child: _metricTile('Expenses', '৳ ${_money.format(s.expenses)}')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _pill(
                    label: 'Profit (Sales - Expenses)',
                    value: '৳ ${_money.format(pSales)}',
                    color: trend,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _pill(
                    label: 'Profit (Collected - Expenses)',
                    value: '৳ ${_money.format(pCollected)}',
                    color: (pCollected >= 0) ? Colors.green : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _pill({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color.withOpacity(0.9))),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 16)),
        ],
      ),
    );
  }

  // ---------- UI HELPERS ----------

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

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    const String baseUrl = "http://localhost:8085/images/roleManager/";
    final String? photoName = widget.profile['photo'];
    final String? photoUrl =
    (photoName != null && photoName.isNotEmpty) ? "$baseUrl$photoName" : null;

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
                accountName:
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Profit Analytics'),
                onTap: () {
                  final analytics =
                  AnalyticsService(baseUrl: 'http://localhost:8085/api/analytics');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfitDashboardPage(
                        profile: widget.profile,
                        analytics: analytics,
                      ),
                    ),
                  );
                },
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
              // ---------- PROFIT CARD (FutureBuilder) ----------
              FutureBuilder<ProfitSummary>(
                future: _profitFuture,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Calculating profit...'),
                          ],
                        ),
                      ),
                    );
                  }
                  if (snap.hasError) {
                    return Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Failed to load profit: ${snap.error}'),
                      ),
                    );
                  }
                  return _profitCard(snap.data!);
                },
              ),

              // ---------- HIGHLIGHT CARD ----------
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
                  style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              // ---------- QUICK ACTIONS ----------
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
