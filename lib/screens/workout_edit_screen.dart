import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/workout.dart';
import '../utils/format.dart';

/// Cria ou edita um treino. Devolve o treino salvo via [Navigator.pop].
class WorkoutEditScreen extends StatefulWidget {
  const WorkoutEditScreen({
    super.key,
    required this.workout,
    this.isNew = false,
  });

  final Workout workout;
  final bool isNew;

  @override
  State<WorkoutEditScreen> createState() => _WorkoutEditScreenState();
}

class _WorkoutEditScreenState extends State<WorkoutEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.workout.name);
  late final _exerciseCount = TextEditingController(
    text: '${widget.workout.exerciseCount}',
  );
  late final _exerciseSeconds = TextEditingController(
    text: '${widget.workout.exerciseSeconds}',
  );
  late final _restExercises = TextEditingController(
    text: '${widget.workout.restBetweenExercisesSeconds}',
  );
  late final _seriesCount = TextEditingController(
    text: '${widget.workout.seriesCount}',
  );
  late final _restSeries = TextEditingController(
    text: '${widget.workout.restBetweenSeriesSeconds}',
  );

  @override
  void dispose() {
    for (final c in [
      _name,
      _exerciseCount,
      _exerciseSeconds,
      _restExercises,
      _seriesCount,
      _restSeries,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Monta o treino a partir dos campos, ou null se algum for inválido.
  Workout? _current() {
    final values = [
      _exerciseCount,
      _exerciseSeconds,
      _restExercises,
      _seriesCount,
      _restSeries,
    ].map((c) => int.tryParse(c.text)).toList();
    if (values.contains(null)) return null;
    return widget.workout.copyWith(
      name: _name.text.trim(),
      exerciseCount: values[0],
      exerciseSeconds: values[1],
      restBetweenExercisesSeconds: values[2],
      seriesCount: values[3],
      restBetweenSeriesSeconds: values[4],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _current());
  }

  @override
  Widget build(BuildContext context) {
    final preview = _current();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Novo treino' : 'Editar treino'),
        actions: [
          IconButton(
            key: const Key('save'),
            icon: const Icon(Icons.check),
            tooltip: 'Salvar',
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('name'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome do treino'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
            ),
            _NumberField(
              fieldKey: const Key('exerciseCount'),
              controller: _exerciseCount,
              label: 'Quantidade de exercícios',
              min: 1,
            ),
            _NumberField(
              fieldKey: const Key('exerciseSeconds'),
              controller: _exerciseSeconds,
              label: 'Tempo de cada exercício',
              suffix: 's',
              min: 1,
            ),
            _NumberField(
              fieldKey: const Key('restExercises'),
              controller: _restExercises,
              label: 'Descanso entre exercícios',
              suffix: 's',
              min: 0,
            ),
            _NumberField(
              fieldKey: const Key('seriesCount'),
              controller: _seriesCount,
              label: 'Quantidade de séries',
              min: 1,
            ),
            _NumberField(
              fieldKey: const Key('restSeries'),
              controller: _restSeries,
              label: 'Descanso entre séries',
              suffix: 's',
              min: 0,
            ),
            const SizedBox(height: 24),
            if (preview != null)
              Text(
                'Duração total: ${formatDuration(preview.totalDuration)}',
                key: const Key('totalDuration'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.min,
    this.suffix,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final int min;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) {
        final n = int.tryParse(v ?? '');
        if (n == null) return 'Informe um número';
        if (n < min) return 'Mínimo $min';
        return null;
      },
    );
  }
}
