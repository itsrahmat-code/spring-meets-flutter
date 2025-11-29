
// lib/models/expense.dart
import 'package:intl/intl.dart';

class Expense {
  final int? id;
  DateTime date;
  String title;
  String? description;
  double amount;
  String? addedBy;

  Expense({
    this.id,
    required this.date,
    required this.title,
    this.description,
    required this.amount,
    this.addedBy,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    // Backend date is "yyyy-MM-dd"
    final dateStr = json['date'] as String?;
    return Expense(
      id: json['id'] as int?,
      date: dateStr != null ? DateTime.parse(dateStr) : DateTime.now(),
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      addedBy: json['addedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final df = DateFormat('yyyy-MM-dd');
    return {
      if (id != null) 'id': id,
      'date': df.format(date),
      'title': title,
      'description': description,
      'amount': amount,
      'addedBy': addedBy,
    };
  }

  Expense copyWith({
    int? id,
    DateTime? date,
    String? title,
    String? description,
    double? amount,
    String? addedBy,
  }) {
    return Expense(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      addedBy: addedBy ?? this.addedBy,
    );
  }
}
