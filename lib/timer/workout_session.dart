import '../models/workout.dart';

enum PhaseType { prepare, exercise, rest, seriesRest }

/// Um trecho do treino com duração fixa. Em descansos, [exerciseNumber] e
/// [seriesNumber] indicam o próximo exercício.
class Phase {
  const Phase({
    required this.type,
    required this.seconds,
    required this.exerciseNumber,
    required this.seriesNumber,
  });

  final PhaseType type;
  final int seconds;
  final int exerciseNumber;
  final int seriesNumber;

  @override
  bool operator ==(Object other) =>
      other is Phase &&
      other.type == type &&
      other.seconds == seconds &&
      other.exerciseNumber == exerciseNumber &&
      other.seriesNumber == seriesNumber;

  @override
  int get hashCode => Object.hash(type, seconds, exerciseNumber, seriesNumber);

  @override
  String toString() =>
      'Phase($type, ${seconds}s, ex $exerciseNumber, '
      'série $seriesNumber)';
}

/// Avisos falados durante o treino.
enum Cue {
  three('três'),
  two('dois'),
  one('um'),
  prepare('Prepare-se'),
  start('Iniciar'),
  rest('Descansar'),
  finished('Treino concluído');

  const Cue(this.text);

  final String text;
}

/// Tempo de preparação antes do primeiro exercício.
const prepareSeconds = 5;

/// Sequência de fases do treino. Descansos com tempo zero são omitidos.
List<Phase> buildPhases(Workout w) {
  final phases = [
    const Phase(
      type: PhaseType.prepare,
      seconds: prepareSeconds,
      exerciseNumber: 1,
      seriesNumber: 1,
    ),
  ];
  for (var s = 1; s <= w.seriesCount; s++) {
    for (var e = 1; e <= w.exerciseCount; e++) {
      final restType = e == 1 ? PhaseType.seriesRest : PhaseType.rest;
      final restSeconds = e == 1
          ? w.restBetweenSeriesSeconds
          : w.restBetweenExercisesSeconds;
      final isFirst = s == 1 && e == 1;
      if (!isFirst && restSeconds > 0) {
        phases.add(
          Phase(
            type: restType,
            seconds: restSeconds,
            exerciseNumber: e,
            seriesNumber: s,
          ),
        );
      }
      phases.add(
        Phase(
          type: PhaseType.exercise,
          seconds: w.exerciseSeconds,
          exerciseNumber: e,
          seriesNumber: s,
        ),
      );
    }
  }
  return phases;
}

/// Andamento do treino, avançado um segundo por vez com [tick]. Não depende
/// de relógio real, para poder ser testado.
class WorkoutSession {
  WorkoutSession(this.workout) : phases = buildPhases(workout) {
    _remaining = phases.first.seconds;
  }

  final Workout workout;
  final List<Phase> phases;

  int _index = 0;
  late int _remaining;
  bool _finished = false;

  bool paused = false;

  Phase get current => phases[_index];
  int get remainingSeconds => _remaining;
  bool get finished => _finished;

  /// Fase seguinte, ou null se esta é a última.
  Phase? get next => _index + 1 < phases.length ? phases[_index + 1] : null;

  /// Aviso a dar quando o treino começa.
  Cue get startCue => Cue.prepare;

  /// Passa um segundo e devolve os avisos desse instante.
  List<Cue> tick() {
    if (_finished || paused) return const [];
    _remaining--;
    if (_remaining > 0) {
      return switch (_remaining) {
        3 => const [Cue.three],
        2 => const [Cue.two],
        1 => const [Cue.one],
        _ => const [],
      };
    }
    return [_advance()];
  }

  /// Pula para a próxima fase e devolve o aviso dela.
  Cue? skip() => _finished ? null : _advance();

  Cue _advance() {
    if (_index + 1 >= phases.length) {
      _finished = true;
      _remaining = 0;
      return Cue.finished;
    }
    _index++;
    _remaining = current.seconds;
    return current.type == PhaseType.exercise ? Cue.start : Cue.rest;
  }
}
