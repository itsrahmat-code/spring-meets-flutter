// lib/services/product_service.dart


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merchandise_management_system/models/product_model.dart';


class ProductService {
  // Use your Spring Boot server's URL.
  // Assuming it's running locally on port 8080 and your device can access it.
  static const String _baseUrl = 'http://localhost:8085/api/product';
  // final String baseUrl = 'http://localhost:8085/api/product';
  // Helper method for standard request headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // GET: Fetch all products
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/all'));

    if (response.statusCode == 200) {
      // Decode the JSON list and map it to a List<Product>
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  // GET: Fetch product by ID
  Future<Product> getProductById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product with ID $id: ${response.statusCode}');
    }
  }

  // POST: Add a new product
  Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/add'),
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) { // Spring returns 200 OK
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add product: ${response.statusCode}');
    }
  }

  // PUT: Update an existing product
  Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/${product.id}'),
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) { // Spring returns 200 OK
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update product: ${response.statusCode}');
    }
  }

  // DELETE: Delete a product by ID
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode != 200) { // Spring returns 200 OK for success
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }
}