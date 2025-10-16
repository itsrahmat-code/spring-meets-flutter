// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// import 'authservice.dart';
//
// class ApplicationService {
//   static const String baseUrl = 'http://localhost:8085/api/applications/my';
//
//   Future<List<JobApplication>> fetchApplications() async {
//     // 1️⃣ Get token from AuthService
//     String? token = await AuthService().getToken();
//
//     // 2️⃣ Call API with Authorization header
//     final response = await http.get(
//       Uri.parse(baseUrl),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     // 3️⃣ Handle response
//     if (response.statusCode == 200) {
//       List<dynamic> data = jsonDecode(response.body);
//       return data.map((json) => JobApplication.fromJson(json)).toList();
//     } else if (response.statusCode == 401) {
//       throw Exception('Unauthorized: Invalid or expired token');
//     } else {
//       throw Exception('Failed to load applications (${response.statusCode})');
//     }
//   }
// }