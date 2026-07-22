import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/movere_button.dart';
import '../../../core/widgets/movere_text_field.dart';

/// Login screen (UI only — real authentication will be connected with
/// Firebase in Sprint 4; for now a successful login goes to a temporary home screen).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key to access the form's state (valid/invalid).
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    // Simple email check: one @ followed by a dot.
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
    return ok ? null : 'Enter a valid email';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    // validate(): runs the validators of all fields.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    // Fake wait until Sprint 4 — will become a real request once Firebase arrives.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Welcome back',
                      style: Theme.of(context).textTheme.displayMedium,),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text('Focus, progress, break free.',
                      style: Theme.of(context).textTheme.bodyMedium,),
                  const SizedBox(height: AppConstants.spacingXl),
                  MovereTextField(
                    label: 'Email',
                    controller: _emailController,
                    hint: 'you@movere.ai',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  MovereTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: _validatePassword,
                    textInputAction: TextInputAction.done,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Password reset will come with Firebase in Sprint 4.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Password reset will be added in Sprint 4.',),
                          ),
                        );
                      },
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  MovereButton(
                    label: 'Sign In',
                    isLoading: _loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No account yet?',
                          style: Theme.of(context).textTheme.bodyMedium,),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AppRoutes.register),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
