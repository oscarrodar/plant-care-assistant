import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/plant.dart';
import '../../providers/plant_provider.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _wateringScheduleController = TextEditingController();
  final _notesController = TextEditingController(); // Added notes controller

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _wateringScheduleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _savePlant() {
    if (_formKey.currentState!.validate()) {
      final newPlant = Plant(
        name: _nameController.text,
        species: _speciesController.text.isEmpty ? null : _speciesController.text,
        wateringSchedule: _wateringScheduleController.text.isEmpty ? null : _wateringScheduleController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        // last_watered_date can be set by another screen or default to null/current date
      );

      Provider.of<PlantProvider>(context, listen: false).addPlant(newPlant);
      Navigator.pop(context); // Go back to PlantListScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Plant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // Using ListView to prevent overflow with keyboard
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Plant Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the plant name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(labelText: 'Species (Optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _wateringScheduleController,
                decoration: const InputDecoration(labelText: 'Watering Schedule (e.g., "Every 3 days")'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _savePlant,
                child: const Text('Save Plant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
