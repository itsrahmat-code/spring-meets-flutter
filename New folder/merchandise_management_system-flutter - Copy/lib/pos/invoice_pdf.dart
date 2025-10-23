// lib/pos/invoice_pdf.dart
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'package:merchandise_management_system/models/invoice_model.dart';

class InvoicePdf {
  static final _currency = NumberFormat.currency(locale: 'en_US', symbol: '৳ ');

  static String _fmtMoney(double v) => _currency.format(v);
  static String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(d);
  }

  static Future<Uint8List> build(Invoice inv) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        build: (context) => [
          _header(inv),
          pw.SizedBox(height: 12),
          _party(inv),
          pw.SizedBox(height: 12),
          _items(inv),
          pw.Divider(),
          _totals(inv),
          pw.SizedBox(height: 20),
          _footer(),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.PageTheme _pageTheme() {
    return pw.PageTheme(
      margin: const pw.EdgeInsets.all(24),
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
    );
  }

  static pw.Widget _header(Invoice inv) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text('Invoice #: ${inv.invoiceNumber}', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Date: ${_fmtDate(inv.date)}', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Status: ${inv.isPaid ? "Paid" : "Unpaid"}', style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
        pw.Spacer(),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Your Shop Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Address line 1'),
            pw.Text('City, ZIP'),
            pw.Text('Phone: +880-0000-000000'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _party(Invoice inv) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bill To', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(inv.name),
                if ((inv.phone ?? '').isNotEmpty) pw.Text('Phone: ${inv.phone}'),
                if ((inv.email ?? '').isNotEmpty) pw.Text('Email: ${inv.email}'),
              ],
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Thank you for your purchase!'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _items(Invoice inv) {
    final headers = ['Item', 'Qty', 'Unit', 'Line Total'];
    final data = inv.items.map((it) {
      final lineTotal = it.priceAtSale * it.quantity;
      return [
        it.productName,
        it.quantity.toString(),
        _fmtMoney(it.priceAtSale),
        _fmtMoney(lineTotal),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      border: null,
      headerAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _totals(Invoice inv) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 280,
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: [
            _kv('Subtotal', _fmtMoney(inv.subtotal)),
            _kv('Discount', _fmtMoney(inv.discount)),
            pw.Divider(),
            _kv('Total', _fmtMoney(inv.total), bold: true),
            _kv('Paid', _fmtMoney(inv.paid)),
            pw.SizedBox(height: 6),
            _kv('Due', _fmtMoney(inv.total - inv.paid),
                bold: true,
                valueColor: inv.isPaid ? PdfColors.green800 : PdfColors.orange800),
          ],
        ),
      ),
    );
  }

  static pw.Widget _kv(String k, String v, {bool bold = false, PdfColor? valueColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(k)),
          pw.Text(
            v,
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer() {
    return pw.Center(
      child: pw.Text(
        'Generated by Merchandise Management System',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }
}
