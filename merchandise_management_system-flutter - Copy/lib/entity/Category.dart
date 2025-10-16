enum Category { Laptop, Accessory }

extension CategoryExtension on Category {
  String toShortString() {
    return this.toString().split('.').last;
  }

  static Category fromString(String s) {
    return Category.values.firstWhere((e) => e.toString().split('.').last == s);
  }
}
