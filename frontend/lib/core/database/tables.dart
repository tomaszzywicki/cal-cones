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

  await db.execute('''
    CREATE TABLE weight_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      uuid TEXT,
      user_id INTEGER NOT NULL,
      weight REAL NOT NULL,
      created_at TEXT NOT NULL,
      last_modified_at TEXT NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 0
    )
 ''');

  await db.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      uuid TEXT,
      user_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      manufacturer TEXT,
      kcal INTEGER NOT NULL,
      carbs REAL NOT NULL,
      protein REAL NOT NULL,
      fat REAL NOT NULL,
      created_at TEXT NOT NULL,
      last_modified_at TEXT NOT NULL,
      from_model INTEGER NOT NULL DEFAULT 0,
      is_synced INTEGER NOT NULL DEFAULT 0
    )
''');

  await db.execute('''
    CREATE TABLE meals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      uuid TEXT,
      user_id INTEGER NOT NULL,
      name TEXT,
      total_kcal INTEGER,
      total_carbs REAL,
      total_protein REAL,
      total_fat REAL,
      notes TEXT,
      consumed_at TEXT,
      created_at TEXT,
      last_modified_at TEXT,
      is_synced INTEGER NOT NULL DEFAULT 0
    )
''');

  await db.execute(''' 
  CREATE TABLE meal_products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT,
    meal_id INTEGER NOT NULL,
    meal_uuid TEXT,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    product_uuid TEXT,
    name TEXT NOT NULL,
    manufacturer TEXT,
    kcal INTEGER NOT NULL,
    carbs REAL NOT NULL,
    protein REAL NOT NULL,
    fat REAL NOT NULL,
    unit_id INTEGER NOT NULL,
    unit_short TEXT NOT NULL,
    conversion_factor REAL NOT NULL,
    amount REAL NOT NULL,
    notes TEXT,
    created_at TEXT NOT NULL,
    last_modified_at TEXT NOT NULL,
    is_synced INTEGER NOT NULL DEFAULT 0,

    FOREIGN KEY (meal_id) REFERENCES meals(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
  )
  ''');

  await db.execute('''
    CREATE TABLE units (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      shortname TEXT NOT NULL,
      unit_type TEXT NOT NULL,
      conversion_factor REAL NOT NULL,
      base_unit INTEGER NOT NULL DEFAULT 0
    )
  ''');
}
