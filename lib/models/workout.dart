/// Um treino salvo: exercícios em séries, com descansos entre eles.
class Workout {
  const Workout({
    required this.id,
    required this.name,
    required this.exerciseCount,
    required this.exerciseSeconds,
    required this.restBetweenExercisesSeconds,
    required this.seriesCount,
    required this.restBetweenSeriesSeconds,
  });

  /// Valores sugeridos para um treino novo.
  factory Workout.create({required String id}) => Workout(
    id: id,
    name: 'Novo treino',
    exerciseCount: 5,
    exerciseSeconds: 40,
    restBetweenExercisesSeconds: 20,
    seriesCount: 3,
    restBetweenSeriesSeconds: 60,
  );

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'] as String,
    name: json['name'] as String,
    exerciseCount: json['exerciseCount'] as int,
    exerciseSeconds: json['exerciseSeconds'] as int,
    restBetweenExercisesSeconds: json['restBetweenExercisesSeconds'] as int,
    seriesCount: json['seriesCount'] as int,
    restBetweenSeriesSeconds: json['restBetweenSeriesSeconds'] as int,
  );

  final String id;
  final String name;
  final int exerciseCount;
  final int exerciseSeconds;
  final int restBetweenExercisesSeconds;
  final int seriesCount;
  final int restBetweenSeriesSeconds;

  /// Duração total do treino. Não há descanso depois do último exercício
  /// de uma série nem depois da última série.
  Duration get totalDuration {
    final perSeries =
        exerciseCount * exerciseSeconds +
        (exerciseCount - 1) * restBetweenExercisesSeconds;
    final total =
        seriesCount * perSeries + (seriesCount - 1) * restBetweenSeriesSeconds;
    return Duration(seconds: total);
  }

  Workout copyWith({
    String? id,
    String? name,
    int? exerciseCount,
    int? exerciseSeconds,
    int? restBetweenExercisesSeconds,
    int? seriesCount,
    int? restBetweenSeriesSeconds,
  }) => Workout(
    id: id ?? this.id,
    name: name ?? this.name,
    exerciseCount: exerciseCount ?? this.exerciseCount,
    exerciseSeconds: exerciseSeconds ?? this.exerciseSeconds,
    restBetweenExercisesSeconds:
        restBetweenExercisesSeconds ?? this.restBetweenExercisesSeconds,
    seriesCount: seriesCount ?? this.seriesCount,
    restBetweenSeriesSeconds:
        restBetweenSeriesSeconds ?? this.restBetweenSeriesSeconds,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'exerciseCount': exerciseCount,
    'exerciseSeconds': exerciseSeconds,
    'restBetweenExercisesSeconds': restBetweenExercisesSeconds,
    'seriesCount': seriesCount,
    'restBetweenSeriesSeconds': restBetweenSeriesSeconds,
  };

  @override
  bool operator ==(Object other) =>
      other is Workout &&
      other.id == id &&
      other.name == name &&
      other.exerciseCount == exerciseCount &&
      other.exerciseSeconds == exerciseSeconds &&
      other.restBetweenExercisesSeconds == restBetweenExercisesSeconds &&
      other.seriesCount == seriesCount &&
      other.restBetweenSeriesSeconds == restBetweenSeriesSeconds;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    exerciseCount,
    exerciseSeconds,
    restBetweenExercisesSeconds,
    seriesCount,
    restBetweenSeriesSeconds,
  );
}
