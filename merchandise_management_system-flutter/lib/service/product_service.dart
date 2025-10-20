import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:merchandise_management_system/models/product_model.dart';




class ProductService {
  // Replace with your actual base URL and port
  final String baseUrl = 'http://localhost:8085/api/product';

  final Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // 1. Read All
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/all'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products. Status: ${response.statusCode}');
    }
  }

  // 2. Read One by ID
  Future<Product> getProductById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product $id. Status: ${response.statusCode}');
    }
  }

  // 3. Create (Add)
  Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: headers,
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add product. Status: ${response.statusCode}');
    }
  }

  // 4. Update
  Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${product.id}'),
      headers: headers,
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update product ${product.id}. Status: ${response.statusCode}');
    }
  }

  // 5. Delete
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product $id. Status: ${response.statusCode}');
    }
  }
}