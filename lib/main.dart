import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/insights/presentation/usage_demo_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

Future<void> main() async {
  // Firebase must be ready before any screen tries to use FirebaseAuth —
  // this reads the native GoogleService-Info.plist (iOS) / google-services.json
  // (Android) that was registered in the Firebase console.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MovereApp()));
}

class MovereApp extends ConsumerWidget {
  const MovereApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Movere AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // Flow: Splash -> Onboarding -> Login -> (temporary home screen)
      home: const SplashScreen(),
      routes: {
        // Route names in one place: AppRoutes (app_constants.dart).
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        // Main screen after login: Dashboard (Sprint 2).
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.usageDemo: (_) => const UsageDemoScreen(),
      },
    );
  }
}
