import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';

/// The signed-in user's stored profile — for now just the email, since
/// login itself is still a simulated flow (a 1-second delay). Sprint 4's
/// second half connects real Firebase Authentication behind this exact
/// same interface: [saveEmail] is where that call will eventually live.
class ProfileStore extends StateNotifier<String?> {
  ProfileStore() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('user_profile', where: 'id = 1');
    if (rows.isNotEmpty) state = rows.first['email'] as String?;
  }

  Future<void> saveEmail(String email) async {
    state = email;
    final db = await AppDatabase.instance.database;
    await db.insert(
      'user_profile',
      {'id': 1, 'email': email},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clear() async {
    state = null;
    final db = await AppDatabase.instance.database;
    await db.delete('user_profile', where: 'id = 1');
  }
}

final profileProvider =
    StateNotifierProvider<ProfileStore, String?>((ref) => ProfileStore());
