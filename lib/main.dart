import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/workout_repository.dart';
import 'services/announcer.dart';
import 'services/screen_awake.dart';
import 'screens/workout_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    BrandaoTimerApp(
      repository: WorkoutRepository(prefs),
      announcer: TtsAnnouncer(),
      screenAwake: WakelockScreenAwake(),
    ),
  );
}

class BrandaoTimerApp extends StatelessWidget {
  const BrandaoTimerApp({
    super.key,
    required this.repository,
    required this.announcer,
    required this.screenAwake,
  });

  final WorkoutRepository repository;
  final Announcer announcer;
  final ScreenAwake screenAwake;

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
      home: WorkoutListScreen(
        repository: repository,
        announcer: announcer,
        screenAwake: screenAwake,
      ),
    );
  }
}
