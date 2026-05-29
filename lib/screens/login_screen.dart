import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4), // Light gray container
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.bolt, size: 36, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to order straight to your classroom.',
                style: TextStyle(color: Colors.black54, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 40),
              
              TextField(
                controller: _nimController,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'NIM / Student ID',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: const Color(0xFFF1F3F4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: const Color(0xFFF1F3F4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}