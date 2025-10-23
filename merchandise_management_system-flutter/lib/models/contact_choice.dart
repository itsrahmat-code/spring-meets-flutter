// lib/models/contact_choice.dart
enum ReceiptChannel { email, sms }

class ContactChoice {
  final String? email;
  final String? phone;
  final ReceiptChannel channel;
  final bool consent;

  ContactChoice({
    required this.channel,
    this.email,
    this.phone,
    required this.consent,
  });
}
