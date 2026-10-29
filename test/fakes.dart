import 'package:brandao_timer/services/announcer.dart';
import 'package:brandao_timer/services/screen_awake.dart';
import 'package:brandao_timer/timer/workout_session.dart';

class FakeAnnouncer implements Announcer {
  final cues = <Cue>[];
  var stopped = false;

  @override
  Future<void> announce(Cue cue) async => cues.add(cue);

  @override
  Future<void> stop() async => stopped = true;
}

class FakeScreenAwake implements ScreenAwake {
  var enabled = false;

  @override
  Future<void> enable() async => enabled = true;

  @override
  Future<void> disable() async => enabled = false;
}
