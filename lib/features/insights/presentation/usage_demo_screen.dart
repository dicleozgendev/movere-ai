import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/movere_button.dart';
import '../../../core/widgets/movere_card.dart';
import '../../../core/widgets/movere_navigation.dart';
import '../application/privacy_report_service.dart';
import '../application/usage_stats_service.dart';

/// Demo ekranı: bugünün en çok kullanılan 10 uygulaması + süreleri.
/// Android'de gerçek UsageStats verisini gösterir; iOS'ta neden
/// gösteremediğini dürüstçe açıklar (Screen Time API + entitlement).
class UsageDemoScreen extends StatefulWidget {
  const UsageDemoScreen({super.key});

  @override
  State<UsageDemoScreen> createState() => _UsageDemoScreenState();
}

class _UsageDemoScreenState extends State<UsageDemoScreen> {
  bool _loading = false;
  bool _needsPermission = false;
  List<AppUsageEntry> _apps = const [];

  // iOS: App Privacy Report ice aktarma durumu
  bool _iosLoading = false;
  List<PrivacyAppEntry>? _iosApps;

  Future<void> _importReport() async {
    setState(() => _iosLoading = true);
    final apps = await PrivacyReportService.pickAndParse(count: 10);
    if (!mounted) return;
    setState(() {
      _iosLoading = false;
      if (apps != null) _iosApps = apps;
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _needsPermission = false;
    });
    final granted = await UsageStatsService.hasPermission();
    if (!granted) {
      setState(() {
        _loading = false;
        _needsPermission = true;
      });
      return;
    }
    final apps = await UsageStatsService.getTopApps(count: 10);
    if (!mounted) return;
    setState(() {
      _apps = apps;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: const MovereAppBar(title: 'Usage Insights (Demo)'),
      body: !UsageStatsService.isSupported
          // --- iOS: dürüst açıklama kartı ---
          ? ListView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              children: [
                Text('iOS: Privacy Report import',
                    style: textTheme.displayMedium,),
                const SizedBox(height: 4),
                Text(
                  'Real per-app activity from your App Privacy Report.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppConstants.spacingLg),
                MovereCard(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How it works', style: textTheme.titleMedium),
                      const SizedBox(height: AppConstants.spacingSm),
                      Text(
                        '1. Settings > Privacy & Security > App Privacy Report '
                        '(turn it on once; it records from then on).\n'
                        '2. Tap the share icon > Save App Activity > save to Files.\n'
                        '3. Come back and import the file below.\n\n'
                        'Raw screen-time minutes require Apple\'s Screen Time API '
                        '(paid account + Family Controls entitlement); this route '
                        'is the free, Apple-sanctioned alternative based on '
                        'recorded app activity.',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                MovereButton(
                  label: _iosApps == null
                      ? 'Import App Privacy Report'
                      : 'Import another report',
                  isLoading: _iosLoading,
                  onPressed: _importReport,
                ),
                const SizedBox(height: AppConstants.spacingMd),
                if (_iosApps != null && _iosApps!.isEmpty)
                  Text(
                    'No app activity found in that file — make sure the '
                    'report has been enabled for a while before exporting.',
                    style: textTheme.bodyMedium,
                  ),
                if (_iosApps != null)
                  for (var i = 0; i < _iosApps!.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppConstants.spacingSm,),
                      child: MovereCard(
                        padding:
                            const EdgeInsets.all(AppConstants.spacingMd),
                        child: Row(
                          children: [
                            Text(
                              (i + 1).toString().padLeft(2, '0'),
                              style: textTheme.titleMedium
                                  ?.copyWith(color: primary),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(_iosApps![i].name,
                                      style: textTheme.titleMedium,),
                                  Text(
                                    'last active ${_iosApps![i].lastActiveLabel}'
                                    ' \u00b7 ${_iosApps![i].bundleId}',
                                    style: textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${_iosApps![i].events} events',
                              style: textTheme.titleMedium
                                  ?.copyWith(color: primary),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              children: [
                Text('Recently used apps', style: textTheme.displayMedium),
                const SizedBox(height: 4),
                Text('Last 10 used apps today, with foreground time.',
                    style: textTheme.bodyMedium,),
                const SizedBox(height: AppConstants.spacingLg),
                if (_needsPermission) ...[
                  MovereCard(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    child: Column(
                      children: [
                        Text(
                          'Usage access is required. Grant it for Movere in '
                          'the system settings, then come back and refresh.',
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        const MovereButton(
                          label: 'Open Usage Access Settings',
                          onPressed: UsageStatsService.openSettings,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                ],
                MovereButton(
                  label: _apps.isEmpty ? 'Load usage data' : 'Refresh',
                  isLoading: _loading,
                  onPressed: _load,
                ),
                const SizedBox(height: AppConstants.spacingMd),
                for (var i = 0; i < _apps.length; i++)
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppConstants.spacingSm),
                    child: MovereCard(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      child: Row(
                        children: [
                          Text(
                            (i + 1).toString().padLeft(2, '0'),
                            style: textTheme.titleMedium
                                ?.copyWith(color: primary),
                          ),
                          const SizedBox(width: AppConstants.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_apps[i].name,
                                    style: textTheme.titleMedium,),
                                Text(
                                  'last used ${_apps[i].lastUsed} · ${_apps[i].packageName}',
                                  style: textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _apps[i].formatted,
                            style: textTheme.titleMedium
                                ?.copyWith(color: primary),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
