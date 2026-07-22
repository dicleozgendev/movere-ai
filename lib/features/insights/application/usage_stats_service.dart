import 'dart:io';

import 'package:flutter/services.dart';

/// Android UsageStatsManager bridge.
/// The Dart side of the requested snippet: pulls today's most-used
/// apps (by foreground time) from the platform channel.
/// iOS intentionally does not support this — there the official way is the Screen Time
/// API'sidir (FamilyControls + DeviceActivityReport, entitlement gerekir).
class AppUsageEntry {
  const AppUsageEntry({
    required this.name,
    required this.packageName,
    required this.minutes,
    required this.lastUsed,
  });

  final String name;
  final String packageName;
  final int minutes;
  final String lastUsed; // bugun en son ne zaman kullanildi (HH:mm)

  String get formatted =>
      minutes >= 60 ? '${minutes ~/ 60}h ${minutes % 60}m' : '${minutes}m';
}

class UsageStatsService {
  static const _channel = MethodChannel('movere/usage_stats');

  /// This feature only works on Android.
  static bool get isSupported => Platform.isAndroid;

  /// Has the user granted the "Usage access" permission?
  static Future<bool> hasPermission() async {
    if (!isSupported) return false;
    return await _channel.invokeMethod<bool>('hasPermission') ?? false;
  }

  /// Opens Android's Usage Access settings screen (permission is granted there).
  static Future<void> openSettings() =>
      _channel.invokeMethod('openSettings');

  /// Today's [count] most-used apps, sorted by time.
  static Future<List<AppUsageEntry>> getTopApps({int count = 10}) async {
    final raw =
        await _channel.invokeMethod<List<dynamic>>('getTopApps', {'count': count});
    return (raw ?? [])
        .map((e) => AppUsageEntry(
              name: e['name'] as String,
              packageName: e['package'] as String,
              minutes: e['minutes'] as int,
              lastUsed: e['lastUsed'] as String? ?? '',
            ),)
        .toList();
  }
}
