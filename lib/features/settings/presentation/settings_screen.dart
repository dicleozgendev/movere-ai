import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/movere_button.dart';
import '../../../core/widgets/movere_card.dart';
import '../../auth/application/profile_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Settings screen — the full "Move Beyond" settings layout (Sprint 5).
///
/// Profile header with the account badge, grouped preference rows
/// (Preferences / Support), a working Appearance switch wired to
/// [themeModeProvider], and a bordered Sign Out button. Mirrors the
/// design mockups. Lives in its own feature folder now that it is a
/// real screen rather than a placeholder tab.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(ctx)!.settingsSignOut),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    // Clear the local mirror too, so a next sign-in starts from a clean
    // profile state instead of showing the previous user's email briefly.
    await ref.read(profileProvider.notifier).clear();
    if (!context.mounted) return;
    // removeUntil: wipe the whole stack so the back button can't return
    // to the Dashboard after signing out.
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  /// A friendly display name: Firebase displayName when set, otherwise the
  /// local part of the email, title-cased ("mehmet.ozgen" -> "Mehmet Ozgen").
  String _displayName(String? email) {
    final displayName = FirebaseAuth.instance.currentUser?.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    if (email == null || email.isEmpty) return 'Movere User';
    final local = email.split('@').first;
    final parts = local
        .split(RegExp(r'[._\-]+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1));
    return parts.isEmpty ? 'Movere User' : parts.join(' ');
  }

  String _appearanceLabel(BuildContext context, ThemeMode mode) {
    final t = AppLocalizations.of(context)!;
    return switch (mode) {
      ThemeMode.system => t.settingsThemeSystem,
      ThemeMode.light => t.settingsThemeLight,
      ThemeMode.dark => t.settingsThemeDark,
    };
  }

  /// Cycle System -> Light -> Dark -> System. The comment in
  /// theme_provider.dart marks this as the Sprint 5 wiring point.
  void _cycleAppearance(WidgetRef ref) {
    final notifier = ref.read(themeModeProvider.notifier);
    notifier.state = switch (notifier.state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final email = ref.watch(profileProvider);
    final locale = ref.watch(localeProvider);
    final languageLabel = locale?.languageCode == 'tr'
        ? AppLocalizations.of(context)!.languageTurkish
        : AppLocalizations.of(context)!.languageEnglish;
    final themeMode = ref.watch(themeModeProvider);
    final name = _displayName(email);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: [
        Text(AppLocalizations.of(context)!.settingsTitle, style: textTheme.displayMedium),
        const SizedBox(height: AppConstants.spacingLg),

        // --- Profile header card ---
        _ProfileCard(
          initial: initial,
          name: name,
          email: email ?? 'Not signed in',
          onTap: () => _comingSoon(context, 'Edit Profile'),
        ),
        const SizedBox(height: AppConstants.spacingLg),

        // --- Preferences ---
        _SettingsSection(
          title: AppLocalizations.of(context)!.settingsPreferences,
          children: [
            _SettingsRow(
              icon: Icons.person_outline,
              label: AppLocalizations.of(context)!.settingsEditProfile,
              onTap: () => _comingSoon(context, 'Edit Profile'),
            ),
            const _RowDivider(),
            _SettingsRow(
              icon: Icons.notifications_none,
              label: AppLocalizations.of(context)!.settingsNotifications,
              onTap: () => _comingSoon(context, 'Notifications'),
            ),
            const _RowDivider(),
            _SettingsRow(
              icon: Icons.language,
              label: AppLocalizations.of(context)!.settingsLanguage,
              trailing: languageLabel,
              onTap: () => _pickLanguage(context, ref),
            ),
            const _RowDivider(),
            _SettingsRow(
              icon: Icons.light_mode_outlined,
              label: AppLocalizations.of(context)!.settingsAppearance,
              trailing: _appearanceLabel(context, themeMode),
              onTap: () => _cycleAppearance(ref),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // --- Support ---
        _SettingsSection(
          title: AppLocalizations.of(context)!.settingsSupport,
          children: [
            _SettingsRow(
              icon: Icons.help_outline,
              label: AppLocalizations.of(context)!.settingsHelpFeedback,
              onTap: () => _comingSoon(context, 'Help & Feedback'),
            ),
            const _RowDivider(),
            _SettingsRow(
              icon: Icons.shield_outlined,
              label: AppLocalizations.of(context)!.settingsPrivacySecurity,
              onTap: () => _comingSoon(
                  context, AppLocalizations.of(context)!.settingsPrivacySecurity,),
            ),
            const _RowDivider(),
            _SettingsRow(
              icon: Icons.info_outline,
              label: AppLocalizations.of(context)!.settingsAboutMovere,
              onTap: () => _comingSoon(context, 'About Movere'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),

        // --- Sign out (bordered, with icon — matches the mockup) ---
        MovereButton(
          label: AppLocalizations.of(context)!.settingsSignOut,
          icon: Icons.logout,
          variant: MovereButtonVariant.secondary,
          onPressed: () => _signOut(context, ref),
        ),
      ],
    );
  }

  static void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is on the way — see the sprint plan.')),
    );
  }

  /// A simple two-option picker — only English and Turkish are supported,
  /// so a full list/search UI would be overkill.
  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final current = ref.read(localeProvider);
    final chosen = await showDialog<Locale>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.settingsLanguage),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, const Locale('en')),
            child: Row(
              children: [
                if (current?.languageCode != 'tr')
                  const Icon(Icons.check, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: AppConstants.spacingSm),
                Text(AppLocalizations.of(context)!.languageEnglish),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, const Locale('tr')),
            child: Row(
              children: [
                if (current?.languageCode == 'tr')
                  const Icon(Icons.check, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: AppConstants.spacingSm),
                Text(AppLocalizations.of(context)!.languageTurkish),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen != null) {
      ref.read(localeProvider.notifier).state = chosen;
    }
  }
}

/// The account header: avatar with a soft green ring, name, email, and the
/// "Movere account" badge, over a subtle gradient. Tappable (Edit Profile).
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.initial,
    required this.name,
    required this.email,
    required this.onTap,
  });

  final String initial;
  final String name;
  final String email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    return MovereCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withValues(alpha: 0.10),
              surface,
              surface,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Row(
            children: [
              // Avatar with a soft green ring.
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.14),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  initial,
                  style: textTheme.headlineMedium?.copyWith(color: primary),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.settingsMovereAccount,
                        style: textTheme.labelSmall?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 22,
                color: textTheme.labelSmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A titled group of settings rows, e.g. "Preferences" or "Support".
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.spacingSm,
            bottom: AppConstants.spacingSm,
          ),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                ),
          ),
        ),
        MovereCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// A single tappable settings row: icon, label, optional trailing value,
/// chevron. The familiar list pattern from iOS/Android settings screens.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingMd,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: primary),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(child: Text(label, style: textTheme.bodyLarge)),
            if (trailing != null) ...[
              Text(trailing!, style: textTheme.labelSmall),
              const SizedBox(width: AppConstants.spacingSm),
            ],
            Icon(
              Icons.chevron_right,
              size: 20,
              color: textTheme.labelSmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}

/// A hairline separator between rows, indented past the leading icon.
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, indent: 54);
  }
}
