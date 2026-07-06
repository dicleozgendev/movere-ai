import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MovereApp()));
}

/// Dark mode tercihini tutan basit bir provider (Sprint 10'da Settings'e bağlanacak)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

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
      home: const _PlaceholderSplash(),
    );
  }
}

/// Sprint 3'te gerçek Splash Screen ile değiştirilecek geçici ekran.
class _PlaceholderSplash extends StatelessWidget {
  const _PlaceholderSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Movere AI', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text(
              'Sprint 1: Proje kurulumu tamamlandı ✅',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
