import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'providers/cart_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/worker_bulletin_screen.dart';
import 'screens/worker_history_screen.dart';
import 'screens/order_history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const CampusMinimartApp());
}

class CampusMinimartApp extends StatelessWidget {
  const CampusMinimartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'BeeHive Online',
        debugShowCheckedModeBanner: false,
        theme: buildBeehiveTheme(),
        initialRoute: '/welcome',
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/login_form': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/worker_bulletin': (context) => const WorkerBulletinScreen(),
          '/worker_history': (context) => const WorkerHistoryScreen(),
          '/order_history': (context) => const OrderHistoryScreen(),
        },
      ),
    );
  }
}