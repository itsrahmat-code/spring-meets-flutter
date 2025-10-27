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
            // Header row made more adaptive for tight layouts
            LayoutBuilder(
              builder: (ctx, c) {
                final header = Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Profit — $title',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      fit: FlexFit.loose,
                      child: SegmentedButton<ProfitRange>(
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
                );

                // If there isn't enough width, allow wrapping to two lines.
                if (c.maxWidth < 360) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Profit — $title',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Refresh',
                            icon: const Icon(Icons.refresh),
                            onPressed: () => setState(() {
                              _profitFuture = _loadProfitSummary();
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                    ],
                  );
                }

                return header;
              },
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
          label: Text(label, overflow: TextOverflow.ellipsis),
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

  // ---------- Tiny helpers for staff UI ----------

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.take(2).toString().toUpperCase();
    return (parts.first.characters.take(1).toString() + parts.last.characters.take(1).toString()).toUpperCase();
  }

  Widget _staffAvatar({
    required String baseUrl,
    required Map<String, dynamic> staff,
  }) {
    final String? photo = staff['photo'];
    final String name = (staff['name'] ?? 'Staff').toString();
    final ImageProvider img = (photo != null && photo.toString().isNotEmpty)
        ? NetworkImage('$baseUrl$photo')
        : const AssetImage('assets/default_avatar.png');
    return Tooltip(
      message: name,
      child: CircleAvatar(
        radius: 12,
        backgroundImage: img,
        child: photo == null || photo.toString().isEmpty
            ? Text(
          _initials(name),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        )
            : null,
      ),
    );
  }

  // ---------- HIGHLIGHT CARD (with staff reference) ----------

  Widget _highlightCard({
    required String name,
    required String? photoUrl,
    required ProfitSummary summary,
    required int? staffCount,
    required List<Map<String, dynamic>>? staff,
    required String imagesBaseUrl,
  }) {
    final rangeTitle = _range == ProfitRange.today ? 'Today' : 'This Month';
    final totalSalesMoney = '৳ ${_money.format(summary.sales)}';
    final profit = summary.profitOnSales;
    final profitMoney = '৳ ${_money.format(profit)}';
    final bonusEarned = profit > 0;

    ImageProvider avatarProvider;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      avatarProvider = NetworkImage(photoUrl);
    } else {
      avatarProvider = const AssetImage('assets/default_avatar.png');
    }

    // Build a small row of staff avatars if provided
    final List<Widget> staffAvatars = [];
    if (staff != null && staff.isNotEmpty) {
      final show = staff.take(5); // show up to 5
      for (final s in show) {
        staffAvatars.add(_staffAvatar(baseUrl: imagesBaseUrl, staff: s));
        staffAvatars.add(const SizedBox(width: 6));
      }
      if (staff.length > 5) {
        staffAvatars.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.deepPurple.withOpacity(0.25)),
            ),
            child: Text(
              '+${staff.length - 5}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.deepPurple),
            ),
          ),
        );
      } else if (staffAvatars.isNotEmpty) {
        staffAvatars.removeLast(); // remove last spacer
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepPurple, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Photo
          CircleAvatar(
            radius: 32,
            backgroundImage: avatarProvider,
          ),
          const SizedBox(width: 14),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with name + optional bonus chip
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Hi, $name 👋",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (bonusEarned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium, size: 16, color: Colors.green),
                            SizedBox(width: 6),
                            Text(
                              "Bonus Earned",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Dynamic line about sales
                Text(
                  "Great job! $rangeTitle total sales:",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),

                // Total sales (amount)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.deepPurple),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_money, size: 18, color: Colors.deepPurple),
                      const SizedBox(width: 6),
                      Text(
                        totalSalesMoney,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Motivational / bonus blurb with staff mention
                Text(
                  profit > 0
                      ? "🔥 Fantastic work by you and your staff${staffCount != null ? " ($staffCount)" : ""}! $rangeTitle profit is $profitMoney — keep the momentum going!"
                      : "⚡ You and your staff${staffCount != null ? " ($staffCount)" : ""} are building momentum. Focus on high-margin items to turn profit positive.",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                const Text(
                  "💰 Performance bonus will be calculated from profit — keep pushing, team!",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),

                // Tiny staff avatar row (optional)
                if (staffAvatars.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.group, size: 16, color: Colors.deepPurple),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: 6,
                          children: staffAvatars,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
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

    // Optional staff data from profile (if you have it)
    final int? staffCount = widget.profile['staffCount'] is int
        ? widget.profile['staffCount'] as int
        : (widget.profile['staff'] is List ? (widget.profile['staff'] as List).length : null);

    final List<Map<String, dynamic>>? staff = (widget.profile['staff'] is List)
        ? (widget.profile['staff'] as List)
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .cast<Map<String, dynamic>>()
        .toList()
        : null;

    final viewPadding = MediaQuery.of(context).viewPadding;
    final bottomPad = viewPadding.bottom; // safe-area bottom

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please use the Logout button to exit.')),
        );
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // allow content to move if keyboard shows
        appBar: AppBar(
          title: const Text('Manager Dashboard', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          elevation: 4,
        ),
        drawer: Drawer(
          child: SafeArea(
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
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
            physics: const BouncingScrollPhysics(),
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
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
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

                    final summary = snap.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _profitCard(summary),

                        // ---------- HIGHLIGHT CARD (Dynamic + Staff) ----------
                        _highlightCard(
                          name: name,
                          photoUrl: photoUrl,
                          summary: summary,
                          staffCount: staffCount,
                          staff: staff,
                          imagesBaseUrl: baseUrl, // reuse manager image base path
                        ),
                      ],
                    );
                  },
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
                const Text(
                  "Other Features",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
      ),
    );
  }
}
