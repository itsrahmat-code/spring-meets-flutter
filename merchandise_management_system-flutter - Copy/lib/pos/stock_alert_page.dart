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
    final lows  = List<Product>.of(svc.lowStock)..sort((a, b) => a.quantity.compareTo(b.quantity));
    final fulls = List<Product>.of(svc.fullStock)..sort((a, b) => b.quantity.compareTo(a.quantity));

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
          title: const Text('Stock Alerts'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: () => svc.refresh(), // <-- calls the service method
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(36),
            child: _summaryBar(context, lows.length, fulls.length),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => svc.refresh(), // <-- pull-to-refresh
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
            children: [
              _sectionCard(
                context: context,
                title: 'Low stock',
                icon: Icons.warning_amber,
                color: Colors.orange,
                count: lows.length,
                emptyText: 'No low-stock items 🎉',
                children: lows.map((p) => _stockTile(context, p, isLow: true)).toList(),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                context: context,
                title: 'Stock full',
                icon: Icons.inventory_2,
                color: Colors.green,
                count: fulls.length,
                emptyText: 'No stock-full items',
                children: fulls.map((p) => _stockTile(context, p, isLow: false)).toList(),
              ),
            ],
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

  Widget _summaryBar(BuildContext ctx, int lowCount, int fullCount) {
    final onVar = Theme.of(ctx).colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          _summaryPill(ctx, 'Low', lowCount, Colors.orange),
          const SizedBox(width: 8),
          _summaryPill(ctx, 'Full', fullCount, Colors.green),
          const Spacer(),
          Text('Total alerts: ${lowCount + fullCount}', style: TextStyle(color: onVar)),
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
            label == 'Low' ? Icons.warning_amber : Icons.inventory_2,
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                child: Text(emptyText, style: const TextStyle(color: Colors.black54)),
              )
            else
              ..._intersperse(children, const Divider(height: 0)),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext ctx, String title, IconData icon, Color color, int count) {
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
          child: Text(title, style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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

  Widget _stockTile(BuildContext ctx, Product p, {required bool isLow}) {
    final color = isLow ? Colors.orange : Colors.green;
    final label = isLow ? 'Low' : 'Full';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
      subtitle: Text('${p.brand}${p.model == null || p.model!.isEmpty ? '' : ' • ${p.model}'}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Chip(
            label: Text(label),
            backgroundColor: color.withOpacity(0.12),
            labelStyle: TextStyle(color: color),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(height: 4),
          Text('Qty: ${p.quantity}'),
        ],
      ),
    );
  }

  List<Widget> _intersperse(List<Widget> items, Widget separator) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) out.add(separator);
    }
    return out;
  }
}
