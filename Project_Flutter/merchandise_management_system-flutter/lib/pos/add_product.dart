import 'package:flutter/material.dart';
import 'package:merchandise_management_system/models/product_model.dart';
import 'package:merchandise_management_system/service/product_service.dart';

class ProductAdd extends StatefulWidget {
  final Map<String, dynamic> profile;          // required by ManagerPage
  final Product? productToEdit;                // optional for edit mode

  const ProductAdd({
    super.key,
    required this.profile,
    this.productToEdit,
  });

  @override
  State<ProductAdd> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _detailsController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  Category _selectedCategory = Category.Laptop;

  bool get isEditMode => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;

    _nameController = TextEditingController(text: p?.name ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _modelController = TextEditingController(text: p?.model ?? '');
    _detailsController = TextEditingController(text: p?.details ?? '');
    _quantityController = TextEditingController(text: (p?.quantity ?? '').toString());
    _priceController = TextEditingController(text: (p?.price ?? '').toString());
    if (p != null) _selectedCategory = p.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _detailsController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.productToEdit?.id,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
      details: _detailsController.text.trim().isEmpty ? null : _detailsController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      price: double.parse(_priceController.text.trim()),
    );

    try {
      final saved = isEditMode
          ? await _productService.updateProduct(product)
          : await _productService.addProduct(product);

      if (!mounted) return;

      // Return saved product to previous page so it can update instantly
      Navigator.pop(context, saved);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditMode ? 'Product updated' : 'Product added')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Product' : 'Add New Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: Category.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (c) => setState(() => _selectedCategory = c ?? Category.Laptop),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a brand' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model (Optional)'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(labelText: 'Details (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Please enter quantity';
                  final n = int.tryParse(t);
                  if (n == null || n < 0) return 'Enter a valid non-negative integer';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Please enter price';
                  final n = double.tryParse(t);
                  if (n == null || n < 0) return 'Enter a valid non-negative number';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text(isEditMode ? 'Update Product' : 'Save Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
