// // File: lib/pos/product_add_page.dart
//
// import 'package:flutter/material.dart';
// import 'package:merchandise_management_system/models/category_model.dart';
// import 'package:merchandise_management_system/pages/manager_page.dart';
// import 'package:merchandise_management_system/pos/product_list_page.dart';
// import 'package:merchandise_management_system/service/product_service.dart';
//
// import '../models/product_model.dart';
//
// class ProductAdd extends StatefulWidget {
//   final Map<String, dynamic> profile;
//
//   const ProductAdd({super.key, required this.profile});
//
//   @override
//   State<ProductAdd> createState() => _ProductAddState();
// }
//
// class _ProductAddState extends State<ProductAdd> {
//   final _formKey = GlobalKey<FormState>();
//   final ProductService _productService = ProductService();
//
//   // Form Controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _brandController = TextEditingController();
//   final TextEditingController _modelController = TextEditingController();
//   final TextEditingController _detailsController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//
//   // State for Dropdown
//   Category _selectedCategory = Category.Laptop;
//
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _brandController.dispose();
//     _modelController.dispose();
//     _detailsController.dispose();
//     _quantityController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _submitProduct() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final newProduct = Product(
//         name: _nameController.text.trim(),
//         brand: _brandController.text.trim(),
//         model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
//         details: _detailsController.text.trim().isEmpty ? null : _detailsController.text.trim(),
//         category: _selectedCategory,
//         quantity: int.parse(_quantityController.text.trim()),
//         price: double.parse(_priceController.text.trim()),
//       );
//
//       await _productService.addProduct(newProduct);
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Product added successfully!')),
//         );
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ProductListPage(profile: widget.profile),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to add product: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   void _navigateToManagerPage() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ManagerPage(profile: widget.profile),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _navigateToManagerPage();
//         return false; // prevent default pop
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Add New Product'),
//           backgroundColor: Colors.teal,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: _navigateToManagerPage,
//           ),
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 _buildTextField(_nameController, 'Product Name', validator: _validateRequired),
//                 _buildTextField(_brandController, 'Brand', validator: _validateRequired),
//                 _buildCategoryDropdown(),
//                 _buildTextField(_modelController, 'Model (Optional)', isRequired: false),
//                 _buildTextField(_detailsController, 'Details (Optional)', maxLines: 3, isRequired: false),
//                 _buildTextField(
//                   _quantityController,
//                   'Quantity in Stock',
//                   keyboardType: TextInputType.number,
//                   validator: _validateInt,
//                 ),
//                 _buildTextField(
//                   _priceController,
//                   'Unit Price',
//                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                   validator: _validateDouble,
//                 ),
//                 const SizedBox(height: 30),
//                 ElevatedButton.icon(
//                   onPressed: _isLoading ? null : _submitProduct,
//                   icon: _isLoading
//                       ? const SizedBox(
//                     width: 18,
//                     height: 18,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                       : const Icon(Icons.save),
//                   label: Text(_isLoading ? 'Adding Product...' : 'Add Product'),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     backgroundColor: Colors.teal,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(
//       TextEditingController controller,
//       String label, {
//         TextInputType keyboardType = TextInputType.text,
//         String? Function(String?)? validator,
//         int maxLines = 1,
//         bool isRequired = true,
//         String? hintText,
//       }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15.0),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label + (isRequired ? '*' : ''),
//           hintText: hintText,
//           border: const OutlineInputBorder(),
//         ),
//         keyboardType: keyboardType,
//         validator: validator,
//         maxLines: maxLines,
//       ),
//     );
//   }
//
//   Widget _buildCategoryDropdown() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15.0),
//       child: DropdownButtonFormField<Category>(
//         decoration: const InputDecoration(
//           labelText: 'Category*',
//           border: OutlineInputBorder(),
//         ),
//         value: _selectedCategory,
//         items: Category.values.map((Category category) {
//           return DropdownMenuItem<Category>(
//             value: category,
//             child: Text(category.toString().split('.').last),
//           );
//         }).toList(),
//         onChanged: (Category? newValue) {
//           if (newValue != null) {
//             setState(() {
//               _selectedCategory = newValue;
//             });
//           }
//         },
//         validator: (value) => value == null ? 'Please select a category' : null,
//       ),
//     );
//   }
//
//   String? _validateRequired(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'This field is required.';
//     }
//     return null;
//   }
//
//   String? _validateInt(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Quantity is required.';
//     }
//     if (int.tryParse(value) == null) {
//       return 'Please enter a whole number.';
//     }
//     return null;
//   }
//
//   String? _validateDouble(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Price is required.';
//     }
//     if (double.tryParse(value) == null) {
//       return 'Please enter a valid number (e.g., 99.99).';
//     }
//     return null;
//   }
// }
//chat
// // lib/pages/product_upsert_page.dart
// import 'package:flutter/material.dart';
// import '../models/product.dart';
// import '../services/product_service.dart';
//
// class ProductUpsertPage extends StatefulWidget {
//   final Product? initial;
//   ProductUpsertPage({super.key, this.initial});
//
//   @override
//   State<ProductUpsertPage> createState() => _ProductUpsertPageState();
// }
//
// class _ProductUpsertPageState extends State<ProductUpsertPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _service = ProductService();
//
//   late TextEditingController _name;
//   Category _category = Category.Laptop;
//   late TextEditingController _brand;
//   late TextEditingController _model;
//   late TextEditingController _details;
//   late TextEditingController _quantity;
//   late TextEditingController _price;
//
//   @override
//   void initState() {
//     super.initState();
//     final p = widget.initial;
//     _name = TextEditingController(text: p?.name ?? '');
//     _category = p?.category ?? Category.Laptop;
//     _brand = TextEditingController(text: p?.brand ?? '');
//     _model = TextEditingController(text: p?.model ?? '');
//     _details = TextEditingController(text: p?.details ?? '');
//     _quantity = TextEditingController(text: p?.quantity.toString() ?? '0');
//     _price = TextEditingController(text: p?.price.toString() ?? '0');
//   }
//
//   @override
//   void dispose() {
//     _name.dispose();
//     _brand.dispose();
//     _model.dispose();
//     _details.dispose();
//     _quantity.dispose();
//     _price.dispose();
//     super.dispose();
//   }
//
//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final product = Product(
//       id: widget.initial?.id,
//       name: _name.text.trim(),
//       category: _category,
//       brand: _brand.text.trim(),
//       model: _model.text.trim().isEmpty ? null : _model.text.trim(),
//       details: _details.text.trim().isEmpty ? null : _details.text.trim(),
//       quantity: int.parse(_quantity.text.trim()),
//       price: double.parse(_price.text.trim()),
//     );
//
//     try {
//       final result = widget.initial == null
//           ? await _service.addProduct(product)
//           : await _service.updateProduct(product);
//       if (!mounted) return;
//       Navigator.of(context).pop(result);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Save failed: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.initial != null;
//     return Scaffold(
//       appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _name,
//                 decoration: const InputDecoration(labelText: 'Name'),
//                 validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),
//               DropdownButtonFormField<Category>(
//                 value: _category,
//                 decoration: const InputDecoration(labelText: 'Category'),
//                 items: Category.values
//                     .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
//                     .toList(),
//                 onChanged: (c) => setState(() => _category = c ?? Category.Laptop),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _brand,
//                 decoration: const InputDecoration(labelText: 'Brand'),
//                 validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _model,
//                 decoration: const InputDecoration(labelText: 'Model (optional)'),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _details,
//                 decoration: const InputDecoration(labelText: 'Details (optional)'),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _quantity,
//                 decoration: const InputDecoration(labelText: 'Quantity'),
//                 keyboardType: TextInputType.number,
//                 validator: (v) {
//                   if (v == null || v.trim().isEmpty) return 'Required';
//                   final n = int.tryParse(v.trim());
//                   if (n == null || n < 0) return 'Enter a valid non-negative integer';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _price,
//                 decoration: const InputDecoration(labelText: 'Price'),
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 validator: (v) {
//                   if (v == null || v.trim().isEmpty) return 'Required';
//                   final n = double.tryParse(v.trim());
//                   if (n == null || n < 0) return 'Enter a valid non-negative number';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.save),
//                   label: Text(isEditing ? 'Update' : 'Create'),
//                   onPressed: _save,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//gimini
// lib/screens/add_product_page.dart


import 'package:flutter/material.dart';
import 'package:merchandise_management_system/models/product_model.dart';
import 'package:merchandise_management_system/service/product_service.dart';

class ProductAdd extends StatefulWidget {
  final Map<String, dynamic> profile;          // <-- required by ManagerPage
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
    _quantityController = TextEditingController(text: p?.quantity?.toString() ?? '');
    _priceController = TextEditingController(text: p?.price?.toString() ?? '');
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
      if (isEditMode) {
        await _productService.updateProduct(product);
      } else {
        await _productService.addProduct(product);
      }
      if (!mounted) return;
      Navigator.pop(context, true); // signal success to previous page
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
