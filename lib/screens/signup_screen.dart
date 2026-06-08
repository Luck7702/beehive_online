import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nimController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    if (_nimController.text.isEmpty || _fullNameController.text.isEmpty ||
        _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill mandatory fields')));
      return;
    }

    setState(() => _isLoading = true);

    final userData = {
      'nim': _nimController.text,
      'name': _fullNameController.text,
      'email': _emailController.text,
      'phone_number': _mobileController.text,
      'password': _passwordController.text,
    };

    final success = await ApiService.signup(userData);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please log in.')),
      );
      Navigator.pushReplacementNamed(context, '/login_form');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed. NIM or Email might already exist.')));
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: BeehiveColors.ink),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign up to get started.',
                style: TextStyle(color: BeehiveColors.muted, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 30),

              _buildTextField(controller: _nimController, label: 'Student ID (NIM)'),
              _buildTextField(controller: _fullNameController, label: 'Full Name'),
              _buildTextField(controller: _emailController, label: 'Email', keyboardType: TextInputType.emailAddress),
              _buildTextField(controller: _mobileController, label: 'Mobile Number', keyboardType: TextInputType.phone),
              _buildTextField(controller: _passwordController, label: 'Set Password', obscureText: true),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Sign Up'),
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
