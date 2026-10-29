import 'package:flutter/material.dart';

import '../data/workout_repository.dart';
import '../models/workout.dart';
import '../utils/format.dart';
import 'workout_edit_screen.dart';

enum _Action { edit, duplicate, delete }

/// Tela inicial: lista dos treinos salvos.
class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key, required this.repository});

  final WorkoutRepository repository;

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  late List<Workout> _workouts = widget.repository.load();

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _update(List<Workout> workouts) async {
    setState(() => _workouts = workouts);
    await widget.repository.save(workouts);
  }

  Future<void> _create() async {
    final created = await Navigator.push<Workout>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutEditScreen(
          workout: Workout.create(id: _newId()),
          isNew: true,
        ),
      ),
    );
    if (created != null) await _update([..._workouts, created]);
  }

  Future<void> _edit(Workout workout) async {
    final edited = await Navigator.push<Workout>(
      context,
      MaterialPageRoute(builder: (_) => WorkoutEditScreen(workout: workout)),
    );
    if (edited != null) {
      await _update([
        for (final w in _workouts) w.id == edited.id ? edited : w,
      ]);
    }
  }

  Future<void> _duplicate(Workout workout) async {
    final index = _workouts.indexOf(workout);
    final copy = workout.copyWith(
      id: _newId(),
      name: '${workout.name} (cópia)',
    );
    await _update([..._workouts]..insert(index + 1, copy));
  }

  Future<void> _delete(Workout workout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar treino?'),
        content: Text('"${workout.name}" será apagado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _update(_workouts.where((w) => w.id != workout.id).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus treinos')),
      body: _workouts.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhum treino ainda.\nToque em + para criar o primeiro.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              itemCount: _workouts.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final w = _workouts[i];
                return ListTile(
                  title: Text(w.name),
                  subtitle: Text(
                    '${w.exerciseCount} exercícios × ${w.seriesCount} séries · '
                    '${w.exerciseSeconds}s / ${w.restBetweenExercisesSeconds}s · '
                    '${formatDuration(w.totalDuration)}',
                  ),
                  onTap: () => _edit(w),
                  trailing: PopupMenuButton<_Action>(
                    tooltip: 'Opções',
                    onSelected: (action) => switch (action) {
                      _Action.edit => _edit(w),
                      _Action.duplicate => _duplicate(w),
                      _Action.delete => _delete(w),
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: _Action.edit, child: Text('Editar')),
                      PopupMenuItem(
                        value: _Action.duplicate,
                        child: Text('Duplicar'),
                      ),
                      PopupMenuItem(
                        value: _Action.delete,
                        child: Text('Apagar'),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        tooltip: 'Novo treino',
        child: const Icon(Icons.add),
      ),
    );
  }
}
