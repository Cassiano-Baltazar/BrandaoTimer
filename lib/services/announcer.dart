import 'package:flutter_tts/flutter_tts.dart';

import '../timer/workout_session.dart';

/// Fala os avisos do treino.
abstract class Announcer {
  Future<void> announce(Cue cue);
  Future<void> stop();
}

/// Usa a voz do próprio aparelho, em português, sem internet.
class TtsAnnouncer implements Announcer {
  TtsAnnouncer() {
    _ready = _init();
  }

  final _tts = FlutterTts();
  late final Future<void> _ready;

  Future<void> _init() async {
    await _tts.setLanguage('pt-BR');
    await _tts.setSpeechRate(0.6);
    await _tts.awaitSpeakCompletion(false);
  }

  @override
  Future<void> announce(Cue cue) async {
    await _ready;
    await _tts.speak(cue.text);
  }

  @override
  Future<void> stop() => _tts.stop();
}
