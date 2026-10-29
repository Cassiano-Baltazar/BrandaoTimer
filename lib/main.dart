import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/workout_repository.dart';
import 'screens/workout_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(BrandaoTimerApp(repository: WorkoutRepository(prefs)));
}

class BrandaoTimerApp extends StatelessWidget {
  const BrandaoTimerApp({super.key, required this.repository});

  final WorkoutRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brandão Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
      ),
      home: WorkoutListScreen(repository: repository),
    );
  }
}
