import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static Database? _database;
  static const String _databaseName = 'database.db';
  static const int _version = 1;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _version, onCreate: _onCreate);
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
  }

  Future<void> _onCreate(Database db, int version) async {}
}
