import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:level_bot/core/services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioSettings {
  const AudioSettings({this.enabled = true, this.volume = 1.0});
  final bool enabled;
  final double volume;

  AudioSettings copyWith({bool? enabled, double? volume}) => AudioSettings(
        enabled: enabled ?? this.enabled,
        volume: volume ?? this.volume,
      );
}

class AudioSettingsNotifier extends StateNotifier<AudioSettings> {
  AudioSettingsNotifier() : super(const AudioSettings()) {
    _load();
  }

  static const _enabledKey = 'audio_enabled';
  static const _volumeKey = 'audio_volume';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_enabledKey) ?? true;
    final volume = prefs.getDouble(_volumeKey) ?? 1.0;
    state = AudioSettings(enabled: enabled, volume: volume);
    AudioService.setEnabled(enabled);
    AudioService.setVolume(volume);
  }

  Future<void> setEnabled(bool v) async {
    state = state.copyWith(enabled: v);
    AudioService.setEnabled(v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, v);
  }

  Future<void> setVolume(double v) async {
    state = state.copyWith(volume: v);
    AudioService.setVolume(v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, v);
  }
}

final audioSettingsProvider =
    StateNotifierProvider<AudioSettingsNotifier, AudioSettings>(
  (ref) => AudioSettingsNotifier(),
);
