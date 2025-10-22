import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import 'package:merchandise_management_system/service/cart_service.dart';
import 'package:merchandise_management_system/service/invoice_service.dart';
import 'package:merchandise_management_system/models/invoice_model.dart';
import 'package:merchandise_management_system/pos/invoice_pdf.dart';
import 'package:merchandise_management_system/pos/invoice_detail_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _discount = TextEditingController(text: '0');
  final _paid = TextEditingController();

  bool _submitting = false;
  final _invoiceService = InvoiceService();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _discount.dispose();
    _paid.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartService>();
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final discount = double.tryParse(_discount.text.trim()) ?? 0.0;
      final paid = double.tryParse(_paid.text.trim()) ?? 0.0;

      // Create on server
      final resp = await _invoiceService.createInvoice(
        name: _name.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        discount: discount,
        paid: paid,
        items: cart.items, // List<CartLine>
      );

      // Parse the created invoice back into your model.
      // Assumes you have Invoice.fromJson. If not, add it to your invoice_model.dart.
      final created = Invoice.fromJson(resp);

      // Clear cart after success
      cart.clear();

      if (!mounted) return;

      // Show success actions: Preview / Share / Print / View details / Done
      _showSuccessSheet(context, created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create invoice failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ---- Success bottom sheet with PDF actions ----
  void _showSuccessSheet(BuildContext context, Invoice inv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 40),
                const SizedBox(height: 8),
                Text(
                  'Invoice #${inv.invoiceNumber} created',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text('Total: ৳ ${inv.total.toStringAsFixed(2)}'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Preview'),
                        onPressed: () => _openPreview(context, inv),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Share/Download'),
                        onPressed: () => _sharePdf(context, inv),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.print),
                        label: const Text('Print'),
                        onPressed: () => _printPdf(context, inv),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('View details'),
                        onPressed: () {
                          Navigator.of(context).pop(); // close sheet
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => InvoiceDetailPage(
                                invoice: inv,
                                profile: const {}, // pass profile if you have it here
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close sheet
                    Navigator.of(context).popUntil((route) => route.isFirst); // back to home/list
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- PDF helpers (Preview / Share / Print) ----

  Future<Uint8List> _buildPdf(Invoice inv) => InvoicePdf.build(inv);

  Future<void> _openPreview(BuildContext context, Invoice inv) async {
    try {
      // pre-build to catch exceptions
      await _buildPdf(inv);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PreviewScaffold(
            title: 'Preview • #${inv.invoiceNumber}',
            suggestedName: 'invoice_${inv.invoiceNumber}.pdf',
            buildPdf: () => _buildPdf(inv),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preview failed: $e')),
      );
    }
  }

  Future<void> _sharePdf(BuildContext context, Invoice inv) async {
    try {
      final bytes = await _buildPdf(inv);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'invoice_${inv.invoiceNumber}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed: $e')),
      );
    }
  }

  Future<void> _printPdf(BuildContext context, Invoice inv) async {
    try {
      await Printing.layoutPdf(onLayout: (format) => _buildPdf(inv));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = context.select<CartService, double>((c) => c.totalAmount);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Cart total: ৳ ${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Customer Name *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: _discount,
                decoration: const InputDecoration(labelText: 'Discount'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _paid,
                decoration: const InputDecoration(labelText: 'Paid'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final paid = double.tryParse(v ?? '') ?? 0.0;
                  if (paid < 0) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.send),
                label: const Text('Create Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tiny page to host PdfPreview with a normal AppBar.
/// Works across mobile/web/desktop. On web, users can download from Preview.
class _PreviewScaffold extends StatelessWidget {
  final String title;
  final String suggestedName;
  final Future<Uint8List> Function() buildPdf;

  const _PreviewScaffold({
    required this.title,
    required this.suggestedName,
    required this.buildPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: (format) => buildPdf(),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: suggestedName,
      ),
    );
  }
}
