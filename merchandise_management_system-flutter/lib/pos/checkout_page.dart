import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:merchandise_management_system/service/cart_service.dart';
import 'package:merchandise_management_system/service/invoice_service.dart';

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

      final resp = await _invoiceService.createInvoice(
        name: _name.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        discount: discount,
        paid: paid,
        items: cart.items, // List<CartLine>
      );

      cart.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice #${resp['invoiceNumber'] ?? ''} created')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create invoice failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
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
              Text('Cart total: ৳ ${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Customer Name *'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
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
