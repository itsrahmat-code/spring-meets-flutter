// lib/others_page/add_expense_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchandise_management_system/models/expense_model.dart';
import 'package:merchandise_management_system/service/expense_service.dart';

// ⬇️ Import ManagerPage so we can navigate back there
import 'package:merchandise_management_system/pages/manager_page.dart';

class AddExpensePage extends StatefulWidget {
  final ExpenseService service;
  final Expense? initial; // if provided -> edit mode
  final Map<String, dynamic> profile;

  const AddExpensePage({
    super.key,
    required this.service,
    required this.profile,
    this.initial,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _descriptionCtl = TextEditingController();
  final _amountCtl = TextEditingController();
  final _addedByCtl = TextEditingController();
  DateTime _date = DateTime.now();

  bool get isEdit => widget.initial != null;

  String _deriveAddedByFromProfile(Map<String, dynamic> p) {
    // Adjust to match your profile shape
    // Try a few common fields: name, username, email
    final name = (p['name'] ?? p['fullName'] ?? p['username'])?.toString();
    if (name != null && name.trim().isNotEmpty) return name.trim();

    final email = p['email']?.toString();
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return ''; // fallback
  }

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final e = widget.initial!;
      _date = e.date;
      _titleCtl.text = e.title;
      _descriptionCtl.text = e.description ?? '';
      _amountCtl.text = e.amount.toString();
      _addedByCtl.text = e.addedBy ?? _deriveAddedByFromProfile(widget.profile);
    } else {
      // Pre-fill from profile for convenience on create
      _addedByCtl.text = _deriveAddedByFromProfile(widget.profile);
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _descriptionCtl.dispose();
    _amountCtl.dispose();
    _addedByCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be a positive number')),
      );
      return;
    }

    final expense = Expense(
      id: isEdit ? widget.initial!.id : null,
      date: _date,
      title: _titleCtl.text.trim(),
      description: _descriptionCtl.text.trim().isEmpty ? null : _descriptionCtl.text.trim(),
      amount: amount,
      addedBy: _addedByCtl.text.trim().isEmpty ? null : _addedByCtl.text.trim(),
    );

    try {
      if (isEdit) {
        final updated = await widget.service.update(expense.id!, expense);
        if (updated == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense not found (404)')),
            );
          }
          return;
        }
      } else {
        await widget.service.create(expense);
      }

      // ✅ After successful save, go to ManagerPage
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ManagerPage(profile: widget.profile)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  void _goBackToManager() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ManagerPage(profile: widget.profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd');

    return WillPopScope(
      // ✅ Intercept Android system back to go to ManagerPage
      onWillPop: () async {
        _goBackToManager();
        return false; // prevent default pop
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Edit Expense' : 'Add Expense'),
          // ✅ Back arrow to ManagerPage
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBackToManager,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Date
                Row(
                  children: [
                    Expanded(
                      child: Text('Date: ${df.format(_date)}', style: const TextStyle(fontSize: 16)),
                    ),
                    TextButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.date_range),
                      label: const Text('Pick'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                TextFormField(
                  controller: _titleCtl,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 255,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Title is required';
                    if (v.trim().length > 255) return 'Max 255 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Description
                TextFormField(
                  controller: _descriptionCtl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 1000,
                ),
                const SizedBox(height: 12),

                // Amount
                TextFormField(
                  controller: _amountCtl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Amount is required';
                    final val = double.tryParse(v.trim());
                    if (val == null) return 'Enter a valid number';
                    if (val <= 0) return 'Amount must be > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Added By
                TextFormField(
                  controller: _addedByCtl,
                  decoration: const InputDecoration(
                    labelText: 'Added By',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 255,
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(isEdit ? 'Update' : 'Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
