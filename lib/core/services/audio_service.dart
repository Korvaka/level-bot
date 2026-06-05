import 'package:flutter/services.dart';

enum AudioEvent {
  setComplete,
  restStart,
  restEnd,
  workoutStart,
  workoutComplete,
  personalRecord,
  achievement,
  notification,
}

class AudioService {
  static bool _enabled = true;
  static double _volume = 1.0;

  static bool get isEnabled => _enabled;
  static double get volume => _volume;

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  static void setVolume(double v) {
    _volume = v.clamp(0.0, 1.0);
  }

  static Future<void> play(AudioEvent event) async {
    if (!_enabled) return;
    switch (event) {
      case AudioEvent.setComplete:
        await HapticFeedback.lightImpact();
      case AudioEvent.restStart:
        await HapticFeedback.mediumImpact();
      case AudioEvent.restEnd:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 120));
        await HapticFeedback.heavyImpact();
      case AudioEvent.workoutStart:
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.lightImpact();
      case AudioEvent.workoutComplete:
        for (int i = 0; i < 3; i++) {
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 150));
        }
      case AudioEvent.personalRecord:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.heavyImpact();
      case AudioEvent.achievement:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        await HapticFeedback.mediumImpact();
      case AudioEvent.notification:
        await HapticFeedback.lightImpact();
    }
  }
}
