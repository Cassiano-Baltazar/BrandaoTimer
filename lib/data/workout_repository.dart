import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout.dart';

/// Guarda os treinos no próprio aparelho, como JSON.
class WorkoutRepository {
  WorkoutRepository(this._prefs);

  static const storageKey = 'workouts';

  final SharedPreferences _prefs;

  List<Workout> load() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Workout.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Object {
      // Dado corrompido não deve impedir o app de abrir.
      return [];
    }
  }

  Future<void> save(List<Workout> workouts) => _prefs.setString(
    storageKey,
    jsonEncode(workouts.map((w) => w.toJson()).toList()),
  );
}
