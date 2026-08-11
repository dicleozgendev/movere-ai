import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/movere_card.dart';
import '../../../core/widgets/movere_progress_ring.dart';
import '../../auth/application/profile_providers.dart';
import '../../focus/application/focus_providers.dart';
import '../../academy/presentation/academy_screen.dart';
import '../../focus/presentation/focus_screen.dart';
import '../../progress/presentation/progress_screen.dart';
import '../../reality_score/application/reality_score_provider.dart';
import '../../recommendations/application/recommendation_provider.dart';
import '../../recommendations/presentation/ai_insights_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../l10n/app_localizations.dart';

/// Main screen after login: a floating 3-item nav (Home / AI / Academy),
/// a hamburger drawer for the rest (Progress, Usage, theme, Settings), and
/// the Dashboard content. All five destinations still live in one
/// IndexedStack so their state is preserved; the bar and drawer just move
/// between them.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tabIndex = 0;

  void _goTo(int i) => setState(() => _tabIndex = i);

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Notifications',
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none),
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications arrive in a later sprint.'),
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Menu',
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _AppDrawer(
        isDark: isDark,
        onProgress: () => _goTo(2),
        onSettings: () => _goTo(4),
        onUsage: () => Navigator.of(context).pushNamed(AppRoutes.usageDemo),
        onToggleTheme: () => ref.read(themeModeProvider.notifier).state =
            isDark ? ThemeMode.light : ThemeMode.dark,
      ),
      body: SafeArea(
        // IndexedStack: tabs stay ready, only the selected one is visible;
        // screen state (scroll etc.) isn't lost across transitions.
        child: IndexedStack(
          index: _tabIndex,
          children: [
            _DashboardTab(
              onDeepFocus: () => _goTo(1),
              onMyProgress: () => _goTo(2),
              onAcademy: () => _goTo(3),
              onOpenAi: () => _goTo(5),
            ),
            const FocusScreen(),
            const ProgressScreen(),
            const AcademyScreen(),
            const SettingsScreen(),
            AiInsightsScreen(onGoToTab: _goTo),
          ],
        ),
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _tabIndex,
        onSelect: _goTo,
      ),
    );
  }
}

/// The hamburger drawer: everything that isn't one of the three main tabs.
class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.isDark,
    required this.onProgress,
    required this.onSettings,
    required this.onUsage,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onProgress;
  final VoidCallback onSettings;
  final VoidCallback onUsage;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget tile(IconData icon, String label, VoidCallback action) {
      return ListTile(
        leading: Icon(icon),
        title: Text(label, style: textTheme.bodyLarge),
        onTap: () {
          Navigator.pop(context); // close the drawer first
          action();
        },
      );
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Row(
                children: [
                  Image.asset('assets/branding/logo.png', width: 36, height: 36),
                  const SizedBox(width: AppConstants.spacingSm),
                  Text('Movere AI', style: textTheme.titleLarge),
                ],
              ),
            ),
            const Divider(),
            tile(Icons.insights_outlined, AppLocalizations.of(context)!.dashboardProgress, onProgress),
            tile(Icons.query_stats, AppLocalizations.of(context)!.dashboardUsageInsights, onUsage),
            tile(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              isDark
                  ? AppLocalizations.of(context)!.dashboardLightMode
                  : AppLocalizations.of(context)!.dashboardDarkMode,
              onToggleTheme,
            ),
            const Divider(),
            tile(Icons.settings_outlined, AppLocalizations.of(context)!.dashboardSettings, onSettings),
          ],
        ),
      ),
    );
  }
}

/// The floating, rounded 3-item bar from the design: Home · AI · Academy.
/// The centre "AI" is the brand-logo focus launcher and sits a little higher.
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppConstants.spacingLg,
          0,
          AppConstants.spacingLg,
          AppConstants.spacingSm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingSm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: AppLocalizations.of(context)!.dashboardHome,
              selected: currentIndex == 0,
              color: primary,
              muted: muted,
              onTap: () => onSelect(0),
            ),
            _CenterNavItem(
              label: 'AI',
              selected: currentIndex == 5,
              color: primary,
              muted: muted,
              onTap: () => onSelect(5),
            ),
            _NavItem(
              icon: Icons.school_outlined,
              activeIcon: Icons.school,
              label: AppLocalizations.of(context)!.dashboardAcademy,
              selected: currentIndex == 3,
              color: primary,
              muted: muted,
              onTap: () => onSelect(3),
            ),
          ],
        ),
      ),
    );
  }
}

/// A side item in the floating bar: icon + label.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.color,
    required this.muted,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final Color color;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = selected ? color : muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? activeIcon : icon, color: c, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: c,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The centre "AI" item: the brand logo in a glowing ring, slightly raised.
class _CenterNavItem extends StatelessWidget {
  const _CenterNavItem({
    required this.label,
    required this.selected,
    required this.color,
    required this.muted,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: selected ? 0.18 : 0.10),
              border: Border.all(
                color: color.withValues(alpha: selected ? 0.6 : 0.3),
                width: 1.2,
              ),
            ),
            child: Image.asset('assets/branding/logo.png', width: 26, height: 26),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? color : muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashboard tab — the main screen from the design (Turkish, matches the
/// mockup): focus launcher, greeting, today's focus card, quick actions,
/// and a quote. The focus card reads real session data from Focus Mode.
/// Maps a [RealityScoreBand] to its localized message — kept as a plain
/// function (not inside the data class) because it needs a BuildContext
/// for AppLocalizations, which the data class deliberately doesn't carry.
String _realityScoreMessage(BuildContext context, RealityScoreBand band) {
  final t = AppLocalizations.of(context)!;
  return switch (band) {
    RealityScoreBand.strong => t.realityScoreStrong,
    RealityScoreBand.good => t.realityScoreGood,
    RealityScoreBand.slow => t.realityScoreSlow,
    RealityScoreBand.none => t.realityScoreNone,
  };
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab({
    required this.onDeepFocus,
    required this.onMyProgress,
    required this.onAcademy,
    required this.onOpenAi,
  });

  final VoidCallback onDeepFocus;
  final VoidCallback onMyProgress;
  final VoidCallback onAcademy;
  final VoidCallback onOpenAi;

  static const int _dailyGoalMinutes = 210; // 3h 30m

  /// Duration format: "2h 43m" / "43m".
  String _format(int m) =>
      m >= 60 ? '${m ~/ 60}h ${m % 60}m' : '${m}m';

  /// First name from the stored email ("mehmet.ozgen@..." -> "Mehmet").
  String _firstName(String? email) {
    if (email == null || email.isEmpty) return '';
    final parts = email
        .split('@')
        .first
        .split(RegExp(r'[._\-]+'))
        .where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    final first = parts.first;
    return first[0].toUpperCase() + first.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    final todayMinutes = ref.watch(todayFocusMinutesProvider);
    final name = _firstName(ref.watch(profileProvider));
    final goalProgress =
        (todayMinutes / _dailyGoalMinutes).clamp(0.0, 1.0).toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingSm,
        AppConstants.spacingLg,
        AppConstants.spacingLg,
      ),
      children: [
        // --- Focus launcher hero (7-segment timer + play) ---
        _FocusHeroCard(onStart: onDeepFocus),
        const SizedBox(height: AppConstants.spacingLg),

        // --- Greeting ---
        Text(
          name.isEmpty
              ? AppLocalizations.of(context)!.dashboardWelcomeBack
              : '${AppLocalizations.of(context)!.dashboardWelcomeBack}, $name',
          style: textTheme.displayMedium,
        ),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context)!.dashboardTagline, style: textTheme.bodyMedium),
        const SizedBox(height: AppConstants.spacingLg),

        // --- Today's focus card ---
        MovereCard(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.dashboardFocusTimeToday, style: textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      _format(todayMinutes),
                      style: textTheme.displayMedium?.copyWith(color: primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.of(context)!.dashboardGoalPrefix}${_format(_dailyGoalMinutes)}',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: goalProgress,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              MovereProgressRing(progress: goalProgress, label: AppLocalizations.of(context)!.dashboardProgress),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // --- Quick actions ---
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.track_changes,
                title: AppLocalizations.of(context)!.dashboardDailyGoals,
                subtitle: '3 / 5 done',
                onTap: () => _notYet(context, 'Daily goals'),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: _QuickAction(
                icon: Icons.trending_up,
                title: AppLocalizations.of(context)!.dashboardMyProgress,
                subtitle: AppLocalizations.of(context)!.dashboardWeeklyView,
                onTap: onMyProgress,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: _QuickAction(
                icon: Icons.psychology,
                title: AppLocalizations.of(context)!.dashboardDeepFocus,
                subtitle: AppLocalizations.of(context)!.dashboardStartNow,
                onTap: onDeepFocus,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // --- Reality Score: a real, computed number (Sprint 5) ---
        Builder(builder: (context) {
          final score = ref.watch(realityScoreProvider);
          return MovereCard(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Row(
              children: [
                MovereProgressRing(
                  progress: score.value / 100,
                  label: AppLocalizations.of(context)!.dashboardScoreLabel,
                ),
                const SizedBox(width: AppConstants.spacingLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.dashboardRealityScore, style: textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(_realityScoreMessage(context, score.band), style: textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          );
        },),
        const SizedBox(height: AppConstants.spacingMd),

        // --- AI Assistant teaser: full detail lives on the AI tab ---
        Builder(builder: (context) {
          final top = ref.watch(topRecommendationProvider);
          final topText = insightText(AppLocalizations.of(context)!, top);
          return MovereCard(
            onTap: onOpenAi,
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: AppColors.brandGradient),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 20,),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.aiAssistantLabel, style: textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(topText.title,
                          style: textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: textTheme.labelSmall?.color,),
              ],
            ),
          );
        },),
        const SizedBox(height: AppConstants.spacingMd),

        // --- Quote card ---
        MovereCard(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote, color: primary, size: 28),
              const SizedBox(height: AppConstants.spacingSm),
              Text(AppLocalizations.of(context)!.dashboardQuote,
                  style: textTheme.titleMedium,),
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

/// The digital "focus launcher" at the top of the dashboard — a preview of
/// the timer with a play button that jumps straight into Focus Mode. The
/// +/- steppers adjust the previewed duration; the real session is started
/// and configured on the Focus screen.
class _FocusHeroCard extends StatefulWidget {
  const _FocusHeroCard({required this.onStart});

  final VoidCallback onStart;

  @override
  State<_FocusHeroCard> createState() => _FocusHeroCardState();
}

class _FocusHeroCardState extends State<_FocusHeroCard> {
  int _minutes = 30;

  void _bump(int delta) {
    setState(() => _minutes = (_minutes + delta).clamp(5, 120));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final time = '${_minutes.toString().padLeft(2, '0')}:00';

    return MovereCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingLg,
        horizontal: AppConstants.spacingLg,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SevenSegmentClock(
                text: time,
                onColor: primary,
                offColor: primary.withValues(alpha: 0.12),
                height: 64,
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepperButton(icon: Icons.add, onTap: () => _bump(5)),
                  const SizedBox(height: AppConstants.spacingSm),
                  _StepperButton(icon: Icons.remove, onTap: () => _bump(-5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.dashboardAppBlockingSoon),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.dashboardBlockedApp,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.add, size: 18, color: primary),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          // Play -> jump into Focus Mode to actually run the session.
          GestureDetector(
            onTap: widget.onStart,
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.14),
                border: Border.all(
                  color: primary.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Icon(Icons.play_arrow_rounded, color: primary, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small round +/- stepper used by the focus hero card.
class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: primary.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, size: 18, color: primary),
      ),
    );
  }
}

/// Quick action card: icon + title + subtitle, tappable.
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

/// An exact 7-segment digital clock, drawn with a CustomPainter so it matches
/// the alarm-clock look in the design: lit segments are bright, the unlit
/// "ghost" segments stay faintly visible behind them. Scales to fit via
/// FittedBox, so [height] just sets the on-screen size.
class _SevenSegmentClock extends StatelessWidget {
  const _SevenSegmentClock({
    required this.text,
    required this.onColor,
    required this.offColor,
    this.height = 64,
  });

  final String text;
  final Color onColor;
  final Color offColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final painter = _SevenSegPainter(
      text: text,
      onColor: onColor,
      offColor: offColor,
    );
    return SizedBox(
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: painter.intrinsicWidth,
          height: painter.intrinsicHeight,
          child: CustomPaint(painter: painter),
        ),
      ),
    );
  }
}

class _SevenSegPainter extends CustomPainter {
  _SevenSegPainter({
    required this.text,
    required this.onColor,
    required this.offColor,
  });

  final String text;
  final Color onColor;
  final Color offColor;

  // Digit geometry in design units; FittedBox scales the whole thing to fit.
  static const double _digitW = 46;
  static const double _digitH = 84;
  static const double _thick = 9;
  static const double _gap = 12;
  static const double _colonW = 22;

  // Which of the 7 segments (a,b,c,d,e,f,g) light up for each digit.
  static const Map<String, List<bool>> _segmentMap = {
    '0': [true, true, true, true, true, true, false],
    '1': [false, true, true, false, false, false, false],
    '2': [true, true, false, true, true, false, true],
    '3': [true, true, true, true, false, false, true],
    '4': [false, true, true, false, false, true, true],
    '5': [true, false, true, true, false, true, true],
    '6': [true, false, true, true, true, true, true],
    '7': [true, true, true, false, false, false, false],
    '8': [true, true, true, true, true, true, true],
    '9': [true, true, true, true, false, true, true],
  };

  double get intrinsicWidth {
    var w = 0.0;
    for (var i = 0; i < text.length; i++) {
      w += text[i] == ':' ? _colonW : _digitW;
      if (i != text.length - 1) w += _gap;
    }
    return w;
  }

  double get intrinsicHeight => _digitH;

  @override
  void paint(Canvas canvas, Size size) {
    var x = 0.0;
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      if (ch == ':') {
        _drawColon(canvas, x);
        x += _colonW + _gap;
      } else {
        _drawDigit(canvas, x, ch);
        x += _digitW + _gap;
      }
    }
  }

  void _drawColon(Canvas canvas, double x) {
    final paint = Paint()..color = onColor;
    final cx = x + _colonW / 2;
    const r = _thick / 2;
    canvas.drawCircle(Offset(cx, _digitH * 0.34), r, paint);
    canvas.drawCircle(Offset(cx, _digitH * 0.66), r, paint);
  }

  void _drawDigit(Canvas canvas, double x, String ch) {
    final segs = _segmentMap[ch] ?? List<bool>.filled(7, false);
    const t = _thick;
    const w = _digitW;
    const h = _digitH;
    const hLen = w - 2 * t; // horizontal segment length
    const vLen = (h - 3 * t) / 2; // vertical segment length

    // Order matches _segmentMap: a, b, c, d, e, f, g.
    final rects = <RRect>[
      _rr(x + t, 0, hLen, t), // a - top
      _rr(x + w - t, t, t, vLen), // b - top right
      _rr(x + w - t, t + vLen + t, t, vLen), // c - bottom right
      _rr(x + t, h - t, hLen, t), // d - bottom
      _rr(x, t + vLen + t, t, vLen), // e - bottom left
      _rr(x, t, t, vLen), // f - top left
      _rr(x + t, t + vLen, hLen, t), // g - middle
    ];

    final offPaint = Paint()..color = offColor;
    final onPaint = Paint()..color = onColor;
    // Ghost (unlit) segments first...
    for (final r in rects) {
      canvas.drawRRect(r, offPaint);
    }
    // ...then the lit ones on top.
    for (var s = 0; s < 7; s++) {
      if (segs[s]) canvas.drawRRect(rects[s], onPaint);
    }
  }

  RRect _rr(double left, double top, double w, double h) {
    return RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, w, h),
      Radius.circular((w < h ? w : h) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _SevenSegPainter old) =>
      old.text != text || old.onColor != onColor || old.offColor != offColor;
}
