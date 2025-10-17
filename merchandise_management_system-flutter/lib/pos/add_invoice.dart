import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/cart_service.dart';
// ⚠️ CORRECTED: Using the proper API Service class name
import '../service/invoice_api_service.dart';


class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Controller for new email field
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(text: '0.00');
  final TextEditingController _paidController = TextEditingController();

  // ⚠️ CORRECTED: Referencing the new/correct API Service class
  final InvoiceApiService _apiService = InvoiceApiService();
  final double _taxRate = 5.0; // Fixed tax rate from your Java entity
  double _discount = 0.0;
  double _paid = 0.0;
  bool _isLoading = false;
  int? _completedInvoiceId;

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

  // Recalculates totals and updates paid amount if not manually entered
  void _recalculate() {
    final cartService = Provider.of<CartService>(context, listen: false);
    setState(() {
      _discount = double.tryParse(_discountController.text) ?? 0.0;
      // Recalculate total
      final subtotal = cartService.subtotal;
      final taxedSubtotal = subtotal - _discount;
      final taxAmount = taxedSubtotal * (_taxRate / 100.0);
      final total = taxedSubtotal + taxAmount;

      // Update paid controller if it's currently showing an old total or is empty
      // Only set initial paid amount if it's empty, otherwise let user input stand
      if (_paidController.text.isEmpty || _paidController.text == '0.00') {
        _paidController.text = total.toStringAsFixed(2);
      }

      _paid = double.tryParse(_paidController.text) ?? 0.0;
    });
  }

  void _completeSell() async {
    final cartService = Provider.of<CartService>(context, listen: false);
    if (cartService.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty. Add products to sell.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final subtotal = cartService.subtotal;
      final taxedSubtotal = subtotal - _discount;
      final taxAmount = taxedSubtotal * (_taxRate / 100.0);
      final total = taxedSubtotal + taxAmount;

      _paid = double.tryParse(_paidController.text) ?? 0.0;

      if (_paid < total) {
        throw Exception('Paid amount is less than the total due.');
      }

      // Pass all calculated financial fields and the new customer email
      final newInvoiceId = await _apiService.createInvoice(
        customerName: _nameController.text.trim().isEmpty ? 'Guest Customer' : _nameController.text.trim(),
        customerEmail: _emailController.text.trim(), // ⬅️ NEW: Passing customer email
        customerPhone: _phoneController.text.trim(),
        customerAddress: _addressController.text.trim(),
        subtotal: subtotal,
        discount: _discount,
        taxRate: _taxRate,
        taxAmount: taxAmount,
        total: total,
        paid: _paid,
        products: cartService.items,
      );

      setState(() {
        _completedInvoiceId = newInvoiceId;
        _isLoading = false;
      });

      cartService.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale Completed! Invoice ID: $newInvoiceId')),
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle the exception more gracefully for user feedback
      final errorMessage = e.toString().contains('less than the total')
          ? 'Payment error: Paid amount is less than the total due.'
          : 'Sell Failed: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  void _downloadPdf() {
    if (_completedInvoiceId == null) return;
    // TODO: Implement PDF download logic, possibly another API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading PDF for Invoice ${_completedInvoiceId!}... (Feature placeholder)')),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalculate();
    });
    // Listeners to trigger recalculation when input fields change
    _discountController.addListener(_recalculate);
    _paidController.addListener(() {
      // Only recalculate to update the DUE amount, not the whole invoice total
      setState(() {
        _paid = double.tryParse(_paidController.text) ?? 0.0;
      });
    });
  }

  // Helper method for consistent, premium-looking text fields
  Widget _buildCustomerInputField(
      TextEditingController controller,
      String label,
      IconData icon,
      TextInputType keyboardType, {
        bool isOptional = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label + (isOptional ? ' (Optional)' : ' (Required)'),
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Sale / Checkout'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          final subtotal = cartService.subtotal;
          final taxedSubtotal = subtotal - _discount;
          final taxAmount = taxedSubtotal * (_taxRate / 100.0);
          final total = taxedSubtotal + taxAmount;
          final due = total - _paid;

          if (_completedInvoiceId != null) {
            return Center(
              child: Padding(
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
                        const SizedBox(height: 16),
                        Text('Sale Completed Successfully!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                        const SizedBox(height: 8),
                        Text('Invoice ID: #${_completedInvoiceId!}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _downloadPdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Download Invoice PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                          child: const Text('Start New Sale', style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          if (cartService.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Your cart is empty. Please add products to start a sale.', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('Go to Products'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Customer Info ---
                const Text('Customer Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                const Divider(color: Colors.teal, thickness: 1),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildCustomerInputField(_nameController, 'Customer Name', Icons.person, TextInputType.name),
                        const SizedBox(height: 15),
                        _buildCustomerInputField(_emailController, 'Email', Icons.email, TextInputType.emailAddress, isOptional: true), // ⬅️ NEW EMAIL FIELD
                        const SizedBox(height: 15),
                        _buildCustomerInputField(_phoneController, 'Phone', Icons.phone, TextInputType.phone, isOptional: true),
                        const SizedBox(height: 15),
                        _buildCustomerInputField(_addressController, 'Address', Icons.location_on, TextInputType.streetAddress, isOptional: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Cart Items ---
                const Text('Items to Invoice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                const Divider(color: Colors.teal, thickness: 1),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: cartService.items.map((product) => ListTile(
                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('${product.quantity} units @ \$${product.price.toStringAsFixed(2)}'),
                      trailing: Text('\$${product.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Totals ---
                const Text('Invoice Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                const Divider(color: Colors.teal, thickness: 1),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', subtotal),
                        _buildSummaryRow('Discount (Applied)', _discount, isInput: true, controller: _discountController, color: Colors.redAccent),
                        _buildSummaryRow('Tax (${_taxRate.toStringAsFixed(0)}%)', taxAmount),
                        const Divider(),
                        _buildSummaryRow('GRAND TOTAL', total, isBold: true, color: Colors.deepPurple),
                        const SizedBox(height: 10),
                        _buildSummaryRow('Amount Paid', _paid, isInput: true, controller: _paidController),
                        _buildSummaryRow('Amount Due', due, isBold: true, color: due > 0 ? Colors.red : Colors.green),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Complete Sell Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _completeSell,
                    icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.check_circle_outline, size: 28),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                    ),
                    label: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : const Text('COMPLETE SELL & GENERATE INVOICE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false, Color color = Colors.black, bool isInput = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
              color: color,
            ),
          ),
          isInput
              ? SizedBox(
            width: 120,
            height: 40,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
              decoration: InputDecoration(
                prefixText: '\$',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          )
              : Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
