// lib/pos/product_edit_page.dart
import 'package:flutter/material.dart';
import 'package:merchandise_management_system/models/product_model.dart';
import 'package:merchandise_management_system/service/product_service.dart';

class ProductEditPage extends StatefulWidget {
  final Product original;
  final ProductService api;

  const ProductEditPage({
    super.key,
    required this.original,
    required this.api,
  });

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _detailsCtrl;

  late Category _category;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.original;
    _nameCtrl = TextEditingController(text: p.name);
    _brandCtrl = TextEditingController(text: p.brand);
    _modelCtrl = TextEditingController(text: p.model ?? '');
    _priceCtrl = TextEditingController(text: p.price.toString());
    _qtyCtrl = TextEditingController(text: p.quantity.toString());
    _detailsCtrl = TextEditingController(text: p.details ?? '');
    _category = p.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final updated = widget.original.copyWith(
        name: _nameCtrl.text.trim(),
        brand: _brandCtrl.text.trim(),
        model: _modelCtrl.text.trim().isEmpty ? null : _modelCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text.trim()) ?? widget.original.price,
        quantity: int.tryParse(_qtyCtrl.text.trim()) ?? widget.original.quantity,
        details: _detailsCtrl.text.trim(),
        category: _category,
      );

      final saved = await widget.api.updateProduct(updated);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated')),
      );
      Navigator.of(context).pop<Product>(saved); // return updated product
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: AbsorbPointer(
        absorbing: _saving,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _brandCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Brand *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _modelCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Price *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                            (double.tryParse(v ?? '') == null) ? 'Invalid' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                            (int.tryParse(v ?? '') == null) ? 'Invalid' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Category selector
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Category>(
                          value: _category,
                          isExpanded: true,
                          items: Category.values
                              .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c.name)))
                              .toList(),
                          onChanged: (c) {
                            if (c != null) setState(() => _category = c);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _detailsCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Details',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
            if (_saving) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
