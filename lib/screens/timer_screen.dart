import 'dart:async';

import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/announcer.dart';
import '../services/screen_awake.dart';
import '../timer/workout_session.dart';
import '../utils/format.dart';

/// Executa um treino: contagem, avisos falados, pausar, pular e encerrar.
class TimerScreen extends StatefulWidget {
  const TimerScreen({
    super.key,
    required this.workout,
    required this.announcer,
    required this.screenAwake,
  });

  final Workout workout;
  final Announcer announcer;
  final ScreenAwake screenAwake;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late final _session = WorkoutSession(widget.workout);
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    widget.screenAwake.enable();
    widget.announcer.announce(_session.startCue);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    widget.announcer.stop();
    widget.screenAwake.disable();
    super.dispose();
  }

  void _tick() {
    final cues = _session.tick();
    _announce(cues);
    if (_session.finished) _ticker?.cancel();
    setState(() {});
  }

  void _announce(Iterable<Cue> cues) {
    for (final cue in cues) {
      widget.announcer.announce(cue);
    }
  }

  void _togglePause() => setState(() => _session.paused = !_session.paused);

  void _skip() {
    final cue = _session.skip();
    if (cue != null) _announce([cue]);
    if (_session.finished) _ticker?.cancel();
    setState(() {});
  }

  Future<void> _confirmStop() async {
    final stop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar treino?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
    if (stop == true && mounted) Navigator.pop(context);
  }

  static String _label(PhaseType type) => switch (type) {
    PhaseType.prepare => 'PREPARE-SE',
    PhaseType.exercise => 'EXERCÍCIO',
    PhaseType.rest => 'DESCANSO',
    PhaseType.seriesRest => 'DESCANSO ENTRE SÉRIES',
  };

  static Color _color(PhaseType type) => switch (type) {
    PhaseType.prepare => Colors.blueGrey.shade700,
    PhaseType.exercise => Colors.deepOrange.shade700,
    PhaseType.rest => Colors.teal.shade700,
    PhaseType.seriesRest => Colors.indigo.shade700,
  };

  @override
  Widget build(BuildContext context) {
    final w = widget.workout;
    final phase = _session.current;
    final finished = _session.finished;
    final background = finished ? Colors.green.shade700 : _color(phase.type);
    final textTheme = Theme.of(context).textTheme;

    final position =
        'Exercício ${phase.exerciseNumber} de ${w.exerciseCount} · '
        'Série ${phase.seriesNumber} de ${w.seriesCount}';

    return PopScope(
      canPop: finished,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmStop();
      },
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: Text(w.name),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: finished
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Treino concluído!',
                          style: textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Voltar'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        Text(
                          _label(phase.type),
                          key: const Key('phaseLabel'),
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            formatDuration(
                              Duration(seconds: _session.remainingSeconds),
                            ),
                            key: const Key('remaining'),
                            style: const TextStyle(
                              fontSize: 160,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        Text(
                          phase.type == PhaseType.exercise
                              ? position
                              : 'Próximo: $position',
                          key: const Key('position'),
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _RoundButton(
                              icon: Icons.stop,
                              tooltip: 'Encerrar',
                              onPressed: _confirmStop,
                            ),
                            _RoundButton(
                              icon: _session.paused
                                  ? Icons.play_arrow
                                  : Icons.pause,
                              tooltip: _session.paused ? 'Continuar' : 'Pausar',
                              onPressed: _togglePause,
                              large: true,
                            ),
                            _RoundButton(
                              icon: Icons.skip_next,
                              tooltip: 'Pular',
                              onPressed: _skip,
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.large = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: large ? 56 : 36,
      padding: EdgeInsets.all(large ? 20 : 14),
      onPressed: onPressed,
    );
  }
}
