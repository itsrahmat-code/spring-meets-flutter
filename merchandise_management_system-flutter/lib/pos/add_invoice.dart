// File: lib/pos/invoice_add_page.dart

import 'package:flutter/material.dart';
import '../entity/invoice.dart';
import '../entity/product.dart'; // Ensure you have this import
import '../service/product_service.dart'; // Ensure you have this import
import '../service/invoice_service.dart';


class InvoiceAddPage extends StatefulWidget {
  const InvoiceAddPage({super.key});

  @override
  State<InvoiceAddPage> createState() => _InvoiceAddPageState();
}

class _InvoiceAddPageState extends State<InvoiceAddPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final InvoiceService _invoiceService = InvoiceService();

  // Customer Controllers
  final TextEditingController _nameController = TextEditingController(text: 'Walk-in Customer');
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Payment Controllers
  final TextEditingController _discountController = TextEditingController(text: '0.0');
  final TextEditingController _paidController = TextEditingController();

  // Product State
  List<Product> _allStockProducts = [];
  List<Product> _selectedProductDetails = [];
  Map<int, int> _selectedQuantities = {}; // Map<ProductID, QuantitySold>

  bool _isLoading = true;
  bool _isSaving = false;

  // Invoice Totals
  double _subtotal = 0.0;
  double _discount = 0.0;
  double _taxRate = 5.0; // Matches your Spring entity default
  double _taxAmount = 0.0;
  double _total = 0.0;
  double _paid = 0.0;
  double _due = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchStockProducts();
    _discountController.addListener(_calculateTotals);
    _paidController.addListener(_calculateTotals);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _discountController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  // --- Data & Calculation Logic ---

  Future<void> _fetchStockProducts() async {
    try {
      // NOTE: Assuming ProductService.getAllProducts returns List<Product>
      _allStockProducts = await _productService.getAllProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stock products: $e')),
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

  void _calculateTotals() {
    if (!mounted) return;

    // 1. Calculate Base Subtotal
    double newSubtotal = 0.0;
    for (var product in _selectedProductDetails) {
      int quantitySold = _selectedQuantities[product.id] ?? 0;
      newSubtotal += product.price * quantitySold;
    }

    // 2. Parse discount and paid amounts
    double parsedDiscount = double.tryParse(_discountController.text) ?? 0.0;
    double parsedPaid = double.tryParse(_paidController.text) ?? 0.0;

    // Prevent discount > subtotal
    if (parsedDiscount > newSubtotal) {
      parsedDiscount = newSubtotal;
    }

    // 3. Calculate Tax
    double taxableAmount = newSubtotal - parsedDiscount;
    double newTaxAmount = taxableAmount * (_taxRate / 100.0);

    // 4. Calculate Final Total
    double newTotal = taxableAmount + newTaxAmount;

    // 5. Calculate Due
    double newDue = newTotal - parsedPaid;

    setState(() {
      _subtotal = newSubtotal;
      _discount = parsedDiscount;
      _taxAmount = newTaxAmount;
      _total = newTotal;
      _paid = parsedPaid;
      _due = newDue;
    });
  }

  // --- Add Product Dialog ---
  Future<void> _showAddProductDialog() async {
    Product? selectedProduct;
    int quantityToSell = 1;

    // Filter out products already selected and those with zero stock
    List<Product> availableProducts = _allStockProducts
        .where((p) => !_selectedQuantities.containsKey(p.id) && (p.quantity ?? 0) > 0)
        .toList();

    if (availableProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more unique products available in stock.')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Product to Invoice'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Product>(
                    decoration: const InputDecoration(labelText: 'Select Product'),
                    value: selectedProduct,
                    items: availableProducts.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('${p.name} (${p.brand}) - Stock: ${p.quantity}'),
                    )).toList(),
                    onChanged: (Product? newValue) {
                      setState(() {
                        selectedProduct = newValue;
                        quantityToSell = 1; // Reset quantity
                      });
                    },
                    validator: (value) => value == null ? 'Please select a product' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    initialValue: quantityToSell.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    onChanged: (value) {
                      int? newQty = int.tryParse(value);
                      if (selectedProduct != null && newQty != null && newQty > 0 && newQty <= selectedProduct!.quantity) {
                        quantityToSell = newQty;
                      }
                    },
                    validator: (value) {
                      int? newQty = int.tryParse(value ?? '');
                      if (newQty == null || newQty <= 0) return 'Enter valid quantity.';
                      if (selectedProduct != null && newQty > selectedProduct!.quantity) return 'Only ${selectedProduct!.quantity} in stock.';
                      return null;
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (selectedProduct != null && quantityToSell > 0) {
                      // Add item to main widget state
                      _addItemToInvoice(selectedProduct!, quantityToSell);
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addItemToInvoice(Product product, int quantity) {
    setState(() {
      _selectedQuantities[product.id!] = quantity;
      _selectedProductDetails.add(product);
      _calculateTotals();
    });
  }

  void _removeItemFromInvoice(int productId) {
    setState(() {
      _selectedQuantities.remove(productId);
      _selectedProductDetails.removeWhere((p) => p.id == productId);
      _calculateTotals();
    });
  }

  // --- Submission Logic ---
  Future<void> _submitInvoice() async {
    if (!_formKey.currentState!.validate() || _selectedQuantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_selectedQuantities.isEmpty ? 'Please add at least one product.' : 'Please fix form errors.')),
      );
      return;
    }

    if (_paid < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paid amount cannot be negative.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      List<InvoiceProductItem> itemsToSell = _selectedProductDetails.map((p) =>
          InvoiceProductItem(
            id: p.id!,
            quantity: _selectedQuantities[p.id]!,
          )).toList();

      await _invoiceService.createInvoice(
        _nameController.text.trim(),
        _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        _discount,
        _paid,
        itemsToSell,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice created successfully!')),
        );
        Navigator.pop(context, true); // Success, refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating invoice: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sales Invoice'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Customer Details
              _buildSectionTitle('Customer Details'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Customer Name*'),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone (Optional)'),
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email (Optional)'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address (Optional)'),
              ),

              const SizedBox(height: 30),

              // 2. Product Selection
              _buildSectionTitle('Invoice Items'),
              _buildProductList(),

              ElevatedButton.icon(
                onPressed: _showAddProductDialog,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // 3. Totals Summary
              _buildTotalsSummary(),

              // 4. Payment Input
              _buildSectionTitle('Payment & Discount'),
              TextFormField(
                  controller: _discountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Discount Amount (-\$)', prefixText: '\$'),
                  validator: (v) {
                    if (double.tryParse(v ?? '0.0') == null) return 'Invalid number';
                    return null;
                  }
              ),
              TextFormField(
                controller: _paidController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount Paid* (+\$)', prefixText: '\$'),
                validator: (v) {
                  if (double.tryParse(v ?? '0.0') == null) return 'Invalid number';
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // 5. Submit Button
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _submitInvoice,
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.receipt),
                label: Text(_isSaving ? 'Saving Invoice...' : 'Create Invoice'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedProductDetails.length,
      itemBuilder: (context, index) {
        final product = _selectedProductDetails[index];
        final quantity = _selectedQuantities[product.id] ?? 0;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          elevation: 1,
          child: ListTile(
            title: Text('${product.name} (${product.brand})'),
            subtitle: Text(
                'Qty: $quantity x \$${product.price.toStringAsFixed(2)} = \$${(product.price * quantity).toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeItemFromInvoice(product.id!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalRow(String label, double amount, Color color, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style ?? const TextStyle(fontSize: 15)),
          Text(
            '${amount < 0 ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
            style: style?.copyWith(color: color) ?? TextStyle(color: color, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSummary() {
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        color: Colors.teal.shade50,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              _buildTotalRow('Subtotal', _subtotal, Colors.black87),
              _buildTotalRow('Discount (-\$)', -_discount, Colors.red),
              _buildTotalRow('Tax (${_taxRate.toStringAsFixed(1)}%)', _taxAmount, Colors.orange),
              const Divider(),
              _buildTotalRow('GRAND TOTAL', _total, Colors.teal, style: boldStyle.copyWith(fontSize: 18)),
              _buildTotalRow('Amount Paid', _paid, Colors.blue),
              _buildTotalRow('Amount Due', _due, _due > 0 ? Colors.red : Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}