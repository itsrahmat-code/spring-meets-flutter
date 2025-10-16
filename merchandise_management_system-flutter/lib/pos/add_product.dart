// File: lib/pages/product_add_page.dart

import 'package:flutter/material.dart';

import '../entity/Category.dart';
import '../entity/product.dart';
import '../service/product_service.dart';


class ProductAdd extends StatefulWidget {
  const ProductAdd({super.key});

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
  final TextEditingController _invoiceIdController = TextEditingController();

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
    _invoiceIdController.dispose();
    super.dispose();
  }

  // --- Submission Logic ---
  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is not valid
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
        // Check if invoice ID is entered, if not, send null
        invoiceId: _invoiceIdController.text.trim().isEmpty
            ? null
            : int.parse(_invoiceIdController.text.trim()),
      );

      // Call the API service to add the product
      await _productService.addProduct(newProduct);

      // Show success message and pop the page
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.pop(context, true); // Pass true to indicate successful addition
      }
    } catch (e) {
      // Show error message
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Name (Required) ---
              _buildTextField(_nameController, 'Product Name', validator: _validateRequired),

              // --- Brand (Required) ---
              _buildTextField(_brandController, 'Brand', validator: _validateRequired),

              // --- Category (Required) ---
              _buildCategoryDropdown(),

              // --- Model (Optional) ---
              _buildTextField(_modelController, 'Model (Optional)', isRequired: false),

              // --- Details (Optional) ---
              _buildTextField(_detailsController, 'Details (Optional)', maxLines: 3, isRequired: false),

              // --- Quantity (Required, Numeric) ---
              _buildTextField(
                _quantityController,
                'Quantity in Stock',
                keyboardType: TextInputType.number,
                validator: _validateInt,
              ),

              // --- Price (Required, Numeric/Decimal) ---
              _buildTextField(
                _priceController,
                'Unit Price',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateDouble,
              ),

              const Divider(height: 32),

              // --- Invoice ID (Optional, Numeric) ---
              _buildTextField(
                _invoiceIdController,
                'Invoice ID (Optional)',
                keyboardType: TextInputType.number,
                isRequired: false,
                hintText: 'Link to an existing invoice',
              ),

              const SizedBox(height: 30),

              // --- Submit Button ---
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
    );
  }

  // --- Helper Widgets and Validators ---

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