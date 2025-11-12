import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:merchandise_management_system/models/product_model.dart';
import 'package:merchandise_management_system/pages/manager_page.dart';
import 'package:merchandise_management_system/service/stock_alert_service.dart';

class StockAlertPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  const StockAlertPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<StockAlertService>();

    // Existing: low & full (sorted locally for display)
    final lows = List<Product>.of(svc.lowStock)
      ..sort((a, b) => a.quantity.compareTo(b.quantity));
    final fulls = List<Product>.of(svc.fullStock)
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    // NEW: best sellers & slow movers (service already ranks them)
    final best = List<Product>.of(svc.bestSellers());
    final slow = List<Product>.of(svc.slowMovers());

    return WillPopScope(
      onWillPop: () async {
        _goBackToManager(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back to Manager',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _goBackToManager(context),
          ),
          title: const Text('Stock & Sales Alerts'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: () => svc.refresh(), // service refresh
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(36),
            child: _summaryBar(
              context,
              lows.length,
              fulls.length,
              best.length,
              slow.length,
            ),
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => svc.refresh(), // pull-to-refresh
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
              children: [
                // --- SALES SECTIONS ---
                _sectionCard(
                  context: context,
                  title: 'Best sellers (30d)',
                  icon: Icons.trending_up,
                  color: Colors.purple,
                  count: best.length,
                  emptyText: 'No best sellers yet',
                  children: best
                      .map((p) => _salesTile(context, svc, p, isBest: true))
                      .toList(),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  context: context,
                  title: 'Slow movers (30d)',
                  icon: Icons.trending_down,
                  color: Colors.blueGrey,
                  count: slow.length,
                  emptyText: 'No slow movers 🎉',
                  children: slow
                      .map((p) => _salesTile(context, svc, p, isBest: false))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // --- STOCK SECTIONS ---
                _sectionCard(
                  context: context,
                  title: 'Low stock',
                  icon: Icons.warning_amber,
                  color: Colors.orange,
                  count: lows.length,
                  emptyText: 'No low-stock items 🎉',
                  children: lows
                      .map((p) => _stockTile(context, p, isLow: true))
                      .toList(),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  context: context,
                  title: 'Stock full',
                  icon: Icons.inventory_2,
                  color: Colors.green,
                  count: fulls.length,
                  emptyText: 'No stock-full items',
                  children: fulls
                      .map((p) => _stockTile(context, p, isLow: false))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goBackToManager(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => ManagerPage(profile: profile)),
          (route) => false,
    );
  }

  // UPDATED: summary pills now include sales
  Widget _summaryBar(
      BuildContext ctx, int lowCount, int fullCount, int bestCount, int slowCount) {
    final onVar = Theme.of(ctx).colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          _summaryPill(ctx, 'Best', bestCount, Colors.purple),
          const SizedBox(width: 8),
          _summaryPill(ctx, 'Slow', slowCount, Colors.blueGrey),
          const SizedBox(width: 8),
          _summaryPill(ctx, 'Low', lowCount, Colors.orange),
          const SizedBox(width: 8),
          _summaryPill(ctx, 'Full', fullCount, Colors.green),
          const Spacer(),
          Text(
            'Total alerts: ${lowCount + fullCount + bestCount + slowCount}',
            style: TextStyle(color: onVar),
          ),
        ],
      ),
    );
  }

  Widget _summaryPill(BuildContext ctx, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(
            label == 'Low'
                ? Icons.warning_amber
                : label == 'Full'
                ? Icons.inventory_2
                : label == 'Best'
                ? Icons.trending_up
                : Icons.trending_down,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            '$label • $count',
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ---------- Shared section card ----------
  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required String emptyText,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(context, title, icon, color, count),
            const SizedBox(height: 8),
            if (children.isEmpty)
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                child: Text(emptyText,
                    style: const TextStyle(color: Colors.black54)),
              )
            else
              ..._intersperse(children, const Divider(height: 0)),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
      BuildContext ctx, String title, IconData icon, Color color, int count) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(ctx)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Chip(
          label: Text('$count'),
          backgroundColor: color.withOpacity(0.12),
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  // ---------- Stock tile (existing) ----------
  Widget _stockTile(BuildContext ctx, Product p, {required bool isLow}) {
    final color = isLow ? Colors.orange : Colors.green;
    final label = isLow ? 'Low' : 'Full';

    return ListTile(
      isThreeLine: true,
      minVerticalPadding: 10,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            p.category.name.substring(0, 1),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(ctx).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${p.brand}${p.model == null || p.model!.isEmpty ? '' : ' • ${p.model}'}',
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Chip(
            label: Text(label),
            backgroundColor: color.withOpacity(0.12),
            labelStyle: TextStyle(color: color),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(height: 4),
          Text('Qty: ${p.quantity}'),
        ],
      ),
    );
  }

  // ---------- Sales tile (new) ----------
  Widget _salesTile(BuildContext ctx, StockAlertService svc, Product p,
      {required bool isBest}) {
    final color = isBest ? Colors.purple : Colors.blueGrey;
    final label = isBest ? 'Best' : 'Slow';
    final sold30d = svc.unitsSold(p, days: 30); // service computes this
    final turnDays = 30;
    final turnRate = svc.turnoverRate(p, days: turnDays); // optional metric

    return ListTile(
      isThreeLine: true,
      minVerticalPadding: 10,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            p.category.name.substring(0, 1),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(ctx).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${p.brand}${p.model == null || p.model!.isEmpty ? '' : ' • ${p.model}'}',
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Chip(
            label: Text(label),
            backgroundColor: color.withOpacity(0.12),
            labelStyle: TextStyle(color: color),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(height: 4),
          Text(
            'Sold (30d): $sold30d'
                '${turnRate != null ? ' • Turn: ${turnRate.toStringAsFixed(2)}x' : ''}',
          ),
        ],
      ),
    );
  }

  // ---------- Small helper ----------
  List<Widget> _intersperse(List<Widget> items, Widget separator) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) out.add(separator);
    }
    return out;
  }
}
