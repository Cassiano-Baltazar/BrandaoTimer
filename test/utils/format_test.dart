import 'package:brandao_timer/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formata minutos e segundos', () {
    expect(formatDuration(const Duration(seconds: 5)), '0:05');
    expect(formatDuration(const Duration(seconds: 960)), '16:00');
  });

  test('inclui horas quando necessário', () {
    expect(formatDuration(const Duration(seconds: 3725)), '1:02:05');
  });
}
