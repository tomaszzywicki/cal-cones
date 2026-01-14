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
    CREATE TABLE weight_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      uuid TEXT,
      user_id INTEGER NOT NULL,
      weight REAL NOT NULL,
      date TEXT NOT NULL,
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
      average_portion REAL,
      is_synced INTEGER NOT NULL DEFAULT 0
    )
''');

  //   await db.execute('''
  //     CREATE TABLE meals (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       uuid TEXT,
  //       user_id INTEGER NOT NULL,
  //       name TEXT,
  //       total_kcal INTEGER,
  //       total_carbs REAL,
  //       total_protein REAL,
  //       total_fat REAL,
  //       notes TEXT,
  //       consumed_at TEXT,
  //       created_at TEXT,
  //       last_modified_at TEXT,
  //       is_synced INTEGER NOT NULL DEFAULT 0
  //     )
  // ''');

  await db.execute(''' 
  CREATE TABLE meal_products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT,
    -- meal_id INTEGER NOT NULL,
    -- meal_uuid TEXT,
    user_id INTEGER NOT NULL,
    product_id INTEGER,
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
    is_synced INTEGER NOT NULL DEFAULT 0

    -- FOREIGN KEY (meal_id) REFERENCES meals(id) ON DELETE CASCADE,
    -- FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
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

  await db.execute('''
    CREATE TABLE IF NOT EXISTS sync_queue (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      feature TEXT NOT NULL,
      operation TEXT NOT NULL,
      entity_uuid TEXT NOT NULL,
      payload TEXT,
      created_at TEXT NOT NULL
    )
  ''');

  // Recipe table
  await db.execute('''
    CREATE TABLE recipes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      time TEXT,
      calories INTEGER,
      ingredients TEXT, -- JSON encoded list of strings
      instructions TEXT, -- JSON encoded list of strings
      created_at TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE daily_targets (
      date TEXT PRIMARY KEY,
      user_id INTEGER NOT NULL,
      goal_id INTEGER NOT NULL,
      weight_used DOUBLE NOT NULL,
      diet_type TEXT,
      calories INTEGER NOT NULL,
      protein_g INTEGER NOT NULL,
      carbs_g REAL NOT NULL,
      fat_g REAL NOT NULL,
      last_modified_at TEXT NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 0
    )
  ''');

}
