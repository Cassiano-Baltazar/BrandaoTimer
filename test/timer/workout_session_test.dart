import 'package:brandao_timer/models/workout.dart';
import 'package:brandao_timer/timer/workout_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const workout = Workout(
    id: '1',
    name: 'T',
    exerciseCount: 2,
    exerciseSeconds: 5,
    restBetweenExercisesSeconds: 4,
    seriesCount: 2,
    restBetweenSeriesSeconds: 6,
  );

  Phase phase(PhaseType type, int seconds, int e, int s) =>
      Phase(type: type, seconds: seconds, exerciseNumber: e, seriesNumber: s);

  group('buildPhases', () {
    test('monta preparação, exercícios e descansos na ordem', () {
      expect(buildPhases(workout), [
        phase(PhaseType.prepare, prepareSeconds, 1, 1),
        phase(PhaseType.exercise, 5, 1, 1),
        phase(PhaseType.rest, 4, 2, 1),
        phase(PhaseType.exercise, 5, 2, 1),
        phase(PhaseType.seriesRest, 6, 1, 2),
        phase(PhaseType.exercise, 5, 1, 2),
        phase(PhaseType.rest, 4, 2, 2),
        phase(PhaseType.exercise, 5, 2, 2),
      ]);
    });

    test('omite descansos com tempo zero', () {
      final phases = buildPhases(
        workout.copyWith(
          restBetweenExercisesSeconds: 0,
          restBetweenSeriesSeconds: 0,
        ),
      );
      expect(phases.map((p) => p.type), [
        PhaseType.prepare,
        PhaseType.exercise,
        PhaseType.exercise,
        PhaseType.exercise,
        PhaseType.exercise,
      ]);
    });

    test('duração das fases após a preparação bate com totalDuration', () {
      final seconds = buildPhases(workout)
          .skip(1)
          .fold(0, (sum, p) => sum + p.seconds);
      expect(Duration(seconds: seconds), workout.totalDuration);
    });
  });

  group('WorkoutSession', () {
    test('começa na preparação com aviso "Prepare-se"', () {
      final session = WorkoutSession(workout);
      expect(session.current.type, PhaseType.prepare);
      expect(session.remainingSeconds, prepareSeconds);
      expect(session.startCue, Cue.prepare);
    });

    test('conta 3, 2, 1 e avisa "Iniciar" ao começar o exercício', () {
      final session = WorkoutSession(workout);
      final cues = [for (var i = 0; i < prepareSeconds; i++) session.tick()];
      expect(cues, [
        <Cue>[],
        [Cue.three],
        [Cue.two],
        [Cue.one],
        [Cue.start],
      ]);
      expect(session.current.type, PhaseType.exercise);
      expect(session.remainingSeconds, 5);
    });

    test('conta 3, 2, 1 e avisa "Descansar" ao fim do exercício', () {
      final session = WorkoutSession(workout);
      for (var i = 0; i < prepareSeconds; i++) {
        session.tick();
      }
      final cues = [for (var i = 0; i < 5; i++) session.tick()];
      expect(cues.last, [Cue.rest]);
      expect(cues.sublist(1, 4), [
        [Cue.three],
        [Cue.two],
        [Cue.one],
      ]);
      expect(session.current.type, PhaseType.rest);
    });

    test('termina com "Treino concluído" e depois não avança mais', () {
      final session = WorkoutSession(workout);
      final total = session.phases.fold(0, (sum, p) => sum + p.seconds);
      final cues = <Cue>[];
      for (var i = 0; i < total; i++) {
        cues.addAll(session.tick());
      }
      expect(session.finished, isTrue);
      expect(cues.last, Cue.finished);
      expect(cues.where((c) => c == Cue.start), hasLength(4));
      expect(session.tick(), isEmpty);
      expect(session.skip(), isNull);
    });

    test('pausado não avança o tempo', () {
      final session = WorkoutSession(workout)..paused = true;
      expect(session.tick(), isEmpty);
      expect(session.remainingSeconds, prepareSeconds);
      session.paused = false;
      session.tick();
      expect(session.remainingSeconds, prepareSeconds - 1);
    });

    test('pular vai para a próxima fase com o aviso dela', () {
      final session = WorkoutSession(workout);
      expect(session.skip(), Cue.start);
      expect(session.current.type, PhaseType.exercise);
      expect(session.skip(), Cue.rest);
      expect(session.remainingSeconds, 4);
      expect(session.next, phase(PhaseType.exercise, 5, 2, 1));
    });

    test('fase curta só conta os números que cabem', () {
      final session = WorkoutSession(
        workout.copyWith(restBetweenExercisesSeconds: 2),
      );
      session
        ..skip()
        ..skip(); // descanso de 2s
      expect(session.tick(), [Cue.one]);
      expect(session.tick(), [Cue.start]);
    });
  });
}
