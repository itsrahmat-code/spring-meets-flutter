// lib/pos/confirm_contact_sheet.dart
import 'package:flutter/material.dart';
import 'package:merchandise_management_system/models/contact_choice.dart';

class ConfirmContactSheet extends StatefulWidget {
  final String initialEmail;
  final String initialPhone;

  const ConfirmContactSheet({
    super.key,
    this.initialEmail = '',
    this.initialPhone = '',
  });

  @override
  State<ConfirmContactSheet> createState() => _ConfirmContactSheetState();
}

class _ConfirmContactSheetState extends State<ConfirmContactSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  ReceiptChannel _channel = ReceiptChannel.email;
  bool _consent = true;

  @override
  void initState() {
    super.initState();
    _email.text = widget.initialEmail;
    _phone.text = widget.initialPhone;
  }

  String? _validateEmail(String? v) {
    if (_channel == ReceiptChannel.email) {
      if (v == null || v.trim().isEmpty) return 'Email required';
      final emailRx = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      if (!emailRx.hasMatch(v.trim())) return 'Invalid email';
    }
    return null;
  }

  String? _validatePhone(String? v) {
    if (_channel == ReceiptChannel.sms) {
      if (v == null || v.trim().isEmpty) return 'Phone required';
      // Bangladesh format examples: 01XXXXXXXXX or +8801XXXXXXXXX
      final bdRx = RegExp(r'^(\+?8801|01)[3-9]\d{8}$');
      if (!bdRx.hasMatch(v.trim())) return 'Invalid BD mobile number';
    }
    return null;
  }

  void _submit() {
    if (!_consent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consent is required to send receipt.')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        ContactChoice(
          channel: _channel,
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          consent: _consent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          top: 12,
        ),
        child: Form(
          key: _formKey,
          child: Wrap(
            runSpacing: 10,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text('Send digital receipt', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              SegmentedButton<ReceiptChannel>(
                segments: const [
                  ButtonSegment(value: ReceiptChannel.email, label: Text('Email'), icon: Icon(Icons.email_outlined)),
                  ButtonSegment(value: ReceiptChannel.sms,   label: Text('SMS'),   icon: Icon(Icons.sms_outlined)),
                ],
                selected: {_channel},
                onSelectionChanged: (s) => setState(() => _channel = s.first),
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (BD)',
                  hintText: '01XXXXXXXXX or +8801XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _consent,
                onChanged: (v) => setState(() => _consent = v ?? false),
                title: const Text('I agree to receive a digital receipt.'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.send),
                      label: const Text('Save & Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
