import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/movere_button.dart';
import '../../../core/widgets/movere_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/profile_providers.dart';

/// Login screen — real Firebase Authentication (email/password).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Key to access the form's state (valid/invalid).
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _authError;

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

  /// Translates Firebase's error codes into short, human copy —
  /// the console-side message ("auth/wrong-password") is not something
  /// a user should ever see.
  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a moment.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Sign-in failed. Please try again.';
    }
  }

  Future<void> _submit() async {
    // validate(): runs the validators of all fields.
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _authError = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      // Real sign-in succeeded — mirror the email into SQLite too, so the
      // rest of the app (which reads the local profile store) stays in sync.
      await ref
          .read(profileProvider.notifier)
          .saveEmail(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
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
                  Text(AppLocalizations.of(context)!.loginWelcomeBack,
                      style: Theme.of(context).textTheme.displayMedium,),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(AppLocalizations.of(context)!.loginTagline,
                      style: Theme.of(context).textTheme.bodyMedium,),
                  const SizedBox(height: AppConstants.spacingXl),
                  MovereTextField(
                    label: AppLocalizations.of(context)!.loginEmailLabel,
                    controller: _emailController,
                    hint: 'you@movere.ai',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  MovereTextField(
                    label: AppLocalizations.of(context)!.loginPasswordLabel,
                    controller: _passwordController,
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: _validatePassword,
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        final email = _emailController.text.trim();
                        if (_validateEmail(email) != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Enter your email above first.',),
                            ),
                          );
                          return;
                        }
                        try {
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password reset email sent.'),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_authErrorMessage(e))),
                          );
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.loginForgotPassword),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  MovereButton(
                    label: AppLocalizations.of(context)!.loginSignIn,
                    isLoading: _loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.loginNoAccount,
                          style: Theme.of(context).textTheme.bodyMedium,),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AppRoutes.register),
                        child: Text(AppLocalizations.of(context)!.loginSignUp),
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
