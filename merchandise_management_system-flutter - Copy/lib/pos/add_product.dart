// File: lib/pos/product_add_page.dart

import 'package:flutter/material.dart';
import 'package:merchandise_management_system/models/category_model.dart';
import 'package:merchandise_management_system/pages/manager_page.dart';
import 'package:merchandise_management_system/pos/product_list_page.dart';
import 'package:merchandise_management_system/service/product_service.dart';

import '../models/product_model.dart';

class ProductAdd extends StatefulWidget {
  final Map<String, dynamic> profile;

  const ProductAdd({super.key, required this.profile});

  @override
  State<ProductAdd> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // State for Dropdown
  Category _selectedCategory = Category.Laptop;

  bool _isLoading = false;

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

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newProduct = Product(
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
        details: _detailsController.text.trim().isEmpty ? null : _detailsController.text.trim(),
        category: _selectedCategory,
        quantity: int.parse(_quantityController.text.trim()),
        price: double.parse(_priceController.text.trim()),
      );

      await _productService.addProduct(newProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListPage(profile: widget.profile),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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

  void _navigateToManagerPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ManagerPage(profile: widget.profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToManagerPage();
        return false; // prevent default pop
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Product'),
          backgroundColor: Colors.teal,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateToManagerPage,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildTextField(_nameController, 'Product Name', validator: _validateRequired),
                _buildTextField(_brandController, 'Brand', validator: _validateRequired),
                _buildCategoryDropdown(),
                _buildTextField(_modelController, 'Model (Optional)', isRequired: false),
                _buildTextField(_detailsController, 'Details (Optional)', maxLines: 3, isRequired: false),
                _buildTextField(
                  _quantityController,
                  'Quantity in Stock',
                  keyboardType: TextInputType.number,
                  validator: _validateInt,
                ),
                _buildTextField(
                  _priceController,
                  'Unit Price',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateDouble,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitProduct,
                  icon: _isLoading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Adding Product...' : 'Add Product'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
        int maxLines = 1,
        bool isRequired = true,
        String? hintText,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (isRequired ? '*' : ''),
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<Category>(
        decoration: const InputDecoration(
          labelText: 'Category*',
          border: OutlineInputBorder(),
        ),
        value: _selectedCategory,
        items: Category.values.map((Category category) {
          return DropdownMenuItem<Category>(
            value: category,
            child: Text(category.toString().split('.').last),
          );
        }).toList(),
        onChanged: (Category? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedCategory = newValue;
            });
          }
        },
        validator: (value) => value == null ? 'Please select a category' : null,
      ),
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  String? _validateInt(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required.';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a whole number.';
    }
    return null;
  }

  String? _validateDouble(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required.';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number (e.g., 99.99).';
    }
    return null;
  }
}
