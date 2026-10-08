import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

abstract final class SoundHelper {
  static final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static Future<void> playTaskAdded() async {
    try {
      HapticFeedback.lightImpact();
      await _player.stop();
      await _player.play(AssetSource('sounds/task_added.wav'), volume: 0.9);
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  static Future<void> playTaskCompleted() async {
    try {
      HapticFeedback.heavyImpact();
      await _player.stop();
      await _player.play(AssetSource('sounds/task_completed.wav'), volume: 1.0);
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
