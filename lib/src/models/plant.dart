class Plant {
  final int? id;
  final String name;
  final String? species;
  final String? wateringSchedule;
  final String? lastWateredDate;
  final String? notes;

  Plant({
    this.id,
    required this.name,
    this.species,
    this.wateringSchedule,
    this.lastWateredDate,
    this.notes,
  });

  // Convert a Plant object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'watering_schedule': wateringSchedule,
      'last_watered_date': lastWateredDate,
      'notes': notes,
    };
  }

  // Extract a Plant object from a Map object
  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'],
      name: map['name'] ?? '',
      species: map['species'],
      wateringSchedule: map['watering_schedule'],
      lastWateredDate: map['last_watered_date'],
      notes: map['notes'],
    );
  }

  @override
  String toString() {
    return 'Plant{id: $id, name: $name, species: $species, wateringSchedule: $wateringSchedule, lastWateredDate: $lastWateredDate, notes: $notes}';
  }
}
