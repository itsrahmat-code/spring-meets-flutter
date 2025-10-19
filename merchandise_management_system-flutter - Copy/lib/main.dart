import 'package:flutter/material.dart';
import 'package:merchandise_management_system/pages/login_page.dart';
import 'package:merchandise_management_system/pages/registration_page.dart';
import 'package:merchandise_management_system/pages/welcome_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const Manager(), // Registration screen
      },
    );
  }
}
