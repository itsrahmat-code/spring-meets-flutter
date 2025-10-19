import 'package:flutter/material.dart';
import 'package:merchandise_management_system/entity/invoice.dart';
import 'package:merchandise_management_system/service/invoice_service.dart';

class InvoiceAddPage extends StatefulWidget {
  final Map<Product, int> cartItems;

  const InvoiceAddPage({super.key, required this.cartItems});

  @override
  State<InvoiceAddPage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<InvoiceAddPage> {
  final _formKey = GlobalKey<FormState>();
  final InvoiceService _invoiceService = InvoiceService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _invoiceNumberController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(text: '0.0');
  final TextEditingController _taxRateController = TextEditingController(text: '5.0');
  final TextEditingController _paidController = TextEditingController(text: '0.0');

  // You can remove these if you don't want product editing here.
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productQuantityController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.cartItems.isNotEmpty) {
      final firstProduct = widget.cartItems.keys.first;
      final qty = widget.cartItems[firstProduct]!;

      _productNameController.text = firstProduct.name;
      _productPriceController.text = firstProduct.price.toStringAsFixed(2);
      _productQuantityController.text = qty.toString();
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newProduct = Product(
        name: _productNameController.text,
        price: double.tryParse(_productPriceController.text) ?? 0.0,
        quantity: int.tryParse(_productQuantityController.text) ?? 0,
      );

      final newInvoice = Invoice(
        date: DateTime.now(),
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        invoiceNumber: _invoiceNumberController.text,
        discount: double.tryParse(_discountController.text) ?? 0.0,
        taxRate: double.tryParse(_taxRateController.text) ?? 5.0,
        paid: double.tryParse(_paidController.text) ?? 0.0,
        subtotal: 0.0,
        taxAmount: 0.0,
        total: 0.0,
        products: [newProduct],
      );

      try {
        final createdInvoice = await _invoiceService.createInvoice(newInvoice);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invoice ${createdInvoice.invoiceNumber} created successfully! ID: ${createdInvoice.id}')),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save invoice: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _invoiceNumberController.dispose();
    _discountController.dispose();
    _taxRateController.dispose();
    _paidController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    _productQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _submitForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            const Text('Customer Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildTextFormField(_nameController, 'Customer Name', (value) => value!.isEmpty ? 'Name is required' : null),
            _buildTextFormField(_emailController, 'Email', null),
            _buildTextFormField(_phoneController, 'Phone', null),
            _buildTextFormField(_addressController, 'Address', null),
            const Divider(height: 30),
            const Text('Invoice Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildTextFormField(_invoiceNumberController, 'Invoice Number', (value) => value!.isEmpty ? 'Invoice Number is required' : null),
            _buildTextFormField(_discountController, 'Discount Amount', null, isDouble: true),
            _buildTextFormField(_taxRateController, 'Tax Rate (%)', null, isDouble: true),
            _buildTextFormField(_paidController, 'Amount Paid', null, isDouble: true),
            const Divider(height: 30),
            const Text('Product Entry (One Product Only)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildTextFormField(_productNameController, 'Product Name', (value) => value!.isEmpty ? 'Product Name is required' : null),
            _buildTextFormField(_productPriceController, 'Price', (value) => value!.isEmpty ? 'Price is required' : null, isDouble: true),
            _buildTextFormField(_productQuantityController, 'Quantity', (value) => value!.isEmpty ? 'Quantity is required' : null, isInteger: true),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Save Invoice', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller,
      String labelText,
      String? Function(String?)? validator, {
        bool isDouble = false,
        bool isInteger = false,
      }) {
    TextInputType keyboardType = TextInputType.text;
    if (isDouble) keyboardType = const TextInputType.numberWithOptions(decimal: true);
    if (isInteger) keyboardType = TextInputType.number;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: validator ??
                (value) {
              if (isDouble || isInteger) {
                if (value == null || value.isEmpty) return null;
                final val = isDouble ? double.tryParse(value) : int.tryParse(value);
                return val == null ? 'Invalid number format' : null;
              }
              return null;
            },
      ),
    );
  }
}
