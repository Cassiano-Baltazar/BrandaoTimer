import 'package:brandao_timer/data/workout_repository.dart';
import 'package:brandao_timer/main.dart';
import 'package:brandao_timer/models/workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late WorkoutRepository repository;

  Future<void> pumpApp(
    WidgetTester tester, [
    List<Workout> initial = const [],
  ]) async {
    SharedPreferences.setMockInitialValues({});
    repository = WorkoutRepository(await SharedPreferences.getInstance());
    await repository.save(initial);
    await tester.pumpWidget(BrandaoTimerApp(repository: repository));
  }

  Future<void> openMenu(WidgetTester tester, String item) async {
    await tester.tap(find.byTooltip('Opções').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
  }

  final treinoA = Workout.create(id: '1').copyWith(name: 'Treino A');

  testWidgets('mostra mensagem quando não há treinos', (tester) async {
    await pumpApp(tester);
    expect(find.textContaining('Nenhum treino ainda'), findsOneWidget);
  });

  testWidgets('cria um treino e salva no aparelho', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('name')), 'Pernas');
    await tester.enterText(find.byKey(const Key('exerciseCount')), '4');
    await tester.pump();
    // 4*40 + 3*20 = 220s por série; 3*220 + 2*60 = 780s.
    expect(find.text('Duração total: 13:00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('save')));
    await tester.pumpAndSettle();

    expect(find.text('Pernas'), findsOneWidget);
    final saved = repository.load().single;
    expect(saved.name, 'Pernas');
    expect(saved.exerciseCount, 4);
  });

  testWidgets('não salva com campos inválidos', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('name')), '  ');
    await tester.enterText(find.byKey(const Key('seriesCount')), '0');
    await tester.tap(find.byKey(const Key('save')));
    await tester.pumpAndSettle();

    expect(find.text('Informe um nome'), findsOneWidget);
    expect(find.text('Mínimo 1'), findsOneWidget);
    expect(repository.load(), isEmpty);
  });

  testWidgets('edita um treino existente', (tester) async {
    await pumpApp(tester, [treinoA]);
    await tester.tap(find.text('Treino A'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('name')), 'Treino A2');
    await tester.tap(find.byKey(const Key('save')));
    await tester.pumpAndSettle();

    expect(find.text('Treino A2'), findsOneWidget);
    expect(repository.load().single.id, '1');
  });

  testWidgets('duplica um treino com novo id', (tester) async {
    await pumpApp(tester, [treinoA]);
    await openMenu(tester, 'Duplicar');

    final saved = repository.load();
    expect(saved.map((w) => w.name), ['Treino A', 'Treino A (cópia)']);
    expect(saved[1].id, isNot(saved[0].id));
  });

  testWidgets('apaga só depois de confirmar', (tester) async {
    await pumpApp(tester, [treinoA]);

    await openMenu(tester, 'Apagar');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repository.load(), hasLength(1));

    await openMenu(tester, 'Apagar');
    await tester.tap(find.widgetWithText(TextButton, 'Apagar'));
    await tester.pumpAndSettle();
    expect(repository.load(), isEmpty);
    expect(find.text('Treino A'), findsNothing);
  });
}
