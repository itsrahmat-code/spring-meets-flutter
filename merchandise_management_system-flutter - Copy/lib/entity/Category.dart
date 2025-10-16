// File: lib/models/category_enum.dart

enum Category {
  Laptop,
  Accessory,
}

Category stringToCategory(String category) {
  switch (category.toLowerCase()) {
    case 'laptop':
      return Category.Laptop;
    case 'accessory':
      return Category.Accessory;
    default:
      throw Exception('Unknown category: $category');
  }
}

String categoryToString(Category category) {
  switch (category) {
    case Category.Laptop:
      return 'Laptop';
    case Category.Accessory:
      return 'Accessory';
  }
}