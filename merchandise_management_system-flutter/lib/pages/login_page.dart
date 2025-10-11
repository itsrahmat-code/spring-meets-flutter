import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:merchandise_management_system/pages/admin_page.dart';
import 'package:merchandise_management_system/pages/manager_page.dart';
import 'package:merchandise_management_system/service/admin_service.dart';
import 'package:merchandise_management_system/service/authservice.dart';
import 'package:merchandise_management_system/service/manager_service.dart';


class LoginPage extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _obscurePassword = true;

  final storage = new FlutterSecureStorage();
  AuthService authService = AuthService();
  ManagerService managerService = ManagerService();
  AdminService adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.00),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(
                labelText: "example@gamil.com",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_rounded),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: password,
              decoration: InputDecoration(
                labelText: "password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.password),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                loginUser(context);
              },
              child: Text(
                "Login",
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.orangeAccent,
              ),
            ),
            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Future<void> loginUser(BuildContext context) async {
    try {
      final response = await authService.login(email.text, password.text);

      // Successful login , role-based navigation
      final role = await authService.getUserRole();
      if (role == 'ADMIN') {
        final profile = await adminService
            .getAdminProfile();
        if(profile != null){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(profile: profile),
            ),
          );

        } else {
          print('Unknown role: $role');
        }
      } else if (role == 'MANAGER') {
        final profile = await managerService
            .getManagerProfile();
        if(profile != null){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ManagerPage(profile: profile),
            ),
          );

        } else {
          print('Unknown role: $role');
        }

      }
    }

    catch (error) {
      print('Login Failed: $error');
    }
  }
}
