import 'package:brandao_timer/models/workout.dart';
import 'package:brandao_timer/screens/timer_screen.dart';
import 'package:brandao_timer/timer/workout_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

void main() {
  const workout = Workout(
    id: '1',
    name: 'Treino A',
    exerciseCount: 2,
    exerciseSeconds: 5,
    restBetweenExercisesSeconds: 4,
    seriesCount: 1,
    restBetweenSeriesSeconds: 0,
  );

  late FakeAnnouncer announcer;
  late FakeScreenAwake screenAwake;

  Future<void> pumpTimer(WidgetTester tester) async {
    announcer = FakeAnnouncer();
    screenAwake = FakeScreenAwake();
    await tester.pumpWidget(
      MaterialApp(
        home: TimerScreen(
          workout: workout,
          announcer: announcer,
          screenAwake: screenAwake,
        ),
      ),
    );
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  Future<void> seconds(WidgetTester tester, int n) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
  }

  testWidgets('mantém a tela acesa e anuncia a preparação', (tester) async {
    await pumpTimer(tester);
    expect(screenAwake.enabled, isTrue);
    expect(announcer.cues, [Cue.prepare]);
    expect(text(tester, 'phaseLabel'), 'PREPARE-SE');
    expect(text(tester, 'remaining'), '0:05');
    expect(
      text(tester, 'position'),
      'Próximo: Exercício 1 de 2 · Série 1 de 1',
    );
  });

  testWidgets('conta o tempo e fala 3, 2, 1, iniciar', (tester) async {
    await pumpTimer(tester);
    await seconds(tester, prepareSeconds);
    expect(announcer.cues, [
      Cue.prepare,
      Cue.three,
      Cue.two,
      Cue.one,
      Cue.start,
    ]);
    expect(text(tester, 'phaseLabel'), 'EXERCÍCIO');
    expect(text(tester, 'remaining'), '0:05');
    expect(text(tester, 'position'), 'Exercício 1 de 2 · Série 1 de 1');
  });

  testWidgets('pausar congela o tempo e continuar retoma', (tester) async {
    await pumpTimer(tester);
    await tester.tap(find.byTooltip('Pausar'));
    await seconds(tester, 3);
    expect(text(tester, 'remaining'), '0:05');

    await tester.tap(find.byTooltip('Continuar'));
    await seconds(tester, 1);
    expect(text(tester, 'remaining'), '0:04');
  });

  testWidgets('mostra conclusão no fim e libera a tela', (tester) async {
    await pumpTimer(tester);
    await seconds(tester, prepareSeconds + 5 + 4 + 5);
    expect(find.text('Treino concluído!'), findsOneWidget);
    expect(announcer.cues.last, Cue.finished);

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(screenAwake.enabled, isFalse);
    expect(announcer.stopped, isTrue);
  });

  testWidgets('pular avança para a próxima fase', (tester) async {
    await pumpTimer(tester);
    await tester.tap(find.byTooltip('Pular'));
    await tester.pump();
    expect(text(tester, 'phaseLabel'), 'EXERCÍCIO');
    expect(announcer.cues.last, Cue.start);
  });

  testWidgets('encerrar pede confirmação', (tester) async {
    await pumpTimer(tester);
    await tester.tap(find.byTooltip('Encerrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.byType(TimerScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Encerrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Encerrar'));
    await tester.pumpAndSettle();
    expect(find.byType(TimerScreen), findsNothing);
    expect(screenAwake.enabled, isFalse);
  });
}
