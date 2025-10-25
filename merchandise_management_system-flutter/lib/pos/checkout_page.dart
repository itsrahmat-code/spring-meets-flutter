import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchandise_management_system/pages/manager_page.dart';
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

  final _invoiceService = InvoiceService();
  bool _submitting = false;

  // Focus order
  final _fEmail = FocusNode();
  final _fPhone = FocusNode();
  final _fDiscount = FocusNode();
  final _fPaid = FocusNode();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _discount.dispose();
    _paid.dispose();
    _fEmail.dispose();
    _fPhone.dispose();
    _fDiscount.dispose();
    _fPaid.dispose();
    super.dispose();
  }

  String _tk(num v) => '৳ ${v.toStringAsFixed(2)}';
  double _parseMoney(String v) => double.tryParse(v.trim().replaceAll(',', '')) ?? 0.0;

  ({double subtotal, double discount, double paid, double grandTotal, double due, double change})
  _computeTotals(BuildContext context) {
    final subtotal = context.select<CartService, double>((c) => c.totalAmount);
    final discount = _parseMoney(_discount.text);
    final paid = _parseMoney(_paid.text);
    final grandTotal = (subtotal - discount).clamp(0.0, double.infinity);
    final due = (grandTotal - paid).clamp(0.0, double.infinity);
    final change = (paid - grandTotal).clamp(0.0, double.infinity);
    return (
    subtotal: subtotal,
    discount: discount,
    paid: paid,
    grandTotal: grandTotal,
    due: due,
    change: change
    );
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
      final discount = _parseMoney(_discount.text);
      final paid = _parseMoney(_paid.text);

      final resp = await _invoiceService.createInvoice(
        name: _name.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        discount: discount,
        paid: paid,
        items: cart.items,
      );

      final created = Invoice.fromJson(resp);
      cart.clear();
      if (!mounted) return;

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

  void _showSuccessSheet(BuildContext rootContext, Invoice inv) {
    showModalBottomSheet(
      context: rootContext,
      isScrollControlled: false,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text('Total: ${_tk(inv.total)}'),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Preview'),
                        onPressed: () => _openPreview(rootContext, inv),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Share/Download'),
                        onPressed: () => _sharePdf(rootContext, inv),
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
                        onPressed: () => _printPdf(rootContext, inv),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('View details'),
                        onPressed: () {
                          Navigator.of(sheetContext).pop(); // close sheet
                          Navigator.of(rootContext).push(
                            MaterialPageRoute(
                              builder: (_) => InvoiceDetailPage(
                                invoice: inv,
                                profile: const {},
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
                    Navigator.of(sheetContext).pop(); // close sheet
                    Navigator.of(rootContext).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const ManagerPage(profile: {}),
                      ),
                          (route) => false,
                    );
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

  Future<Uint8List> _buildPdf(Invoice inv) => InvoicePdf.build(inv);

  Future<void> _openPreview(BuildContext context, Invoice inv) async {
    try {
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
      await Printing.sharePdf(bytes: bytes, filename: 'invoice_${inv.invoiceNumber}.pdf');
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

  InputDecoration _fieldDecoration(String label, {Widget? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsCount = context.select<CartService, int>((c) => c.items.length);
    final totals = _computeTotals(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                onChanged: () => setState(() {}), // live totals refresh
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$itemsCount item${itemsCount == 1 ? '' : 's'} • Subtotal ${_tk(totals.subtotal)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Customer info
                    Text('Customer', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _name,
                              textInputAction: TextInputAction.next,
                              decoration: _fieldDecoration('Customer Name *', prefix: const Icon(Icons.person_outline)),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _email,
                              focusNode: _fEmail,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _fieldDecoration('Email', prefix: const Icon(Icons.email_outlined)),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phone,
                              focusNode: _fPhone,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                              decoration: _fieldDecoration('Phone', prefix: const Icon(Icons.phone_outlined)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payment
                    Text('Payment', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _discount,
                              focusNode: _fDiscount,
                              textInputAction: TextInputAction.next,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
                              decoration: _fieldDecoration('Discount', prefix: const Icon(Icons.percent)),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _paid,
                              focusNode: _fPaid,
                              textInputAction: TextInputAction.done,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
                              decoration: _fieldDecoration('Paid', prefix: const Icon(Icons.payments_outlined)),
                              validator: (v) {
                                final paid = _parseMoney(v ?? '');
                                if (paid < 0) return 'Invalid amount';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Totals
                    Text('Totals', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _totalRow('Subtotal', _tk(totals.subtotal)),
                            _totalRow('Discount', '- ${_tk(totals.discount)}'),
                            const Divider(),
                            _totalRow('Grand Total', _tk(totals.grandTotal), isEmphasis: true),
                            const SizedBox(height: 6),
                            _totalRow('Paid', _tk(totals.paid)),
                            const SizedBox(height: 2),
                            if (totals.due > 0)
                              _pillRow(Icons.error_outline, 'Due', _tk(totals.due), context, color: Colors.orange)
                            else
                              _pillRow(Icons.check_circle_outline, 'Change', _tk(totals.change), context, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 120), // space for bottom bar
                  ],
                ),
              ),
            ),
          ),

          // Sticky bottom bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.receipt_long),
                    label: const Text('Create Invoice'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool isEmphasis = false}) {
    final style = isEmphasis
        ? const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)
        : const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _pillRow(IconData icon, String label, String value, BuildContext context, {required Color color}) {
    final bg = color.withOpacity(0.12);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

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
