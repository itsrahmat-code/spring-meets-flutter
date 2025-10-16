// invoice_page.dart

import 'package:flutter/material.dart';

import '../entity/invoice.dart';
import '../service/invoice_service.dart';


class InvoicePage extends StatefulWidget {
  const InvoicePage({Key? key}) : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final InvoiceService _invoiceService = InvoiceService();
  late Future<List<Invoice>> _invoiceList;

  @override
  void initState() {
    super.initState();
    _invoiceList = _invoiceService.fetchAllInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
      ),
      body: FutureBuilder<List<Invoice>>(
        future: _invoiceList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final invoices = snapshot.data!;
          if (invoices.isEmpty) {
            return const Center(child: Text('No invoices found'));
          }

          return ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                child: ListTile(
                  title: Text(invoice.name ?? 'No Name'),
                  subtitle: Text('Total: ${invoice.total.toStringAsFixed(2)}'),
                  trailing: Text('Due: ${invoice.due.toStringAsFixed(2)}'),
                  onTap: () {
                    // Navigate to detail or edit page
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Create Invoice form
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
