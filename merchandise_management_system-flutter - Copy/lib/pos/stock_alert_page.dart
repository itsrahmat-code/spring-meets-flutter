import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:merchandise_management_system/service/stock_alert_service.dart';
import 'package:merchandise_management_system/models/product_model.dart';

class StockAlertPage extends StatelessWidget {
  const StockAlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<StockAlertService>();
    final lows = svc.lowStock..sort((a, b) => a.quantity.compareTo(b.quantity));
    final fulls = svc.fullStock..sort((a, b) => b.quantity.compareTo(a.quantity));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Alerts'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          _sectionHeader(context, 'Low stock', Icons.warning_amber, Colors.orange, lows.length),
          if (lows.isEmpty)
            _empty('No low-stock items 🎉')
          else
            ...lows.map((p) => _stockTile(context, p, isLow: true)),

          const SizedBox(height: 16),
          _sectionHeader(context, 'Stock full', Icons.inventory_2, Colors.green, fulls.length),
          if (fulls.isEmpty)
            _empty('No stock-full items')
          else
            ...fulls.map((p) => _stockTile(context, p, isLow: false)),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext ctx, String title, IconData icon, Color color, int count) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(ctx).textTheme.titleMedium),
        const SizedBox(width: 6),
        Chip(
          label: Text('$count'),
          backgroundColor: color.withOpacity(0.12),
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _empty(String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(msg, style: const TextStyle(color: Colors.black54)),
  );

  Widget _stockTile(BuildContext ctx, Product p, {required bool isLow}) {
    final color = isLow ? Colors.orange : Colors.green;
    final label = isLow ? 'Low' : 'Full';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${p.brand} • ${p.category.name}'),
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
      ),
    );
  }
}
