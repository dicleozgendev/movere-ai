import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/movere_navigation.dart';
import '../../../core/widgets/movere_button.dart';
import '../../../core/widgets/movere_text_field.dart';
import '../application/profile_providers.dart';

/// Register screen — real Firebase account creation (email/password).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _authError;

  String? _validateName(String? v) =>
      (v == null || v.trim().length < 2) ? 'Enter your name' : null;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email';
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // The password confirmation must be the SAME as the first password field.
  String? _validateConfirm(String? v) =>
      v != _passwordController.text ? 'Passwords do not match' : null;

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Could not create the account. Please try again.';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _authError = null;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Attach the display name — nice to have, and ready for Settings
      // (Sprint 5) to show it without any extra plumbing.
      await credential.user?.updateDisplayName(_nameController.text.trim());
      if (!mounted) return;
      // Same pattern as login: mirror the email into SQLite too, so the
      // rest of the app (which reads the local profile store) stays in sync.
      await ref
          .read(profileProvider.notifier)
          .saveEmail(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created, you can sign in now.')),
      );
      Navigator.of(context).pop(); // go back to Login
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _authError = _authErrorMessage(e);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _authError = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MovereAppBar(title: 'Create Account'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MovereTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  hint: 'Your full name',
                  prefixIcon: Icons.person_outline,
                  validator: _validateName,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppConstants.spacingMd),
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
                  hint: 'At least 6 characters',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: _validatePassword,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppConstants.spacingMd),
                MovereTextField(
                  label: 'Confirm Password',
                  controller: _confirmController,
                  hint: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: _validateConfirm,
                  textInputAction: TextInputAction.done,
                ),
                if (_authError != null) ...[
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    _authError!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: AppConstants.spacingXl),
                MovereButton(
                  label: 'Sign Up',
                  isLoading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
