import 'package:brandao_timer/models/workout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const workout = Workout(
    id: '1',
    name: 'Treino A',
    exerciseCount: 5,
    exerciseSeconds: 40,
    restBetweenExercisesSeconds: 20,
    seriesCount: 3,
    restBetweenSeriesSeconds: 60,
  );

  group('totalDuration', () {
    test('não conta descanso após o último exercício nem a última série', () {
      // Série: 5*40 + 4*20 = 280s. Total: 3*280 + 2*60 = 960s.
      expect(workout.totalDuration, const Duration(seconds: 960));
    });

    test('um exercício e uma série é só o tempo do exercício', () {
      final single = workout.copyWith(exerciseCount: 1, seriesCount: 1);
      expect(single.totalDuration, const Duration(seconds: 40));
    });

    test('descansos zerados somam apenas os exercícios', () {
      final noRest = workout.copyWith(
        restBetweenExercisesSeconds: 0,
        restBetweenSeriesSeconds: 0,
      );
      expect(noRest.totalDuration, const Duration(seconds: 600));
    });
  });

  test('toJson/fromJson preserva todos os campos', () {
    expect(Workout.fromJson(workout.toJson()), workout);
  });

  test('copyWith altera só o campo informado', () {
    final renamed = workout.copyWith(name: 'Treino B');
    expect(renamed.name, 'Treino B');
    expect(renamed.copyWith(name: 'Treino A'), workout);
  });

  test('Workout.create usa valores padrão válidos', () {
    final w = Workout.create(id: 'x');
    expect(w.id, 'x');
    expect(w.exerciseCount, greaterThan(0));
    expect(w.seriesCount, greaterThan(0));
    expect(w.exerciseSeconds, greaterThan(0));
  });
}
