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
            children: [
              const Spacer(),
              // Brand logo
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  gradient: BeehiveColors.brandGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BeehiveColors.blue.withValues(alpha: 0.35),
                      blurRadius: 36,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.hive_rounded, size: 68, color: Colors.white),
              ),
              const SizedBox(height: 36),
              const Text(
                'BeeHive Online',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: BeehiveColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Campus essentials, delivered\nstraight to your room.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: BeehiveColors.muted, height: 1.5),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
