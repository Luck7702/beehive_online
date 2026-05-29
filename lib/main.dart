import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';

void main() {
  runApp(const CampusMinimartApp());
}

class CampusMinimartApp extends StatelessWidget {
  const CampusMinimartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniMart Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF1A73E8), // Correct Dart syntax for Blue
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A73E8),
          secondary: Color(0xFFF1F3F4),
          surface: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFFF8F9FA),
          elevation: 0,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
      },
    );
  }
}