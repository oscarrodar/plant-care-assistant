import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'plant_care.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE plants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        species TEXT,
        watering_schedule TEXT,
        last_watered_date TEXT,
        notes TEXT
      )
    ''');
  }

  // Example method to insert a plant (optional for now, but good for testing)
  // Future<int> insertPlant(Map<String, dynamic> row) async {
  //   Database db = await database;
  //   return await db.insert('plants', row);
  // }

  // Example method to query all plants (optional for now, but good for testing)
  // Future<List<Map<String, dynamic>>> queryAllPlants() async {
  //   Database db = await database;
  //   return await db.query('plants');
  // }
}
