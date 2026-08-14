import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/media/onboarding_video_preloader.dart';
import '../../../core/theme/app_colors.dart';

/// Splash screen: brand identity + automatic transition after 4s.
/// If a Firebase session is already open (the user signed in before and
/// never signed out), skip straight to the Dashboard — otherwise go to
/// Onboarding as before.
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
    // Use the 4s wait we already have to start loading Onboarding's
    // Focus video now, instead of Onboarding paying that cost cold on
    // its very first frame (Sprint: Finalization perf pass).
    OnboardingVideoPreloader.warm('assets/onboarding/focus.mp4');
    // The screen is visible for 2.5s, then REPLACES itself with Onboarding.
    // pushReplacement: we use this instead of push so the back button can't return to splash
    // — splash is removed entirely from the stack.
    _timer = Timer(const Duration(milliseconds: 4000), () {
      if (!mounted) return;
      // Guarded: in widget tests Firebase isn't initialized, so this would
      // throw — falling back to Onboarding in that case is the safe and
      // correct behaviour anyway (no real session exists there either).
      User? user;
      try {
        user = FirebaseAuth.instance.currentUser;
      } catch (_) {
        user = null;
      }
      Navigator.of(context).pushReplacementNamed(
        user != null ? AppRoutes.dashboard : AppRoutes.onboarding,
      );
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
              // Brand logo — circular, on the theme background.
              Image.asset(
                'assets/branding/logo.png',
                width: 175,
                height: 175,
              ),
              const SizedBox(height: AppConstants.spacingMd),
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
