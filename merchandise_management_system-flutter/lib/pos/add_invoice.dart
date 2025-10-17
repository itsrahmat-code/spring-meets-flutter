import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../entity/invoice.dart';
import '../service/cart_service.dart';
import '../service/invoice_service.dart';
import '../entity/product.dart'; // Import Product to access details

class AddInvoicePage extends StatefulWidget {
  const AddInvoicePage({super.key});

  @override
  State<AddInvoicePage> createState() => _AddInvoicePageState();
}

class _AddInvoicePageState extends State<AddInvoicePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _discountController = TextEditingController(text: '0.00');
  final _paidController = TextEditingController();

  final InvoiceService _invoiceService = InvoiceService();
  final double _taxRate = 5.0;

  double _discount = 0.0;
  double _paid = 0.0;
  bool _isLoading = false;
  Invoice? _invoiceResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalculate();
    });
    _discountController.addListener(_recalculate);
    _paidController.addListener(() {
      setState(() {
        _paid = double.tryParse(_paidController.text) ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _discountController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  void _recalculate() {
    // Listen must be false in non-build methods
    final cart = Provider.of<CartService>(context, listen: false);
    setState(() {
      _discount = double.tryParse(_discountController.text) ?? 0.0;
      final subtotal = cart.subtotal;
      final taxedBase = subtotal - _discount;
      final taxAmt = taxedBase * (_taxRate / 100.0);
      final total = taxedBase + taxAmt;

      // Only pre-fill paid amount if it's currently empty or zero
      if (_paidController.text.isEmpty || _paidController.text == '0.00') {
        _paidController.text = total.toStringAsFixed(2);
      }
      _paid = double.tryParse(_paidController.text) ?? 0.0;
    });
  }

  Future<void> _completeSell() async {
    final cart = Provider.of<CartService>(context, listen: false);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty. Please add items.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final subtotal = cart.subtotal;
      final taxedBase = subtotal - _discount;
      final taxAmt = taxedBase * (_taxRate / 100.0);
      final total = taxedBase + taxAmt;
      _paid = double.tryParse(_paidController.text) ?? 0.0;

      if (_paid < total) {
        throw Exception('Paid amount is less than total.');
      }

      // Prepare invoice items
      final items = cart.items.map((p) {
        // p.id should not be null, but you may add null-check
        return InvoiceProductItem(productId: p.id!, quantity: p.quantity);
      }).toList();

      final invoice = await _invoiceService.createInvoice(
        customerName: _nameController.text.trim().isEmpty
            ? 'Guest Customer'
            : _nameController.text.trim(),
        customerEmail: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        customerPhone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        customerAddress: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        subtotal: subtotal,
        discount: _discount,
        taxRate: _taxRate,
        taxAmount: taxAmt,
        total: total,
        paid: _paid,
        items: items,
      );

      setState(() {
        _invoiceResult = invoice;
        _isLoading = false;
      });

      cart.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice created: ${invoice.id}')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _downloadPdf() {
    if (_invoiceResult == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
        Text('Downloading PDF for Invoice ${_invoiceResult!.id} (not implemented)'),
      ),
    );
  }

  // --- UI Helper for Input Fields ---
  Widget _buildField(
      TextEditingController ctrl, String label, IconData icon, TextInputType type,
      {bool optional = false, bool isEmail = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: optional ? '$label (Optional)' : '$label',
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.teal, width: 2.0),
        ),
      ),
    );
  }

  // --- UI Helper for Summary Rows ---
  Widget _buildSummaryRow(String label, double val,
      {bool isInput = false, TextEditingController? ctrl, bool bold = false, Color? color}) {
    final textStyle = TextStyle(
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: color ?? Colors.black,
        fontSize: bold ? 18 : 16);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          isInput && ctrl != null
              ? SizedBox(
            width: 120,
            child: TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                prefixText: '\$',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: textStyle,
            ),
          )
              : Text(
            '\$${val.toStringAsFixed(2)}',
            style: textStyle,
          ),
        ],
      ),
    );
  }

  // --- NEW UI Helper for Product Details ---
  Widget _buildProductDetailCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
            ),
            const Divider(height: 8, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Qty: ${product.quantity}', style: const TextStyle(fontStyle: FontStyle.italic)),
                Text('Unit Price: \$${product.price.toStringAsFixed(2)}'),
                Text('Line Total: \$${product.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (product.details != null && product.details!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Details: ${product.details}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final subtotal = cart.subtotal;
    final taxedBase = subtotal - _discount;
    final taxAmt = taxedBase * (_taxRate / 100.0);
    final total = taxedBase + taxAmt;
    final due = total - _paid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout / Invoice'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _invoiceResult != null
            ? _buildResultView()
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Customer Info ---
            const Text('Customer Info',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildField(_nameController, 'Name', Icons.person, TextInputType.name),
                    const SizedBox(height: 10),
                    _buildField(
                        _emailController, 'Email', Icons.email, TextInputType.emailAddress,
                        optional: true),
                    const SizedBox(height: 10),
                    _buildField(
                        _phoneController, 'Phone', Icons.phone, TextInputType.phone,
                        optional: true),
                    const SizedBox(height: 10),
                    _buildField(_addressController, 'Address', Icons.home,
                        TextInputType.streetAddress,
                        optional: true),
                  ],
                ),
              ),
            ),

            const Divider(height: 30),

            // --- Product Details ---
            const Text('Product Details',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 10),
            // 🛑 MODIFIED: Using the new helper to display rich product details
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: cart.items.map((product) => _buildProductDetailCard(product)).toList(),
                ),
              ),
            ),


            const Divider(height: 30),

            // --- Invoice Summary ---
            const Text('Invoice Summary',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', subtotal),
                    _buildSummaryRow('Discount', _discount,
                        isInput: true, ctrl: _discountController, color: Colors.red),
                    _buildSummaryRow('Tax (${_taxRate.toStringAsFixed(1)}%)', taxAmt),
                    const Divider(height: 20),
                    _buildSummaryRow('Total', total, bold: true, color: Colors.deepPurple),
                    _buildSummaryRow('Paid', _paid, isInput: true, ctrl: _paidController),
                    _buildSummaryRow('Due', due, bold: true, color: due > 0 ? Colors.red : Colors.green),
                  ],
                ),
              ),
            ),


            const SizedBox(height: 24),
            // --- Complete Sale Button ---
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : ElevatedButton.icon(
                onPressed: _completeSell,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Complete Sale'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      // --- Floating Action Button for PDF ---
      floatingActionButton: _invoiceResult != null
          ? FloatingActionButton.extended(
        onPressed: _downloadPdf,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Download PDF'),
        backgroundColor: Colors.deepPurple,
      )
          : null,
    );
  }

  // --- Invoice Result View ---
  Widget _buildResultView() {
    final inv = _invoiceResult!;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              Text('Success! Invoice #${inv.id}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 12),
              Text('Customer: ${inv.customerName}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Total: \$${inv.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate back to the home/product listing page
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Start New Sale'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
