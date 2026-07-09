import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/widget_showcase_screen.dart';

void main() {
  runApp(const ProviderScope(child: MovereApp()));
}

/// Tema tercihi. Varsayılan dark: Move Beyond kimliğinin doğal hali.
/// (Sprint 5'te Settings sayfasındaki anahtara bağlanacak.)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

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
      // Geçici giriş ekranı: design system vitrini.
      // Splash + Onboarding geldiğinde (12 Temmuz) buradan taşınacak.
      home: const WidgetShowcaseScreen(),
    );
  }
}
