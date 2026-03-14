import 'package:get/get.dart';
import '../services/storage_service.dart';

class GameController extends GetxController {
  final _storage = StorageService();

  // ─── Observable State ───
  final coins = 0.obs;
  final lives = 5.obs;
  final language = 'en'.obs;
  final levelCounter = 0.obs;
  final isPremium = false.obs;
  final streakDays = 0.obs;
  final soundEnabled = true.obs;
  final musicEnabled = true.obs;
  final mysteryBoxCounter = 0.obs;
  final completedLevels = <String, Set<int>>{}.obs;

  // ─── Computed ───
  bool get shouldShowInterstitial => levelCounter.value > 0 && levelCounter.value % 3 == 0;
  bool get shouldShowMysteryBox => mysteryBoxCounter.value > 0 && mysteryBoxCounter.value % 4 == 0;
  bool get isAr => language.value == 'ar';

  @override
  void onInit() {
    super.onInit();
    _loadState();
  }

  void _loadState() {
    coins.value = _storage.coins;
    lives.value = _storage.lives;
    language.value = _storage.language;
    levelCounter.value = _storage.levelCounter;
    isPremium.value = _storage.isPremium;
    streakDays.value = _storage.streakDays;
    soundEnabled.value = _storage.soundEnabled;
    musicEnabled.value = _storage.musicEnabled;
    mysteryBoxCounter.value = _storage.mysteryBoxCounter;
    completedLevels.value = _storage.completedLevels;
  }

  void _save() {
    _storage.coins = coins.value;
    _storage.lives = lives.value;
    _storage.language = language.value;
    _storage.levelCounter = levelCounter.value;
    _storage.isPremium = isPremium.value;
    _storage.streakDays = streakDays.value;
    _storage.soundEnabled = soundEnabled.value;
    _storage.musicEnabled = musicEnabled.value;
    _storage.mysteryBoxCounter = mysteryBoxCounter.value;
    _storage.completedLevels = completedLevels;
  }

  // ─── Language ───
  void setLanguage(String lang) {
    language.value = lang;
    _save();
  }

  // ─── Coins ───
  void addCoins(int amount) {
    coins.value += amount;
    _save();
  }

  void spendCoins(int amount) {
    coins.value = (coins.value - amount).clamp(0, 999999);
    _save();
  }

  // ─── Lives ───
  void loseLife() {
    if (lives.value > 0) lives.value--;
    _save();
  }

  void addLife([int count = 1]) {
    lives.value += count;
    _save();
  }

  // ─── Level Counter ───
  void incrementLevelCounter() {
    levelCounter.value++;
    mysteryBoxCounter.value++;
    _save();
  }

  // ─── Premium ───
  void setPremium(bool value) {
    isPremium.value = value;
    _save();
  }

  // ─── Streak ───
  void setStreakDays(int days) {
    streakDays.value = days;
    _save();
  }

  // ─── Sound ───
  void setSoundEnabled(bool value) {
    soundEnabled.value = value;
    _save();
  }

  void setMusicEnabled(bool value) {
    musicEnabled.value = value;
    _save();
  }

  // ─── Mystery Box ───
  void resetMysteryBoxCounter() {
    mysteryBoxCounter.value = 0;
    _save();
  }

  // ─── Level Completion ───
  bool isLevelUnlocked(String gameType, String difficulty, int index) {
    if (index == 0) return true;
    final key = '${gameType}_$difficulty';
    return completedLevels[key]?.contains(index - 1) ?? false;
  }

  bool isLevelCompleted(String gameType, String difficulty, int index) {
    final key = '${gameType}_$difficulty';
    return completedLevels[key]?.contains(index) ?? false;
  }

  void completeLevel(String gameType, String difficulty, int index) {
    final key = '${gameType}_$difficulty';
    final updated = Map<String, Set<int>>.from(completedLevels);
    updated[key] ??= {};
    updated[key]!.add(index);
    completedLevels.value = updated;
    _save();
  }
}
