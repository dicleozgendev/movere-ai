import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/movere_card.dart';
import '../../../core/widgets/movere_navigation.dart';
import '../../../core/widgets/movere_progress_ring.dart';

/// Giriş sonrası ana ekran: üst bar + sekmeler + Dashboard içeriği.
/// Yalnızca Dashboard sekmesi gerçek; diğerleri kendi sprint'lerinde
/// dolacak dürüst yer tutucular. Veriler şimdilik örnek — gerçekleri
/// Sprint 4'te (SQLite) bağlanacak.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Showcase'teki tema anahtarının aynısı, artık asıl evinde.
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: MovereAppBar(
        title: 'Movere AI',
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).state =
                isDark ? ThemeMode.light : ThemeMode.dark,
          ),
        ],
      ),
      body: SafeArea(
        // IndexedStack: sekmeler hazır durur, sadece seçili olan görünür;
        // geçişlerde ekran durumu (scroll vb.) kaybolmaz.
        child: IndexedStack(
          index: _tabIndex,
          children: const [
            _DashboardTab(),
            _PlaceholderTab(
              icon: Icons.timer_outlined,
              title: 'Focus Mode',
              note: 'Coming later this sprint — focus timer and session summary.',
            ),
            _PlaceholderTab(
              icon: Icons.insights_outlined,
              title: 'Progress',
              note: 'Detailed analytics arrive in Sprint 5.',
            ),
            _PlaceholderTab(
              icon: Icons.school_outlined,
              title: 'Academy',
              note: 'Lessons and podcasts arrive in Sprint 3.',
            ),
            _PlaceholderTab(
              icon: Icons.settings_outlined,
              title: 'Settings',
              note: 'Profile and preferences arrive in Sprint 5.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: MovereBottomNav(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}

/// Dashboard sekmesi — tasarımdaki ana ekran.
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingMd,
        AppConstants.spacingLg,
        AppConstants.spacingLg,
      ),
      children: [
        // --- Karşılama ---
        Text('Welcome back', style: textTheme.displayMedium),
        const SizedBox(height: 4),
        Text('Focus, progress, break free.', style: textTheme.bodyMedium),
        const SizedBox(height: AppConstants.spacingLg),

        // --- Bugünkü odak kartı ---
        MovereCard(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Focus time today', style: textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      '1h 20m',
                      style: textTheme.displayMedium?.copyWith(color: primary),
                    ),
                    const SizedBox(height: 4),
                    Text('Goal: 3h 30m', style: textTheme.bodyMedium),
                    const SizedBox(height: AppConstants.spacingMd),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: const LinearProgressIndicator(
                        value: 0.38,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              const MovereProgressRing(progress: 0.38, label: 'Progress'),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // --- Günlük mini istatistikler (Sprint 2 backlog: daily statistics) ---
        Row(
          children: const [
            Expanded(
              child: _StatCard(
                icon: Icons.block,
                value: '12',
                label: 'Distractions\nblocked today',
              ),
            ),
            SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_outlined,
                value: '4 days',
                label: 'Focus\nstreak',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // --- Hızlı aksiyonlar ---
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.track_changes,
                title: 'Daily Goals',
                subtitle: '3 / 5 done',
                onTap: () => _notYet(context, 'Daily goals'),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: _QuickAction(
                icon: Icons.trending_up,
                title: 'My Progress',
                subtitle: 'Weekly view',
                onTap: () => _notYet(context, 'Progress analytics'),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: _QuickAction(
                icon: Icons.psychology,
                title: 'Deep Focus',
                subtitle: 'Start now',
                onTap: () => _notYet(context, 'Focus Mode'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // --- Reality Score kartı (Sprint 2 backlog: Reality Score card) ---
        MovereCard(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Row(
            children: [
              const MovereProgressRing(progress: 0.72, label: 'Score'),
              const SizedBox(width: AppConstants.spacingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reality Score', style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Your digital balance is improving. '
                      'Keep your streak going.',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // --- Alıntı kartı ---
        MovereCard(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote, color: primary, size: 28),
              const SizedBox(height: AppConstants.spacingSm),
              Text('"What you focus on, expands."',
                  style: textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }

  static void _notYet(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is on the way — see the sprint plan.')),
    );
  }
}

/// Küçük istatistik kartı: ikon + değer + etiket.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return MovereCard(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 26),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge),
                Text(label,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hızlı aksiyon kartı: ikon + başlık + alt yazı, tıklanabilir.
class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return MovereCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingMd,
        horizontal: AppConstants.spacingSm,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary, size: 24),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// Henüz gelmemiş sekmeler için dürüst yer tutucu.
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.note,
  });

  final IconData icon;
  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppConstants.spacingMd),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              note,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
