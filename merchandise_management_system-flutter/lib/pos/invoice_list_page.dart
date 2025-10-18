// File: lib/pos/invoice_list_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../entity/invoice.dart';
import '../service/invoice_service.dart';
import 'add_invoice.dart';


class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  late Future<List<InvoiceModel>> _invoicesFuture;
  final InvoiceService _invoiceService = InvoiceService();

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  void _fetchInvoices() {
    setState(() {
      _invoicesFuture = _invoiceService.getAllInvoices();
    });
  }

  void _navigateToAddInvoice() async {
    // Navigate to Add Invoice Page and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InvoiceAddPage()),
    );

    // If result is true (invoice created successfully), refresh the list
    if (result == true) {
      _fetchInvoices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Invoices'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchInvoices,
          ),
        ],
      ),
      body: FutureBuilder<List<InvoiceModel>>(
        future: _invoicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading invoices: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No invoices found.'));
          } else {
            final invoices = snapshot.data!;
            return ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];

                // Determine color for Due amount
                Color dueColor = invoice.due > 0 ? Colors.red : (invoice.due < 0 ? Colors.blue : Colors.green);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        '#${invoice.id}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    title: Text(
                      invoice.invoiceNumber ?? 'Invoice N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer: ${invoice.customerName}'),
                        Text(
                          'Date: ${DateFormat('MMM d, yyyy h:mm a').format(invoice.date ?? DateTime.now())}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('\$${invoice.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Due: \$${invoice.due.abs().toStringAsFixed(2)}', style: TextStyle(color: dueColor, fontSize: 14)),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigate to Invoice Detail Page
                      print('Tapped on invoice: ${invoice.id}');
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddInvoice,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }
}