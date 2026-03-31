import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  /// Call on app startup to sync with stored settings
  void init({required bool soundEnabled, required bool musicEnabled}) {
    _soundEnabled = soundEnabled;
    _musicEnabled = musicEnabled;
    if (_musicEnabled) {
      startBackgroundMusic();
    }
  }

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) _sfxPlayer.stop();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (enabled) {
      startBackgroundMusic();
    } else {
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

  // ── Game-specific sounds ──

  Future<void> playDiceRoll() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/dice_roll.mp3');
  }

  Future<void> playPieceMove() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/piece_move.mp3');
  }

  Future<void> playCapture() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/capture.mp3');
  }

  Future<void> playPieceFinish() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/level_complete.mp3');
  }

  Future<void> playGameWin() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/level_complete.mp3');
  }

  Future<void> playGameLose() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/wrong.mp3');
  }

  Future<void> playMerge() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/merge.mp3');
  }

  Future<void> playSpawn() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/click.mp3');
  }

  Future<void> playTilePlace() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/piece_move.mp3');
  }

  Future<void> playTimeWarning() async {
    if (!_soundEnabled) return;
    await _playSafe('sounds/countdown.mp3');
  }

  bool _musicPlaying = false;

  Future<void> startBackgroundMusic() async {
    if (!_musicEnabled || _musicPlaying) return;
    try {
      _musicPlaying = true;
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('sounds/background.mp3'));
      await _musicPlayer.setVolume(0.3);
    } catch (_) {
      _musicPlaying = false;
    }
  }

  Future<void> stopBackgroundMusic() async {
    _musicPlaying = false;
    await _musicPlayer.stop();
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
