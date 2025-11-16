import 'package:sqflite/sqflite.dart';

Future<void> initTables(Database db, int version) async {
  // Users cache table

  // User goals
  await db.execute('''
    CREATE TABLE user_goals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      uuid TEXT,
      user_id INTEGER NOT NULL,
      start_date TEXT NOT NULL,
      target_date TEXT NOT NULL,
      end_date TEXT,
      start_weight REAL NOT NULL,
      target_weight REAL NOT NULL,
      end_weight REAL,
      tempo REAL NOT NULL,
      is_current INTEGER NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 0
    )
  ''');
}
