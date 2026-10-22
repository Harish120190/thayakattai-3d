import 'package:flutter/services.dart';

class AudioService {
  final bool Function() isSoundEnabled;
  final bool Function() isHapticsEnabled;

  AudioService({
    required this.isSoundEnabled,
    required this.isHapticsEnabled,
  });

  /// Plays dice rolling haptic and audio trigger
  void playDiceRoll() {
    if (isHapticsEnabled()) {
      HapticFeedback.mediumImpact();
    }
    if (isSoundEnabled()) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Plays token step movement sound & haptic
  void playTokenMove() {
    if (isHapticsEnabled()) {
      HapticFeedback.selectionClick();
    }
    if (isSoundEnabled()) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Plays capture ("Vettu") sound & strong haptic
  void playCapture() {
    if (isHapticsEnabled()) {
      HapticFeedback.heavyImpact();
    }
    if (isSoundEnabled()) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  /// Plays victory fanfare sound & celebratory haptic
  void playVictory() {
    if (isHapticsEnabled()) {
      HapticFeedback.vibrate();
    }
    if (isSoundEnabled()) {
      SystemSound.play(SystemSoundType.alert);
    }
  }
}
