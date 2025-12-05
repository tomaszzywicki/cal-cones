import 'dart:io';
import 'package:frontend/core/database/data.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables.dart';

class LocalDatabaseService {
  static Database? _database;
  static const String _databaseName = 'database.db';
  static const int _version = 2;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _version, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
    _database = null;
  }

  Future<void> resetDatabase() async {
    if (_database != null) {
      await close();
    }
    final String path = join(await getDatabasesPath(), _databaseName);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    AppLogger.info('Database reset: $_databaseName deleted.');
  }

  Future<void> _onCreate(Database db, int version) async {
    await initTables(db, version);
    await addData(db, version);
    AppLogger.info('Database initialized with version $version.');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.info('Database upgrade from v$oldVersion to v$newVersion - recreating tables');

    // Drop all tables
    await db.execute('DROP TABLE IF EXISTS meal_products');
    await db.execute('DROP TABLE IF EXISTS meals');
    await db.execute('DROP TABLE IF EXISTS products');
    await db.execute('DROP TABLE IF EXISTS units');
    await db.execute('DROP TABLE IF EXISTS weight_logs');
    await db.execute('DROP TABLE IF EXISTS user_goals');
    await db.execute('DROP TABLE IF EXISTS users');

    // Recreate
    await _onCreate(db, newVersion);
  }
}
