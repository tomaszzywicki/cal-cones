import 'package:sqflite/sqflite.dart';

Future<void> addData(Database db, int version) async {
  // === Units ===
  await db.insert('units', {
    'id': 1,
    'name': 'Gram',
    'shortname': 'g',
    'unit_type': 'weight',
    'conversion_factor': 1.0,
    'base_unit': 1,
  });

  // await db.insert('units', {
  //   'id': 2,
  //   'name': 'Milliliter',
  //   'shortname': 'ml',
  //   'unit_type': 'volume',
  //   'conversion_factor': 1.0,
  //   'base_unit': 1,
  // });

  // await db.insert('units', {
  //   'id': 3,
  //   'name': 'Piece',
  //   'shortname': 'pcs',
  //   'unit_type': 'count',
  //   'conversion_factor': 1.0,
  //   'base_unit': 1,
  // });

  // === Products ===
  final now = DateTime.now().toIso8601String();

  await db.insert('products', {
    'id': 1,
    'user_id': 1,
    'name': 'Chicken Breast',
    'manufacturer': 'Generic',
    'kcal': 165,
    'carbs': 0.0,
    'protein': 31.0,
    'fat': 3.6,
    'created_at': now,
    'last_modified_at': now,
    'from_model': 0,
    'is_synced': 1,
  });

  await db.insert('products', {
    'id': 2,
    'user_id': 1,
    'name': 'Brown Rice',
    'manufacturer': 'Generic',
    'kcal': 370,
    'carbs': 77.0,
    'protein': 7.9,
    'fat': 2.9,
    'created_at': now,
    'last_modified_at': now,
    'from_model': 0,
    'is_synced': 1,
  });

  await db.insert('products', {
    'id': 3,
    'user_id': 1,
    'name': 'Banana',
    'manufacturer': null,
    'kcal': 89,
    'carbs': 22.8,
    'protein': 1.1,
    'fat': 0.3,
    'created_at': now,
    'last_modified_at': now,
    'from_model': 0,
    'is_synced': 1,
  });

  await db.insert('products', {
    'id': 4,
    'user_id': 1,
    'name': 'Eggs',
    'manufacturer': 'Generic',
    'kcal': 155,
    'carbs': 1.1,
    'protein': 13.0,
    'fat': 11.0,
    'created_at': now,
    'last_modified_at': now,
    'from_model': 0,
    'is_synced': 1,
  });

  await db.insert('products', {
    'id': 5,
    'user_id': 1,
    'name': 'Oatmeal',
    'manufacturer': 'Quaker',
    'kcal': 389,
    'carbs': 66.3,
    'protein': 16.9,
    'fat': 6.9,
    'created_at': now,
    'last_modified_at': now,
    'from_model': 0,
    'is_synced': 1,
  });
}
