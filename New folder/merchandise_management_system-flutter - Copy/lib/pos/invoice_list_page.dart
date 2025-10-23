import 'package:flutter/material.dart';
import 'package:merchandise_management_system/models/invoice_model.dart';
import 'package:merchandise_management_system/pages/manager_page.dart';
import 'package:merchandise_management_system/pos/invoice_detail_page.dart';
import 'package:merchandise_management_system/service/invoice_service.dart';

enum InvoiceFilter { all, paid, unpaid }

class InvoiceListPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  const InvoiceListPage({super.key, required this.profile});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  final _service = InvoiceService();
  late Future<List<Invoice>> _future;

  InvoiceFilter _filter = InvoiceFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Start with an initial future without setState
    _future = _service.getAllInvoices();
  }

  void _fetch() {
    // kick off async work
    final fut = _service.getAllInvoices();
    // set state synchronously
    setState(() {
      _future = fut;
    });
  }

  Future<void> _refresh() async {
    final fut = _service.getAllInvoices();
    setState(() {
      _future = fut;
    });
    await fut; // await OUTSIDE setState
  }

  List<Invoice> _applyFilters(List<Invoice> src) {
    var list = switch (_filter) {
      InvoiceFilter.paid => src.where((i) => i.isPaid).toList(),
      InvoiceFilter.unpaid => src.where((i) => !i.isPaid).toList(),
      InvoiceFilter.all => src,
    };

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((i) {
        final s1 = i.name.toLowerCase().contains(q);
        final s2 = i.invoiceNumber.toLowerCase().contains(q);
        return s1 || s2;
      }).toList();
    }

    // newest first (by date if present, else id)
    list.sort((a, b) {
      final da = a.date?.millisecondsSinceEpoch ?? a.id ?? 0;
      final db = b.date?.millisecondsSinceEpoch ?? b.id ?? 0;
      return db.compareTo(da);
    });
    return list;
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  Color _statusColor(bool isPaid) => isPaid ? Colors.green : Colors.orange;
  String _statusText(bool isPaid) => isPaid ? 'Paid' : 'Unpaid';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to Manager',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => ManagerPage(profile: widget.profile)),
                  (r) => false,
            );
          },
        ),
        title: const Text('Invoices'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search by client or invoice number',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _query = ''),
                      tooltip: 'Clear',
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _filter == InvoiceFilter.all,
                      onSelected: (_) => setState(() => _filter = InvoiceFilter.all),
                    ),
                    ChoiceChip(
                      label: const Text('Paid'),
                      selected: _filter == InvoiceFilter.paid,
                      onSelected: (_) => setState(() => _filter = InvoiceFilter.paid),
                    ),
                    ChoiceChip(
                      label: const Text('Unpaid'),
                      selected: _filter == InvoiceFilter.unpaid,
                      onSelected: (_) => setState(() => _filter = InvoiceFilter.unpaid),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        // wrap to avoid passing Future-returning function directly
                        _refresh();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<Invoice>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 80),
                Center(child: Text('Error: ${snap.error}')),
              ],
            );
          }
          final data = _applyFilters(snap.data ?? []);
          if (data.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                Center(child: Text('No invoices found')),
              ],
            );
          }

          // quick summary
          final totalAmt = data.fold<double>(0, (a, b) => a + b.total);
          final paidAmt = data.fold<double>(0, (a, b) => a + b.paid);
          final dueAmt = totalAmt - paidAmt;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              itemCount: data.length + 1,
              itemBuilder: (context, idx) {
                if (idx == 0) {
                  // summary card
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          _summaryTile(context, 'Total', totalAmt),
                          _summaryTile(context, 'Paid', paidAmt),
                          _summaryTile(context, 'Due', dueAmt),
                        ],
                      ),
                    ),
                  );
                }

                final inv = data[idx - 1];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Invoice #${inv.invoiceNumber}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Chip(
                          label: Text(_statusText(inv.isPaid)),
                          backgroundColor: _statusColor(inv.isPaid).withOpacity(0.12),
                          labelStyle: TextStyle(color: _statusColor(inv.isPaid)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Client: ${inv.name}'),
                          Text('Date: ${_fmtDate(inv.date)}'),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _moneyPill(context, 'Total', inv.total),
                              const SizedBox(width: 8),
                              _moneyPill(context, 'Paid', inv.paid),
                              const SizedBox(width: 8),
                              _moneyPill(context, 'Due', inv.due),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => InvoiceDetailPage(
                            invoice: inv,
                            profile: widget.profile,
                          ),
                        ),
                      );
                    },

                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create invoice (from Cart/Checkout)',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('To create an invoice, use Checkout from the Cart.')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _summaryTile(BuildContext context, String label, double amount) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 4),
          Text(
            '৳ ${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _moneyPill(BuildContext context, String label, double amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: ৳ ${amount.toStringAsFixed(2)}'),
    );
  }

  void _openInvoiceDetails(BuildContext context, Invoice inv) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Invoice #${inv.invoiceNumber}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                    ),
                    Chip(
                      label: Text(_statusText(inv.isPaid)),
                      backgroundColor: _statusColor(inv.isPaid).withOpacity(0.12),
                      labelStyle: TextStyle(color: _statusColor(inv.isPaid)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Client: ${inv.name}'),
                if (inv.email != null && inv.email!.isNotEmpty) Text('Email: ${inv.email}'),
                if (inv.phone != null && inv.phone!.isNotEmpty) Text('Phone: ${inv.phone}'),
                Text('Date: ${_fmtDate(inv.date)}'),
                const Divider(height: 20),
                const Text('Items', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: inv.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (_, i) {
                      final it = inv.items[i];
                      final lineTotal = it.priceAtSale * it.quantity;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(it.productName),
                        subtitle: Text('Qty: ${it.quantity} • Unit: ৳ ${it.priceAtSale.toStringAsFixed(2)}'),
                        trailing: Text(
                          '৳ ${lineTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    _summaryTile(context, 'Subtotal', inv.subtotal),
                    _summaryTile(context, 'Discount', inv.discount),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _summaryTile(context, 'Total', inv.total),
                    _summaryTile(context, 'Paid', inv.paid),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Due: ৳ ${inv.due.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _statusColor(inv.isPaid),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
