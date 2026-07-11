import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/theme_provider.dart';
import '../constants/app_constants.dart';
import 'movere_button.dart';
import 'movere_card.dart';
import 'movere_loading.dart';
import 'movere_navigation.dart';
import 'movere_progress_ring.dart';
import 'movere_text_field.dart';

/// Geliştirme amaçlı vitrin ekranı: tüm design system bileşenlerini
/// tek yerde, light/dark modda görsel olarak doğrulamak için.
/// Gerçek ekranlar geldikçe main.dart'taki home buradan onlara taşınacak.
class WidgetShowcaseScreen extends ConsumerStatefulWidget {
  const WidgetShowcaseScreen({super.key});

  @override
  ConsumerState<WidgetShowcaseScreen> createState() =>
      _WidgetShowcaseScreenState();
}

class _WidgetShowcaseScreenState extends ConsumerState<WidgetShowcaseScreen> {
  int _tabIndex = 0;
  bool _demoLoading = false;

  void _simulateLoading() {
    setState(() => _demoLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _demoLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: MovereAppBar(
        title: 'Movere AI',
        actions: [
          // Tema anahtarı: Riverpod'daki themeModeProvider'ı değiştirir,
          // MaterialApp bunu izlediği için TÜM uygulama anında tema değiştirir.
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          Text('Buttons', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppConstants.spacingSm),
          MovereButton(
            label: 'Primary Button',
            icon: Icons.play_arrow,
            onPressed: _simulateLoading,
            isLoading: _demoLoading,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          MovereButton(
            label: 'Secondary Button',
            variant: MovereButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: AppConstants.spacingSm),
          MovereButton(
            label: 'Text Button',
            variant: MovereButtonVariant.text,
            fullWidth: false,
            onPressed: () {},
          ),
          const SizedBox(height: AppConstants.spacingLg),

          Text('Cards', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppConstants.spacingSm),
          // Tasarımdaki "Bugünkü odak süren" kartının component demosu.
          // Sprint 2'de dashboard bu kartı gerçek verilerle kuracak.
          MovereCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Focus time today',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text('1h 20m',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              )),
                      const SizedBox(height: 4),
                      Text('Goal: 3h 30m',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: AppConstants.spacingSm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: const LinearProgressIndicator(
                            value: 0.72, minHeight: 6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                const MovereProgressRing(progress: 0.72, label: 'Progress'),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          MovereCard(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Focus Time',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('You focused for 45 minutes today.',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),

          Text('Form Fields',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppConstants.spacingSm),
          const MovereTextField(
            label: 'Email',
            hint: 'you@movere.ai',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          const MovereTextField(
            label: 'Password',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: AppConstants.spacingLg),

          Text('Loading States',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppConstants.spacingSm),
          const MovereCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MovereSkeleton(width: 140, height: 18),
                SizedBox(height: 10),
                MovereSkeleton(height: 14),
                SizedBox(height: 6),
                MovereSkeleton(width: 220, height: 14),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          const SizedBox(height: 80, child: MovereLoading(message: 'Loading...')),
        ],
      ),
      bottomNavigationBar: MovereBottomNav(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}
