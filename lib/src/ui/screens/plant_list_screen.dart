import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plant_provider.dart';
import '../../models/plant.dart';
import './add_plant_screen.dart';
import './plant_detail_screen.dart'; // Import PlantDetailScreen

class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure context is available and provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // Check if the widget is still mounted before calling setState or provider
    if (!mounted) return;
    try {
      await Provider.of<PlantProvider>(context, listen: false).loadPlants();
    } catch (error) {
      // Handle error, e.g., show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading plants: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plants'),
      ),
      body: Consumer<PlantProvider>(
        builder: (context, plantProvider, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (plantProvider.plants.isEmpty) {
            return const Center(
              child: Text(
                'No plants yet. Add one!',
                style: TextStyle(fontSize: 18.0),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: plantProvider.plants.length,
            itemBuilder: (context, index) {
              final Plant plant = plantProvider.plants[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell( // Make the card tappable
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlantDetailScreen(plant: plant),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(plant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(plant.species ?? 'Unknown species'),
                        const SizedBox(height: 4.0),
                        Text('Last watered: ${plant.lastWateredDate ?? 'Not yet watered'}'),
                        Text('Schedule: ${plant.wateringSchedule ?? 'Not set'}'),
                      ],
                    ),
                    // isThreeLine: true, // Adjust if necessary based on content
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlantScreen()),
          );
        },
        tooltip: 'Add Plant',
        child: const Icon(Icons.add),
      ),
    );
  }
}
