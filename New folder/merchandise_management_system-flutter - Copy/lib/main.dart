import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:merchandise_management_system/pages/login_page.dart';
import 'package:merchandise_management_system/pages/registration_page.dart';
import 'package:merchandise_management_system/pages/welcome_page.dart';
import 'package:merchandise_management_system/service/cart_service.dart';
import 'package:merchandise_management_system/service/stock_alert_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => StockAlertService(
          // tweak defaults here if you want
          defaultLowThreshold: 5,
          defaultMaxCapacity: 100,
        )),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomePage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const Register(),
        },
      ),
    );
  }
}
