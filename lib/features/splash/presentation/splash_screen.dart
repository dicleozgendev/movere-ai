import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Splash screen: brand identity + automatic transition to Onboarding after 2.5s.
/// (Later: if the user has seen onboarding before, go straight to login,
/// if a session is open, go to dashboard — coming in Sprint 4 with sessions.)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Opacity animation for a soft fade-in of the logo and tagline.
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // The screen is visible for 2.5s, then REPLACES itself with Onboarding.
    // pushReplacement: we use this instead of push so the back button can't return to splash
    // — splash is removed entirely from the stack.
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // if the screen closes early, don't let the timer fire uselessly
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark, // splash her zaman koyu
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Temporary typographic logo — once the 3D logo PNG arrives,
              // Image.asset(...) will be placed here.
              ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  colors: AppColors.brandGradient,
                ).createShader(rect),
                child: Text(
                  'MOVERE',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white, // ShaderMask paints the gradient on top of this
                        letterSpacing: 10,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                'MOVE BEYOND',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 6,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
