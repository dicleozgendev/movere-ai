import 'dart:convert';

import 'package:file_picker/file_picker.dart';

/// iOS App Privacy Report (NDJSON) parser.
/// File selection is handled by the file_picker package — the native channel we
/// wrote ourselves was flaky due to registration timing across Flutter/Xcode
/// versions; file_picker solves this problem internally,
/// a ready-made solution tested across millions of apps.
class PrivacyAppEntry {
  const PrivacyAppEntry({
    required this.bundleId,
    required this.events,
    required this.lastActive,
  });

  final String bundleId;
  final int events;
  final DateTime lastActive;

  String get name {
    final last = bundleId.split('.').last;
    return last.isEmpty ? bundleId : last[0].toUpperCase() + last.substring(1);
  }

  String get lastActiveLabel =>
      '${lastActive.hour.toString().padLeft(2, '0')}:'
      '${lastActive.minute.toString().padLeft(2, '0')}';
}

class PrivacyReportService {
  /// Opens a file picker (file_picker), parses the selected report and returns the
  /// last active [count] apps. Returns null if the user cancels.
  static Future<List<PrivacyAppEntry>?> pickAndParse({int count = 10}) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return null;

    final bytes = result.files.single.bytes;
    if (bytes == null) return null;
    final raw = utf8.decode(bytes, allowMalformed: true);

    final events = <String, int>{};
    final lastSeen = <String, DateTime>{};

    for (final line in const LineSplitter().convert(raw)) {
      if (line.trim().isEmpty) continue;
      Map<String, dynamic> m;
      try {
        m = jsonDecode(line) as Map<String, dynamic>;
      } catch (_) {
        continue; // bozuk/uyumsuz satiri atla
      }
      final bundle = (m['bundleID'] ??
              (m['accessor'] is Map ? m['accessor']['identifier'] : null))
          as String?;
      if (bundle == null || bundle.isEmpty) continue;

      events[bundle] = (events[bundle] ?? 0) + 1;
      final ts = m['timeStamp'] as String?;
      if (ts != null) {
        final t = DateTime.tryParse(ts);
        if (t != null &&
            (lastSeen[bundle] == null || t.isAfter(lastSeen[bundle]!))) {
          lastSeen[bundle] = t;
        }
      }
    }

    final entries = [
      for (final b in events.keys)
        PrivacyAppEntry(
          bundleId: b,
          events: events[b]!,
          lastActive: lastSeen[b] ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
    ]..sort((a, c) => c.lastActive.compareTo(a.lastActive));

    return entries.take(count).toList();
  }
}
