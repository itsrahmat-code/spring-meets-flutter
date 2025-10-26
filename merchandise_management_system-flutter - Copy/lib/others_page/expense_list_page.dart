// lib/pages/expense_list_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchandise_management_system/models/expense_model.dart';
import 'package:merchandise_management_system/others_page/add_expense_page.dart';
import 'package:merchandise_management_system/service/expense_service.dart';

// Back to ManagerPage
import 'package:merchandise_management_system/pages/manager_page.dart';

class ExpenseListPage extends StatefulWidget {
  final ExpenseService service;
  final Map<String, dynamic> profile;

  const ExpenseListPage({
    super.key,
    required this.service,
    required this.profile,
  });

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  late Future<List<Expense>> _future;
  List<Expense> _all = [];

  final _df = DateFormat('yyyy-MM-dd');
  final _cf = NumberFormat('#,##0.00');

  // Search / Filter state
  String _query = '';
  DateTime? _from;
  DateTime? _to;
  double? _minAmount;
  double? _maxAmount;
  bool _onlyMine = false;
  String _sort = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc

  final _searchCtl = TextEditingController();
  final _minCtl = TextEditingController();
  final _maxCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Expense>> _load() async {
    final items = await widget.service.getAll();
    _all = items;
    return items;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _delete(Expense e) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${e.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final ok = await widget.service.delete(e.id!);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
        _refresh();
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $err')));
      }
    }
  }

  Future<void> _openAdd() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddExpensePage(
          service: widget.service,
          profile: widget.profile,
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  Future<void> _openEdit(Expense e) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddExpensePage(
          service: widget.service,
          profile: widget.profile,
          initial: e,
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  void _goBackToManager() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ManagerPage(profile: widget.profile)),
    );
  }

  // Apply client-side filtering & sorting
  List<Expense> _filtered(List<Expense> src) {
    final nameGuess = (widget.profile['name'] ??
        widget.profile['fullName'] ??
        widget.profile['username'] ??
        (widget.profile['email']?.toString().split('@').first))
        ?.toString()
        .toLowerCase();

    Iterable<Expense> it = src;

    // search query
    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      it = it.where((e) =>
      e.title.toLowerCase().contains(q) ||
          (e.description ?? '').toLowerCase().contains(q) ||
          (e.addedBy ?? '').toLowerCase().contains(q));
    }

    // date range
    if (_from != null) {
      it = it.where((e) => !e.date.isBefore(DateTime(_from!.year, _from!.month, _from!.day)));
    }
    if (_to != null) {
      final end = DateTime(_to!.year, _to!.month, _to!.day, 23, 59, 59, 999);
      it = it.where((e) => !e.date.isAfter(end));
    }

    // amount range
    if (_minAmount != null) it = it.where((e) => e.amount >= _minAmount!);
    if (_maxAmount != null) it = it.where((e) => e.amount <= _maxAmount!);

    // only mine
    if (_onlyMine && (nameGuess != null && nameGuess.isNotEmpty)) {
      it = it.where((e) => (e.addedBy ?? '').toLowerCase().contains(nameGuess));
    }

    final list = it.toList();

    // sort
    switch (_sort) {
      case 'date_asc':
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_desc':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_asc':
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'date_desc':
      default:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
    }
    return list;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDateRange: (_from != null && _to != null)
          ? DateTimeRange(start: _from!, end: _to!)
          : null,
    );
    if (range != null) {
      setState(() {
        _from = DateTime(range.start.year, range.start.month, range.start.day);
        _to = DateTime(range.end.year, range.end.month, range.end.day);
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _query = '';
      _searchCtl.clear();
      _from = null;
      _to = null;
      _minAmount = null;
      _maxAmount = null;
      _minCtl.clear();
      _maxCtl.clear();
      _onlyMine = false;
      _sort = 'date_desc';
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date range
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date Range'),
                subtitle: Text(
                  (_from == null && _to == null)
                      ? 'Any time'
                      : '${_from != null ? _df.format(_from!) : '...'}  →  ${_to != null ? _df.format(_to!) : '...'}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _pickDateRange,
                ),
              ),
              const SizedBox(height: 8),

              // Amount range
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minCtl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Min Amount',
                        border: OutlineInputBorder(),
                        prefixText: '৳ ',
                      ),
                      onChanged: (v) {
                        setState(() {
                          _minAmount = double.tryParse(v.trim());
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maxCtl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Max Amount',
                        border: OutlineInputBorder(),
                        prefixText: '৳ ',
                      ),
                      onChanged: (v) {
                        setState(() {
                          _maxAmount = double.tryParse(v.trim());
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Only mine
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Only my entries'),
                value: _onlyMine,
                onChanged: (v) => setState(() => _onlyMine = v),
              ),
              const SizedBox(height: 8),

              // Sort
              Row(
                children: [
                  const Text('Sort by:'),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _sort,
                    items: const [
                      DropdownMenuItem(value: 'date_desc', child: Text('Date ↓ (newest)')),
                      DropdownMenuItem(value: 'date_asc', child: Text('Date ↑ (oldest)')),
                      DropdownMenuItem(value: 'amount_desc', child: Text('Amount ↓ (high)')),
                      DropdownMenuItem(value: 'amount_asc', child: Text('Amount ↑ (low)')),
                    ],
                    onChanged: (v) => setState(() => _sort = v ?? 'date_desc'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Apply'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard(List<Expense> items) {
    final total = items.fold<double>(0.0, (sum, e) => sum + e.amount);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.summarize),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Total: ${_cf.format(total)}  •  Entries: ${items.length}',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: _openFilterSheet,
              icon: const Icon(Icons.filter_alt),
              label: const Text('Filters'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _minCtl.dispose();
    _maxCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.profile['name'] ?? widget.profile['username'] ?? 'User').toString();

    return WillPopScope(
      onWillPop: () async {
        _goBackToManager();
        return false; // prevent default pop
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Expenses — $name'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBackToManager,
          ),
          actions: [
            IconButton(
              tooltip: 'Filters',
              icon: const Icon(Icons.filter_list),
              onPressed: _openFilterSheet,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add Expense'),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Expense>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              }

              final items = _filtered(snap.data ?? []);

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  // Search field
                  TextField(
                    controller: _searchCtl,
                    decoration: InputDecoration(
                      hintText: 'Search title, description, added by…',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: (_query.isEmpty)
                          ? null
                          : IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _query = '';
                            _searchCtl.clear();
                          });
                        },
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 12),

                  // Active filter chips (preview)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_from != null || _to != null)
                        InputChip(
                          avatar: const Icon(Icons.date_range, size: 18),
                          label: Text(
                            '${_from != null ? _df.format(_from!) : '...'} → ${_to != null ? _df.format(_to!) : '...'}',
                          ),
                          onDeleted: () => setState(() {
                            _from = null;
                            _to = null;
                          }),
                        ),
                      if (_minAmount != null)
                        InputChip(
                          avatar: const Icon(Icons.trending_up, size: 18),
                          label: Text('Min ৳${_cf.format(_minAmount)}'),
                          onDeleted: () => setState(() => _minAmount = null),
                        ),
                      if (_maxAmount != null)
                        InputChip(
                          avatar: const Icon(Icons.trending_down, size: 18),
                          label: Text('Max ৳${_cf.format(_maxAmount)}'),
                          onDeleted: () => setState(() => _maxAmount = null),
                        ),
                      if (_onlyMine)
                        InputChip(
                          avatar: const Icon(Icons.person, size: 18),
                          label: const Text('Only my entries'),
                          onDeleted: () => setState(() => _onlyMine = false),
                        ),
                      if (_sort != 'date_desc')
                        InputChip(
                          avatar: const Icon(Icons.sort, size: 18),
                          label: Text(_sort == 'date_asc'
                              ? 'Sort: Date ↑'
                              : _sort == 'amount_desc'
                              ? 'Sort: Amount ↓'
                              : 'Sort: Amount ↑'),
                          onDeleted: () => setState(() => _sort = 'date_desc'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  _summaryCard(items),
                  const SizedBox(height: 8),

                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long, size: 56, color: Colors.grey.shade500),
                          const SizedBox(height: 12),
                          Text(
                            _query.isEmpty && _from == null && _to == null && _minAmount == null && _maxAmount == null && !_onlyMine
                                ? 'No expenses yet'
                                : 'No results. Try adjusting your filters.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  else
                    ...items.map((e) => _ExpenseCard(
                      expense: e,
                      df: _df,
                      cf: _cf,
                      onTap: () => _openEdit(e),
                      onDelete: () => _delete(e),
                    )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.df,
    required this.cf,
    required this.onTap,
    required this.onDelete,
  });

  final Expense expense;
  final DateFormat df;
  final NumberFormat cf;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                child: Text(
                  expense.title.isNotEmpty ? expense.title[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & amount
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            expense.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '৳ ${cf.format(expense.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${df.format(expense.date)} • ${(expense.description ?? '-')}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          expense.addedBy ?? '—',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
