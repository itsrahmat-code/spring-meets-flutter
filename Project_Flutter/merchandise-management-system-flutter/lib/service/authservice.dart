import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService{
  final String baseUrl = "http://localhost:8085";

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password' : password});
    final response = await http.post(url, headers: headers, body: body);

    if(response.statusCode == 200 || response.statusCode == 201 ) {
      final data = jsonDecode(response.body);
      String token = data['token'];

      Map<String , dynamic> payload = Jwt.parseJwt(token);
      String role = payload['role'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      await prefs.setString('userRole', role);

      return true;

    }
    else {
      print('Failed to log in : ${response.body}');
      return false;
    }
  }

  Future<bool> registerAdminWeb({
    required Map<String , dynamic> user,
    required Map<String , dynamic> admin,
    File? photoFile,
    Uint8List? photoBytes,
  }) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/admin/reg')
    );
    request.fields['user'] = jsonEncode(user);
    request.fields['admin'] = jsonEncode(admin);


    // If photoBytes is available (e.g., from web image picker)
    if( photoBytes != null){
      request.files.add(http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: 'profile.png'
      ));
    }
    // If photoFile is provided (mobile/desktop), attach it
    else if(photoFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photoFile.path
      ));
    }

    var response = await request.send();
    return response.statusCode == 200;

  }




  Future<bool> registerManagerWeb({
    required Map<String , dynamic> user,
    required Map<String , dynamic> manager,
    File? photoFile,
    Uint8List? photoBytes,
  }) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/manager/reg')
    );
    request.fields['user'] = jsonEncode(user);
    request.fields['manager'] = jsonEncode(manager);


    // If photoBytes is available (e.g., from web image picker)
    if( photoBytes != null){
      request.files.add(http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: 'profile.png'
      ));
    }
    // If photoFile is provided (mobile/desktop), attach it
    else if(photoFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photoFile.path
      ));
    }

    var response = await request.send();
    return response.statusCode == 200;

  }

  Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('userRole'));
    return prefs.getString('userRole');
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<bool> isTokenExpired() async {
    String? token = await getToken();
    if(token != null) {
      DateTime expiryDate = Jwt.getExpiryDate(token)! ;
      return DateTime.now().isAfter(expiryDate);
    }
    return true;
  }

  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    if(token != null && !(await isTokenExpired())) {
      return true;
    } else {
      await logout();
      return false;
    }

  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userRole');
  }

  Future<bool> hasRole(List<String> roles) async {
    String? role = await getUserRole();
    return role != null && roles.contains(role);
  }
}