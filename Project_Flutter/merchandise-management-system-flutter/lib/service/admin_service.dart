import 'dart:convert';


import 'package:http/http.dart' as http;
import 'package:merchandise_management_system/service/authservice.dart';





class AdminService {
  final String baseUrl =  "http://localhost:8085";

  Future<Map<String , dynamic>?> getAdminProfile() async {
    String? token = await AuthService().getToken();

    if(token == null) {
      print('Token Not Found, Please login first.');
      return null;
    }
    final url = Uri.parse('$baseUrl/api/admin/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization' : 'Bearer $token',
        'Content-Type' : 'application/json'
      },
    );
    if(response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load profile : ${response.statusCode} - ${response.body}');
      return null;
    }




  }

}