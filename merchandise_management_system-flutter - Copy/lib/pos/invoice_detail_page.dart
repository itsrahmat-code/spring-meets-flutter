// lib/pos/invoice_detail_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'package:merchandise_management_system/models/invoice_model.dart';
import 'package:merchandise_management_system/pos/invoice_pdf.dart';

class InvoiceDetailPage extends StatelessWidget {
  final Invoice invoice;
  final Map<String, dynamic> profile;

  const InvoiceDetailPage({
    super.key,
    required this.invoice,
    required this.profile,
  });

  String _fmtMoney(double v) => '৳ ${v.toStringAsFixed(2)}';
  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    String two(int x) => x.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  Future<Uint8List> _buildPdf() => InvoicePdf.build(invoice);

  Future<void> _openPreview(BuildContext context) async {
    try {
      // Build once to catch any errors early
      await _buildPdf();
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InvoicePreviewPage(
            title: 'Preview • #${invoice.invoiceNumber}',
            buildPdf: () => _buildPdf(),
            suggestedName: 'invoice_${invoice.invoiceNumber}.pdf',
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preview failed: $e')),
        );
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final bytes = await _buildPdf();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'invoice_${invoice.invoiceNumber}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  Future<void> _printPdf(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) => _buildPdf(),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = invoice.isPaid ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${invoice.invoiceNumber}'),
        actions: [
          IconButton(
            tooltip: 'Preview PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _openPreview(context),
          ),
          IconButton(
            tooltip: 'Share PDF',
            icon: const Icon(Icons.share),
            onPressed: () => _sharePdf(context),
          ),
          IconButton(
            tooltip: 'Print',
            icon: const Icon(Icons.print),
            onPressed: () => _printPdf(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Client: ${invoice.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Chip(
                label: Text(invoice.isPaid ? 'Paid' : 'Unpaid'),
                backgroundColor: statusColor.withOpacity(0.12),
                labelStyle: TextStyle(color: statusColor),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Invoice #: ${invoice.invoiceNumber}'),
          Text('Date: ${_fmtDate(invoice.date)}'),
          if ((invoice.email ?? '').isNotEmpty) Text('Email: ${invoice.email}'),
          if ((invoice.phone ?? '').isNotEmpty) Text('Phone: ${invoice.phone}'),
          const SizedBox(height: 12),
          const Divider(),

          // Items
          const Text('Items', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          ...invoice.items.map((it) {
            final line = it.priceAtSale * it.quantity;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(it.productName),
              subtitle: Text('Qty: ${it.quantity} • Unit: ${_fmtMoney(it.priceAtSale)}'),
              trailing: Text(_fmtMoney(line), style: const TextStyle(fontWeight: FontWeight.w700)),
            );
          }),

          const Divider(),
          // Totals
          Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _kv('Subtotal', _fmtMoney(invoice.subtotal)),
                      _kv('Discount', _fmtMoney(invoice.discount)),
                      const Divider(height: 18),
                      _kv('Total', _fmtMoney(invoice.total), bold: true),
                      _kv('Paid', _fmtMoney(invoice.paid)),
                      const SizedBox(height: 6),
                      _kv('Due', _fmtMoney(invoice.total - invoice.paid),
                          bold: true, color: statusColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action buttons (secondary)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Preview'),
                  onPressed: () => _openPreview(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  onPressed: () => _sharePdf(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                  onPressed: () => _printPdf(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          Text(
            v,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// A dedicated page wrapping PdfPreview with minimal chrome.
/// This keeps preview simple and avoids nested async issues.
class InvoicePreviewPage extends StatelessWidget {
  final String title;
  final Future<Uint8List> Function() buildPdf;
  final String suggestedName;

  const InvoicePreviewPage({
    super.key,
    required this.title,
    required this.buildPdf,
    required this.suggestedName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: (format) => buildPdf(),
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: suggestedName,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}
