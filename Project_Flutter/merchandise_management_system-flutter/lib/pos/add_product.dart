import 'package:flutter/material.dart';
import 'package:merchandise_management_system/models/product_model.dart';
import 'package:merchandise_management_system/service/product_service.dart';

// navigate targets
import 'package:merchandise_management_system/pages/manager_page.dart';
import 'package:merchandise_management_system/pos/product_list_page.dart';

class ProductAdd extends StatefulWidget {
  final Map<String, dynamic> profile;          // required by ManagerPage/ProductList
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
  bool _submitting = false;

  bool get isEditMode => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;

    _nameController    = TextEditingController(text: p?.name ?? '');
    _brandController   = TextEditingController(text: p?.brand ?? '');
    _modelController   = TextEditingController(text: p?.model ?? '');
    _detailsController = TextEditingController(text: p?.details ?? '');
    _quantityController= TextEditingController(text: (p?.quantity ?? '').toString());
    _priceController   = TextEditingController(text: (p?.price ?? '').toString());
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

  // --- navigation helpers ---
  void _goToManager() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => ManagerPage(profile: widget.profile)),
          (route) => false,
    );
  }

  void _goToProductList() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => ProductListPage(profile: widget.profile)),
          (route) => false,
    );
  }

  // --- submit ---
  Future<void> _submitForm() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

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

    setState(() => _submitting = true);
    try {
      if (isEditMode) {
        await _productService.updateProduct(product);
      } else {
        await _productService.addProduct(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditMode ? 'Product updated' : 'Product added')),
      );

      // ✅ after saving, go to Product List page
      _goToProductList();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ✅ device/system back also goes to Manager Page
      onWillPop: () async {
        _goToManager();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Edit Product' : 'Add New Product'),
          leading: IconButton(
            tooltip: 'Back to Manager',
            icon: const Icon(Icons.arrow_back),
            onPressed: _goToManager, // ✅ app-bar back -> ManagerPage
          ),
        ),
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
                    onPressed: _submitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _submitting
                          ? (isEditMode ? 'Updating...' : 'Saving...')
                          : (isEditMode ? 'Update Product' : 'Save Product'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
