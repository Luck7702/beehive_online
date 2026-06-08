import 'package:flutter/material.dart';
import '../theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Brand logo
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: BeehiveColors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BeehiveColors.blue.withValues(alpha: 0.30),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.hive_rounded, size: 72, color: BeehiveColors.yellow),
              ),
              const SizedBox(height: 32),
              const Text(
                'BeeHive Online',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: BeehiveColors.ink),
              ),
              const SizedBox(height: 10),
              const Text(
                'Campus essentials, delivered to your room.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: BeehiveColors.muted, height: 1.4),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login_form'),
                  child: const Text('Log In'),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
