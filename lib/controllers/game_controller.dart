import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/constants.dart';
import '../services/storage_service.dart';
import '../services/game_sync_service.dart';
import '../services/api_service.dart';
import '../services/sound_service.dart';

class GameController extends GetxController with WidgetsBindingObserver {
  final _storage = StorageService();
  Timer? _heartbeatTimer;
  Timer? _lifeRecoveryTimer;
  final isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  // ─── Observable State ───
  final coins = 0.obs;       // gems — the real-money currency
  final xp = 0.obs;          // experience points — gameplay currency
  final lives = 5.obs;
  final maxLives = 5.obs;
  final language = 'en'.obs;
  final levelCounter = 0.obs;
  final isPremium = false.obs;
  final streakDays = 0.obs;
  final soundEnabled = true.obs;
  final musicEnabled = true.obs;
  final isDarkMode = true.obs;
  final mysteryBoxCounter = 0.obs;
  final completedLevels = <String, Set<int>>{}.obs;
  final playerName = ''.obs;
  final phoneNumber = ''.obs;
  final lifeRecoverySeconds = 0.obs; // countdown to next life

  // ─── Remote Config (fetched from server, cached locally) ───
  final _config = <String, String>{};

  /// Read a config value with a fallback default.
  int configInt(String key, int fallback) =>
      int.tryParse(_config[key] ?? '') ?? fallback;

  String configStr(String key, String fallback) =>
      _config[key] ?? fallback;

  // ─── Config-driven getters ───
  int get lifeRecoveryMinutes     => configInt('life_recovery_minutes', 30);
  int get xpPerCorrectAnswer      => configInt('xp_per_correct_answer', 10);
  int get xpPerGameWin            => configInt('xp_per_game_win', 25);
  int get xpPerCrossword          => configInt('xp_per_crossword', 15);
  int get xpPerClassicCrossword   => configInt('xp_per_classic_crossword', 20);
  int get gemsPerAd               => configInt('gems_per_ad', 5);
  int get hintCostGems            => configInt('hint_cost_gems', 20);
  int get spawnCostGems           => configInt('spawn_cost_gems', 5);
  int get mergeWinBonusXp         => configInt('merge_win_bonus_xp', 50);
  int get wordCategoryTimer       => configInt('word_category_timer', 30);
  int get interstitialFrequency   => configInt('interstitial_frequency', 3);
  int get mysteryBoxFrequency     => configInt('mystery_box_frequency', 4);
  int get maxDailyAdWatches       => configInt('max_daily_ad_watches', 50);
  int get streakX15Days           => configInt('streak_x15_days', 3);
  int get streakX2Days            => configInt('streak_x2_days', 7);
  int get streakX3Days            => configInt('streak_x3_days', 30);

  // ─── Computed ───
  bool get shouldShowInterstitial => levelCounter.value > 0 && levelCounter.value % interstitialFrequency == 0;
  bool get shouldShowMysteryBox => mysteryBoxCounter.value > 0 && mysteryBoxCounter.value % mysteryBoxFrequency == 0;
  bool get isAr => language.value == 'ar';
  bool get livesAreFull => lives.value >= maxLives.value;

  @override
  void onInit() {
    super.onInit();
    _loadState();
    _loadCachedConfig();
    WidgetsBinding.instance.addObserver(this);
    _startHeartbeat();
    _initConnectivity();
    _recoverLives();
    _startLifeRecoveryTimer();
  }

  @override
  void onClose() {
    _heartbeatTimer?.cancel();
    _lifeRecoveryTimer?.cancel();
    _connectivitySub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startHeartbeat();
      _recoverLives();
      _startLifeRecoveryTimer();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _heartbeatTimer?.cancel();
      _lifeRecoveryTimer?.cancel();
    }
  }

  // ─── Remote Config ─────────────────────────────────────────────────

  void _loadCachedConfig() {
    _config.addAll(_storage.remoteConfig);
  }

  Future<void> fetchConfig() async {
    final data = await ApiService().getConfig();
    if (data != null) {
      final map = data.map((k, v) => MapEntry(k, v.toString()));
      _config
        ..clear()
        ..addAll(map);
      _storage.remoteConfig = map;
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      ApiService().ping();
    });
  }

  Future<void> _initConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    isOnline.value = !result.contains(ConnectivityResult.none);
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      isOnline.value = !results.contains(ConnectivityResult.none);
    });
  }

  // ─── Life Auto-Recovery ───────────────────────────────────────────────

  void _startLifeRecoveryTimer() {
    _lifeRecoveryTimer?.cancel();
    _lifeRecoveryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (livesAreFull) {
        lifeRecoverySeconds.value = 0;
        return;
      }
      final lastStr = _storage.lastLifeAt;
      if (lastStr == null) {
        _storage.lastLifeAt = DateTime.now().toIso8601String();
        return;
      }
      final last = DateTime.tryParse(lastStr) ?? DateTime.now();
      final elapsed = DateTime.now().difference(last).inSeconds;
      final recoverySeconds = lifeRecoveryMinutes * 60;
      final remaining = recoverySeconds - elapsed;

      if (remaining <= 0) {
        _recoverLives();
      } else {
        lifeRecoverySeconds.value = remaining;
      }
    });
  }

  void _recoverLives() {
    if (livesAreFull) return;

    final lastStr = _storage.lastLifeAt;
    if (lastStr == null) {
      _storage.lastLifeAt = DateTime.now().toIso8601String();
      return;
    }

    final last = DateTime.tryParse(lastStr) ?? DateTime.now();
    final elapsed = DateTime.now().difference(last).inMinutes;
    final livesToRecover = elapsed ~/ lifeRecoveryMinutes;

    if (livesToRecover > 0) {
      final newLives = (lives.value + livesToRecover).clamp(0, maxLives.value);
      lives.value = newLives;
      // Set last_life_at to account for partial time
      final usedMinutes = livesToRecover * lifeRecoveryMinutes;
      _storage.lastLifeAt = last.add(Duration(minutes: usedMinutes)).toIso8601String();
      _save();
    }
  }

  // ─── Offline Dialog ───────────────────────────────────────────────────

  void showOfflineRewardDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(24))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rs(24), vertical: rs(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, color: kOrangeColor, size: rs(56)),
              SizedBox(height: rs(12)),
              Text(
                isAr ? 'لا يوجد اتصال' : 'No Connection',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: kFontSizeH3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: rs(12)),
              Text(
                isAr
                    ? 'يمكنك اللعب بدون إنترنت، لكن لا يمكنك جمع الجواهر أو النقاط إلا عند الاتصال بالإنترنت.'
                    : 'You can play offline, but gems and XP can only be earned when connected to the internet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextSecondary,
                  fontSize: kFontSizeBody,
                  height: 1.5,
                ),
              ),
              SizedBox(height: rs(20)),
              SizedBox(
                width: double.infinity,
                height: rs(48),
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(14))),
                  ),
                  child: Text(
                    isAr ? 'حسنًا' : 'OK',
                    style: TextStyle(fontSize: kFontSizeBodyLarge, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // ─── Load / Save ──────────────────────────────────────────────────────

  void _loadState() {
    coins.value = _storage.coins;
    xp.value = _storage.xp;
    lives.value = _storage.lives;
    maxLives.value = _storage.maxLives;
    language.value = _storage.language;
    levelCounter.value = _storage.levelCounter;
    isPremium.value = _storage.isPremium;
    streakDays.value = _storage.streakDays;
    soundEnabled.value = _storage.soundEnabled;
    musicEnabled.value = _storage.musicEnabled;
    SoundService().init(
      soundEnabled: _storage.soundEnabled,
      musicEnabled: _storage.musicEnabled,
    );
    isDarkMode.value = _storage.isDarkMode;
    isDarkObs.value = _storage.isDarkMode;
    mysteryBoxCounter.value = _storage.mysteryBoxCounter;
    completedLevels.value = _storage.completedLevels;
    playerName.value = _storage.playerName;
    phoneNumber.value = _storage.phoneNumber;
  }

  void _save() {
    _storage.coins = coins.value;
    _storage.xp = xp.value;
    _storage.lives = lives.value;
    _storage.maxLives = maxLives.value;
    _storage.language = language.value;
    _storage.levelCounter = levelCounter.value;
    _storage.isPremium = isPremium.value;
    _storage.streakDays = streakDays.value;
    _storage.soundEnabled = soundEnabled.value;
    _storage.musicEnabled = musicEnabled.value;
    _storage.isDarkMode = isDarkMode.value;
    _storage.mysteryBoxCounter = mysteryBoxCounter.value;
    _storage.completedLevels = completedLevels;
    _storage.playerName = playerName.value;
    _storage.phoneNumber = phoneNumber.value;
  }

  // ─── Sync from API (called after device auth on every launch) ───

  void syncFromApi(Map<String, dynamic> user) {
    coins.value        = (user['coins']       as num?)?.toInt() ?? coins.value;
    xp.value           = (user['xp']          as num?)?.toInt() ?? xp.value;
    lives.value        = (user['lives']       as num?)?.toInt() ?? lives.value;
    maxLives.value     = (user['max_lives']   as num?)?.toInt() ?? maxLives.value;
    isPremium.value    = user['is_premium']   as bool? ?? isPremium.value;
    streakDays.value   = (user['streak_days'] as num?)?.toInt() ?? streakDays.value;
    soundEnabled.value = user['sound_enabled'] as bool? ?? soundEnabled.value;
    musicEnabled.value = user['music_enabled'] as bool? ?? musicEnabled.value;
    SoundService().setSoundEnabled(soundEnabled.value);
    SoundService().setMusicEnabled(musicEnabled.value);

    final lastLifeStr = user['last_life_at'] as String?;
    if (lastLifeStr != null) _storage.lastLifeAt = lastLifeStr;

    final apiLang = user['language'] as String?;
    if (apiLang != null && apiLang != language.value) {
      setLanguage(apiLang);
    }
    final apiDark = user['is_dark_mode'] as bool?;
    if (apiDark != null && apiDark != isDarkMode.value) {
      setDarkMode(apiDark);
    }
    final apiName = user['display_name'] as String?;
    if (apiName != null && apiName.isNotEmpty) {
      playerName.value = apiName;
    }
    final apiPhone = user['phone_number'] as String?;
    if (apiPhone != null && apiPhone.isNotEmpty) {
      phoneNumber.value = apiPhone;
    }
    _save();
    _recoverLives();
  }

  // ─── Language ───
  void setLanguage(String lang) {
    _storage.language = lang;
    Get.changeTheme(buildAppTheme(lang, isDarkMode.value));
    Get.updateLocale(Locale(lang));
    language.value = lang;
    _save();
    ApiService().syncLanguage(lang);
  }

  // ─── Theme Mode ───
  void setDarkMode(bool value) {
    isDarkMode.value = value;
    isDarkObs.value = value;
    Get.changeTheme(buildAppTheme(language.value, value));
    _save();
    _syncSettings();
  }

  // ─── Gems (coins) — ONLY from ads & daily rewards ───

  void addGems(int amount) {
    if (!isOnline.value) return;
    coins.value += amount;
    _save();
    _syncBalance();
  }

  /// Legacy alias — screens that used addCoins now call this.
  /// For game wins, use addXp() instead.
  void addCoins(int amount) => addGems(amount);

  void spendCoins(int amount) {
    coins.value = (coins.value - amount).clamp(0, 999999);
    _save();
    _syncBalance();
  }

  // ─── XP — from gameplay ───

  void addXp(int amount, {String source = 'game'}) {
    if (!isOnline.value) return;
    xp.value += amount;
    _save();
    ApiService().addXp(amount: amount, source: source);
  }

  // ─── Lives ───

  void loseLife() {
    if (lives.value > 0) lives.value--;
    if (livesAreFull) {
      // Was full, now lost one — start recovery clock
      _storage.lastLifeAt = DateTime.now().toIso8601String();
    }
    _save();
    if (isOnline.value) _syncBalance();
  }

  void addLife([int count = 1]) {
    if (!isOnline.value) return;
    lives.value = (lives.value + count).clamp(0, maxLives.value);
    _save();
    _syncBalance();
  }

  /// Call after a game ends. If offline, shows dialog and returns false.
  bool checkOnlineForReward() {
    if (!isOnline.value) {
      showOfflineRewardDialog();
      return false;
    }
    return true;
  }

  void _syncBalance() {
    GameSyncService().syncCoinsAndLives(coins.value, lives.value);
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

  /// Streak multiplier for daily gem rewards
  double get streakMultiplier {
    if (streakDays.value >= streakX3Days) return 3.0;
    if (streakDays.value >= streakX2Days) return 2.0;
    if (streakDays.value >= streakX15Days) return 1.5;
    return 1.0;
  }

  // ─── Sound ───
  void setSoundEnabled(bool value) {
    soundEnabled.value = value;
    _save();
    _syncSettings();
  }

  void setMusicEnabled(bool value) {
    musicEnabled.value = value;
    _save();
    _syncSettings();
  }

  void _syncSettings() {
    ApiService().syncSettings(
      soundEnabled: soundEnabled.value,
      musicEnabled: musicEnabled.value,
      isDarkMode: isDarkMode.value,
    );
  }

  // ─── Profile ───
  void setPlayerName(String value) {
    playerName.value = value;
    _save();
  }

  void setPhoneNumber(String value) {
    phoneNumber.value = value;
    _save();
  }

  Future<void> syncProfile() async {
    await ApiService().updateProfile(
      displayName: playerName.value,
      phoneNumber: phoneNumber.value,
    );
  }

  // ─── Mystery Box ───
  void resetMysteryBoxCounter() {
    mysteryBoxCounter.value = 0;
    _save();
  }

  bool tryShowMysteryBox() {
    if (shouldShowMysteryBox) {
      Get.toNamed('/mystery-box');
      return true;
    }
    return false;
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
