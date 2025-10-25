import 'package:flutter/material.dart';
import 'package:merchandise_management_system/models/supplier_model.dart';
import 'package:merchandise_management_system/service/supplier_api_service.dart';
import 'package:merchandise_management_system/pages/manager_page.dart';

import 'supplier_add_page.dart';

class SupplierListPage extends StatefulWidget {
  final SupplierApiService api;
  final Map<String, dynamic>? profile;

  const SupplierListPage({
    super.key,
    required this.api,
    this.profile,
  });

  @override
  State<SupplierListPage> createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage> {
  final List<Supplier> _items = [];
  final List<Supplier> _filtered = [];
  final _searchCtrl = TextEditingController();

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchSuppliers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.api.fetchSuppliers();
      setState(() {
        _items
          ..clear()
          ..addAll(data);
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    _filtered
      ..clear()
      ..addAll(
        _items.where((s) {
          final company = (s.companyName ?? '').toLowerCase();
          final contact = (s.contactPerson ?? '').toLowerCase();
          final phone = (s.phone ?? '').toLowerCase();
          final email = (s.email ?? '').toLowerCase();
          return q.isEmpty ||
              company.contains(q) ||
              contact.contains(q) ||
              phone.contains(q) ||
              email.contains(q);
        }),
      );
    setState(() {});
  }

  Future<void> _reload() => _fetchSuppliers();

  Future<void> _goToAdd() async {
    final Supplier? created = await Navigator.of(context).push<Supplier>(
      MaterialPageRoute(builder: (_) => SupplierAddPage(api: widget.api)),
    );
    if (created != null) {
      setState(() {
        _items.insert(0, created);
        _applyFilter();
      });
    }
  }

  void _goBackToManagerHard() {
    final profile = widget.profile ?? <String, dynamic>{};
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => ManagerPage(profile: profile)),
          (route) => false,
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ----------------- UI -----------------

  Widget _card(Supplier s) {
    final company = s.companyName ?? '(No company name)';
    final contact = s.contactPerson ?? '';
    final phone = s.phone ?? '';
    final email = s.email ?? '';
    final address = s.address ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(child: Icon(Icons.factory)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    company,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // (Email icon removed)
              ],
            ),

            const SizedBox(height: 6),

            // Body info chips (no actions)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if ((contact).isNotEmpty)
                  Chip(
                    label: Text('Contact: $contact'),
                    avatar: const Icon(Icons.person, size: 18),
                  ),
                if ((phone).isNotEmpty)
                  Chip(
                    label: Text(phone),
                    avatar: const Icon(Icons.call, size: 18),
                  ),
                if ((email).isNotEmpty)
                  Chip(
                    label: Text(email),
                    avatar: const Icon(Icons.alternate_email, size: 18),
                  ),
              ],
            ),

            if (address.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.place_outlined, size: 18),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 6),

            // Footer actions removed (Send Mail / Call)
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.error,
              color: Theme.of(context).colorScheme.error, size: 48),
          const SizedBox(height: 12),
          Center(child: Text('Error: $_error')),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ],
      );
    }
    if (_filtered.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No suppliers found')),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _card(_filtered[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topBar = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search suppliers…',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: (_searchCtrl.text.isEmpty)
                  ? null
                  : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _searchCtrl.clear(),
              ),
            ),
          ),
        ),
      ],
    );

    return WillPopScope(
      onWillPop: () async {
        _goBackToManagerHard();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBackToManagerHard,
          ),
          title: const Text('Suppliers'),
          actions: [
            IconButton(
              tooltip: 'Add Supplier',
              onPressed: _goToAdd,
              icon: const Icon(Icons.person_add_alt_1),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _reload,
          child: Column(
            children: [
              topBar,
              Expanded(child: _body()),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _goToAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add Supplier'),
          tooltip: 'Add Supplier',
        ),
      ),
    );
  }
}
