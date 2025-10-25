import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merchandise_management_system/models/product_model.dart';

class ProductService {

  static const String _baseUrl = 'http://localhost:8085/api/product';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/all'));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Product.fromJson(e)).toList();
    }
    throw Exception('Failed to load products: ${response.statusCode}');
  }

  Future<Product> getProductById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load product $id: ${response.statusCode}');
  }

  Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/add'),
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to add product: ${response.statusCode}');
  }

  Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/${product.id}'),
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update product: ${response.statusCode}');
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }
}
