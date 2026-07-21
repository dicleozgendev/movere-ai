import 'dart:io';

import 'package:flutter/services.dart';

/// Android UsageStatsManager köprüsü.
/// Haydar'ın istediği snippet'in Dart tarafı: bugün en çok kullanılan
/// uygulamaları (ön planda geçirilen süreyle) platform kanalından çeker.
/// iOS'ta bilinçli olarak desteklenmez — orada resmi yol Screen Time
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

  /// Bu özellik yalnızca Android'de çalışır.
  static bool get isSupported => Platform.isAndroid;

  /// Kullanıcı "Kullanım erişimi" iznini vermiş mi?
  static Future<bool> hasPermission() async {
    if (!isSupported) return false;
    return await _channel.invokeMethod<bool>('hasPermission') ?? false;
  }

  /// Android'in Kullanım Erişimi ayar ekranını açar (izin oradan verilir).
  static Future<void> openSettings() =>
      _channel.invokeMethod('openSettings');

  /// Bugünün en çok kullanılan [count] uygulaması, süreye göre sıralı.
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
