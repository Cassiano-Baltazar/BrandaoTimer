import 'package:wakelock_plus/wakelock_plus.dart';

/// Mantém a tela acesa durante o treino.
abstract class ScreenAwake {
  Future<void> enable();
  Future<void> disable();
}

class WakelockScreenAwake implements ScreenAwake {
  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}
