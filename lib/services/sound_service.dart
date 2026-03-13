import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) _sfxPlayer.stop();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.stop();
    }
  }

  Future<void> _playSafe(String asset) async {
    try {
      await _sfxPlayer.play(AssetSource(asset));
    } catch (_) {
      // Sound file not available - silently ignore
    }
  }

  Future<void> playCorrect() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/correct.mp3');
  }

  Future<void> playWrong() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/wrong.mp3');
  }

  Future<void> playLevelComplete() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/level_complete.mp3');
  }

  Future<void> playClick() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/click.mp3');
  }

  Future<void> playCountdown() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/countdown.mp3');
  }

  Future<void> playReward() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/reward.mp3');
  }

  Future<void> startBackgroundMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('sounds/background.mp3'));
      await _musicPlayer.setVolume(0.3);
    } catch (_) {
      // Music file not available - silently ignore
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
