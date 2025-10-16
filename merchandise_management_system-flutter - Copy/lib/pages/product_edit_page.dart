import 'package:flutter/material.dart';

import '../entity/product.dart';
import '../service/product_service.dart';


class ProductEditPage extends StatefulWidget {
  final ProductService service;
  final Product? product; // null => new

  ProductEditPage({required this.service, this.product});

  @override
  _ProductEditPageState createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtl;
  late TextEditingController _brandCtl;
  late TextEditingController _modelCtl;
  late TextEditingController _detailsCtl;
  late TextEditingController _quantityCtl;
  late TextEditingController _priceCtl;
  String _category = 'Laptop';

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtl = TextEditingController(text: p?.name ?? '');
    _brandCtl = TextEditingController(text: p?.brand ?? '');
    _modelCtl = TextEditingController(text: p?.model ?? '');
    _detailsCtl = TextEditingController(text: p?.details ?? '');
    _quantityCtl = TextEditingController(text: p?.quantity.toString() ?? '0');
    _priceCtl = TextEditingController(text: p?.price.toString() ?? '0');
    _category = p?.category ?? 'Laptop';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Product' : 'Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Laptop', 'Accessory']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                controller: _brandCtl,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _modelCtl,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextFormField(
                controller: _detailsCtl,
                decoration: const InputDecoration(labelText: 'Details'),
              ),
              TextFormField(
                controller: _quantityCtl,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Must be integer';
                  return null;
                },
              ),
              TextFormField(
                controller: _priceCtl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Must be number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Text(isEdit ? 'Update' : 'Create'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newProduct = Product(
                      id: widget.product?.id ?? 0,
                      name: _nameCtl.text,
                      category: _category,
                      brand: _brandCtl.text,
                      model: _modelCtl.text.isEmpty ? null : _modelCtl.text,
                      details: _detailsCtl.text.isEmpty ? null : _detailsCtl.text,
                      quantity: int.parse(_quantityCtl.text),
                      price: double.parse(_priceCtl.text),
                    );
                    Product result;
                    if (isEdit) {
                      result = await widget.service.updateProduct(newProduct.id, newProduct);
                    } else {
                      result = await widget.service.addProduct(newProduct);
                    }
                    Navigator.pop(context, result);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
