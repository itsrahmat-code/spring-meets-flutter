// lib/others_page/profit_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchandise_management_system/models/profit_model.dart';
import 'package:merchandise_management_system/pages/manager_page.dart';
import 'package:merchandise_management_system/service/analytics_service.dart';


class ProfitDashboardPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  final AnalyticsService analytics;

  const ProfitDashboardPage({super.key, required this.profile, required this.analytics});

  @override
  State<ProfitDashboardPage> createState() => _ProfitDashboardPageState();
}

class _ProfitDashboardPageState extends State<ProfitDashboardPage> {
  late int _year;
  late Future<_Data> _future;
  final _cf = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
    _future = _load(_year);
  }

  Future<_Data> _load(int year) async {
    final monthly = await widget.analytics.getMonthlyProfit(year);
    final thisYear = await widget.analytics.getYearSummary(year);
    final lastYear = await widget.analytics.getYearSummary(year - 1);
    return _Data(monthly: monthly, thisYear: thisYear, lastYear: lastYear);
  }

  void _goBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ManagerPage(profile: widget.profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async { _goBack(); return false; },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profit Analytics'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack),
          actions: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous year',
              onPressed: () => setState(() => _future = _load(--_year)),
            ),
            Center(child: Text('$_year', style: const TextStyle(fontWeight: FontWeight.w700))),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next year',
              onPressed: () => setState(() => _future = _load(++_year)),
            ),
          ],
        ),
        body: FutureBuilder<_Data>(
          future: _future,
          builder: (context, snap) {
            if (!snap.hasData) {
              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              }
              return const Center(child: CircularProgressIndicator());
            }
            final d = snap.data!;
            final maxProfit = (d.monthly.map((e) => e.profit.abs()).fold<double>(0.0, (m, v) => v > m ? v : m)).clamp(1, double.infinity);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary compare
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        _kpi('This Year', _cf.format(d.thisYear.profit)),
                        _kpi('Last Year', _cf.format(d.lastYear.profit)),
                        _kpi('Δ', _cf.format(d.thisYear.profit - d.lastYear.profit)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Monthly list with mini bars
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const ListTile(
                          leading: Icon(Icons.trending_up),
                          title: Text('Monthly Profit'),
                          subtitle: Text('Revenue – Expenses'),
                        ),
                        const Divider(),
                        ...d.monthly.map((m) {
                          final ratio = (m.profit.abs() / maxProfit).clamp(0.0, 1.0);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 40, child: Text(_monthName(m.month))),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: ratio,
                                        minHeight: 8,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('৳ ${_cf.format(m.profit)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const SizedBox(width: 48),
                                    Text('Rev: ৳ ${_cf.format(m.revenue)}'),
                                    const SizedBox(width: 12),
                                    Text('Exp: ৳ ${_cf.format(m.expenses)}'),
                                  ],
                                )
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _kpi(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('৳ $value', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return (m >= 1 && m <= 12) ? names[m - 1] : '--';
  }
}

class _Data {
  final List<MonthlyProfit> monthly;
  final YearProfitSummary thisYear;
  final YearProfitSummary lastYear;
  _Data({required this.monthly, required this.thisYear, required this.lastYear});
}
