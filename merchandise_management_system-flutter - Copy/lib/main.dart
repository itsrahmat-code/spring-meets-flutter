import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:merchandise_management_system/pages/welcome_page.dart';
import 'package:merchandise_management_system/pages/login_page.dart';
import 'package:merchandise_management_system/pages/registration_page.dart';

import 'package:merchandise_management_system/service/cart_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // IMPORTANT: MaterialApp is below the providers
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const WelcomePage(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const Register(),
        // ManagerPage/ProductListPage etc. are pushed with MaterialPageRoute elsewhere
      },
    );
  }
}
