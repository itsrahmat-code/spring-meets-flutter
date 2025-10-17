import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // REQUIRED: Import the provider package
import 'package:merchandise_management_system/pages/login_page.dart';
import 'package:merchandise_management_system/pages/registration_page.dart';
import 'package:merchandise_management_system/pages/welcome_page.dart';
import 'package:merchandise_management_system/service/cart_service.dart'; // REQUIRED: Import your CartService

void main() {
  // 1. Configure the state management service (CartService)
  // The entire application (MyApp) is wrapped to allow access to the CartService.
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // The nested main() function has been removed.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        // Corrected route: Using RegistrationPage as the registration screen
        '/register': (context) => const Manager(),
        // Note: The ManagerPage is typically used after login, not as a route name like /register
        // You may want to add '/manager' route if needed:
        // '/manager': (context) => const ManagerPage(),
      },
    );
  }
}
