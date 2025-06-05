import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:provider/provider.dart';
import '../../models/plant.dart';
import '../../providers/plant_provider.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _wateringScheduleController;
  late TextEditingController _notesController;
  late String _lastWateredDateString; // To display and update locally

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant.name);
    _speciesController = TextEditingController(text: widget.plant.species);
    _wateringScheduleController = TextEditingController(text: widget.plant.wateringSchedule);
    _notesController = TextEditingController(text: widget.plant.notes);
    _lastWateredDateString = widget.plant.lastWateredDate ?? 'Not yet watered';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _wateringScheduleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _markAsWateredToday() async {
    final now = DateTime.now();
    final updatedPlant = Plant(
      id: widget.plant.id,
      name: _nameController.text, // Keep current form values
      species: _speciesController.text,
      wateringSchedule: _wateringScheduleController.text,
      lastWateredDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(now), // Format date
      notes: _notesController.text,
    );

    try {
      await Provider.of<PlantProvider>(context, listen: false).updatePlant(updatedPlant);
      setState(() {
        _lastWateredDateString = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plant watered!')),
        );
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as watered: $e')),
        );
      }
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedPlant = Plant(
        id: widget.plant.id,
        name: _nameController.text,
        species: _speciesController.text.isEmpty ? null : _speciesController.text,
        wateringSchedule: _wateringScheduleController.text.isEmpty ? null : _wateringScheduleController.text,
        lastWateredDate: widget.plant.lastWateredDate, // Preserve original if not marked watered today via this screen
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      try {
        await Provider.of<PlantProvider>(context, listen: false).updatePlant(updatedPlant);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Changes saved!')),
          );
          Navigator.pop(context); // Optionally pop back
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save changes: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant.name),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
                decoration: const InputDecoration(labelText: 'Watering Schedule'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Text('Last Watered: $_lastWateredDateString', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _markAsWateredToday,
                child: const Text('Mark as Watered Today'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Plant'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete "${widget.plant.name}"?'),
                const Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
                _deletePlant(); // Call the actual delete method
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePlant() async {
    if (widget.plant.id != null) {
      try {
        await Provider.of<PlantProvider>(context, listen: false)
            .deletePlant(widget.plant.id!);
        if (mounted) {
          // Pop PlantDetailScreen
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete plant: $e')),
          );
        }
      }
    } else {
      // Should not happen if plant is from DB
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Plant ID is null.')),
        );
      }
  }
}
