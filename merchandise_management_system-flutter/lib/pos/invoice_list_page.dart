// lib/pages/invoice_list_page.dart

import 'package:flutter/material.dart';
import 'package:merchandise_management_system/entity/invoice.dart';
import 'package:merchandise_management_system/service/invoice_service.dart';


class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  late Future<List<Invoice>> _invoicesFuture;
  final InvoiceService _invoiceService = InvoiceService();

  @override
  void initState() {
    super.initState();
    _invoicesFuture = _invoiceService.getAllInvoices();
  }

  // Add a method to refresh the list
  Future<void> _refreshInvoices() async {
    setState(() {
      _invoicesFuture = _invoiceService.getAllInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshInvoices,
          ),
        ],
      ),
      body: FutureBuilder<List<Invoice>>(
        future: _invoicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}. Check your API URL.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No invoices found.'));
          } else {
            // Data has been successfully loaded
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Invoice invoice = snapshot.data![index];
                return ListTile(
                  title: Text('Invoice #${invoice.invoiceNumber}'),
                  subtitle: Text(
                      'Client: ${invoice.name}\nTotal: \$${invoice.total.toStringAsFixed(2)}'),
                  trailing: Text('Paid: \$${invoice.paid.toStringAsFixed(2)}'),
                  onTap: () {
                    // Navigate to a detail page or show dialog
                    _showInvoiceDetails(context, invoice);
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a create new invoice page
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showInvoiceDetails(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice Details #${invoice.invoiceNumber}'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Client: ${invoice.name}'),
              Text('Email: ${invoice.email}'),
              Text('Subtotal: \$${invoice.subtotal.toStringAsFixed(2)}'),
              Text('Discount: \$${invoice.discount.toStringAsFixed(2)}'),
              Text('Tax Rate: ${invoice.taxRate.toStringAsFixed(2)}%'),
              Text('Total: \$${invoice.total.toStringAsFixed(2)}'),
              const Divider(),
              const Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
              // Simple product list
              ...invoice.products.map((p) => Text('${p.name} (${p.quantity} x \$${p.price.toStringAsFixed(2)})'))
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}