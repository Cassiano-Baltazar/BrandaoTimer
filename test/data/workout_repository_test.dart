import 'package:brandao_timer/data/workout_repository.dart';
import 'package:brandao_timer/models/workout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<WorkoutRepository> repo([
    Map<String, Object> initial = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(initial);
    return WorkoutRepository(await SharedPreferences.getInstance());
  }

  test('começa vazio', () async {
    expect((await repo()).load(), isEmpty);
  });

  test('salva e carrega mantendo a ordem', () async {
    final r = await repo();
    final workouts = [
      Workout.create(id: '1').copyWith(name: 'A'),
      Workout.create(id: '2').copyWith(name: 'B'),
    ];
    await r.save(workouts);
    expect(r.load(), workouts);
  });

  test('dado corrompido retorna lista vazia em vez de quebrar', () async {
    final r = await repo({WorkoutRepository.storageKey: 'não é json'});
    expect(r.load(), isEmpty);
  });
}
