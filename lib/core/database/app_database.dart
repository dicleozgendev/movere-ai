import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Single entry point for local persistence. Every feature store reads
/// through this one database instead of opening its own — one file to see
/// the whole schema, one place to bump the version when it changes.
///
/// Tables (Sprint 4 backlog, one row of the plan each):
///  - focus_sessions      Store focus sessions
///  - reading_progress    Store Academy progress (reading)
///  - bookmarks           Store Academy progress (bookmarks)
///  - listened_episodes   Store Academy progress (podcast)
///  - user_profile        Store user profile
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'movere.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE focus_sessions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            started_at TEXT NOT NULL,
            planned_minutes INTEGER NOT NULL,
            elapsed_minutes INTEGER NOT NULL,
            completed INTEGER NOT NULL,
            interruptions INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE reading_progress(
            lesson_id TEXT PRIMARY KEY,
            progress REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE bookmarks(
            lesson_id TEXT PRIMARY KEY
          )
        ''');
        await db.execute('''
          CREATE TABLE listened_episodes(
            episode_id TEXT PRIMARY KEY
          )
        ''');
        await db.execute('''
          CREATE TABLE user_profile(
            id INTEGER PRIMARY KEY CHECK (id = 1),
            email TEXT
          )
        ''');
      },
    );
  }

  /// Test/debug helper: wipes every table without deleting the file.
  /// Not wired to any UI yet — kept here for the Settings "reset data"
  /// action planned for Sprint 5.
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('focus_sessions');
    await db.delete('reading_progress');
    await db.delete('bookmarks');
    await db.delete('listened_episodes');
    await db.delete('user_profile');
  }
}
