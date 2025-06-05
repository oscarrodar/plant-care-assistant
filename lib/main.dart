import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/plant_provider.dart';
import 'src/ui/screens/plant_list_screen.dart'; // Will be created next

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlantProvider(),
      child: MaterialApp(
        title: 'Plant Care App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const PlantListScreen(), // This will be created
      ),
    );
  }
}
