import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../entity/product.dart';

class ProductService {
  static const String baseUrl = 'http://localhost:8085/api/product'; // Update for production

  /// Fetch all products
  Future<List<product>> fetchProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      if (authToken == null) {
        throw Exception('Auth token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/all'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => product.fromJson(data)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  /// Create a new product
  Future<product> createProduct(product prod) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      if (authToken == null) {
        throw Exception('Auth token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(prod.toJson()),
      );

      if (response.statusCode == 200) {
        return product.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        throw Exception('Failed to create product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  /// Update an existing product
  Future<void> updateProduct(int id, product prod) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      if (authToken == null) {
        throw Exception('Auth token not found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(prod.toJson()),
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception('Unauthorized: Please log in again.');
        }
        throw Exception('Failed to update product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  /// Delete a product by ID
  Future<void> deleteProduct(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      if (authToken == null) {
        throw Exception('Auth token not found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception('Unauthorized: Please log in again.');
        }
        throw Exception('Failed to delete product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }
}
