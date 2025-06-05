import 'package:flutter/foundation.dart';
import '../models/plant.dart';
import '../data/database_helper.dart'; // Assuming this path is correct

class PlantProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Initialize DatabaseHelper
  List<Plant> _plants = [];

  List<Plant> get plants => _plants;

  Future<void> loadPlants() async {
    // DatabaseHelper.database ensures the db is initialized
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('plants');

    _plants = List.generate(maps.length, (i) {
      return Plant.fromMap(maps[i]);
    });
    notifyListeners();
  }

  Future<void> addPlant(Plant plant) async {
    final db = await _dbHelper.database;
    await db.insert('plants', plant.toMap());
    await loadPlants(); // Reload and notify
  }

  Future<void> updatePlant(Plant plant) async {
    final db = await _dbHelper.database;
    await db.update(
      'plants',
      plant.toMap(),
      where: 'id = ?',
      whereArgs: [plant.id],
    );
    await loadPlants(); // Reload and notify
  }

  Future<void> deletePlant(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadPlants(); // Reload and notify
  }

  Future<void> updateLastWateredDate(int id, DateTime date) async {
    final db = await _dbHelper.database;
    // Fetch the existing plant
    List<Map<String, dynamic>> maps = await db.query(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      Plant existingPlant = Plant.fromMap(maps.first);
      Plant updatedPlant = Plant(
        id: existingPlant.id,
        name: existingPlant.name,
        species: existingPlant.species,
        wateringSchedule: existingPlant.wateringSchedule,
        lastWateredDate: date.toIso8601String(), // Update the date
        notes: existingPlant.notes,
      );
      await updatePlant(updatedPlant); // This will call loadPlants and notifyListeners
    }
  }
}
