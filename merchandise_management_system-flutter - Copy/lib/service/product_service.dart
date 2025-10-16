import 'dart:convert';
import 'package:http/http.dart' as http;

import '../entity/product.dart';


class ProductService {
  final String baseUrl;

  ProductService({required this.baseUrl});

  Future<List<Product>> fetchAllProducts() async {
    final url = Uri.parse('$baseUrl/api/product/all');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> list = json.decode(response.body);
      return list.map((jsonItem) => Product.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  Future<Product> fetchProductById(int id) async {
    final url = Uri.parse('$baseUrl/api/product/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product id $id');
    }
  }

  Future<Product> addProduct(Product p) async {
    final url = Uri.parse('$baseUrl/api/product/add');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(p.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add product: ${response.statusCode}');
    }
  }

  Future<Product> updateProduct(int id, Product p) async {
    final url = Uri.parse('$baseUrl/api/product/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(p.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update product: ${response.statusCode}');
    }
  }

  Future<void> deleteProduct(int id) async {
    final url = Uri.parse('$baseUrl/api/product/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }
}
