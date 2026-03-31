import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _storage = GetStorage();

  // ─── Keys ───
  static const _kCoins = 'coins';
  static const _kLives = 'lives';
  static const _kLanguage = 'language';
  static const _kLevelCounter = 'levelCounter';
  static const _kIsPremium = 'isPremium';
  static const _kStreakDays = 'streakDays';
  static const _kSoundEnabled = 'soundEnabled';
  static const _kMusicEnabled = 'musicEnabled';
  static const _kMysteryBoxCounter = 'mysteryBoxCounter';
  static const _kCompletedLevels = 'completedLevels';
  static const _kIsDarkMode = 'isDarkMode';
  static const _kAuthToken = 'authToken';
  static const _kDeviceId  = 'deviceId';
  static const _kCachedPuzzles = 'cached_puzzles';
  static const _kOfflineProgress = 'offline_progress';
  static const _kFcmToken = 'fcmToken';
  static const _kPlayerName = 'playerName';
  static const _kPhoneNumber = 'phoneNumber';
  static const _kXp = 'xp';
  static const _kMaxLives = 'maxLives';
  static const _kLastLifeAt = 'lastLifeAt';
  static const _kRemoteConfig = 'remoteConfig';

  // ─── Initialize ───
  static Future<void> init() async {
    await GetStorage.init();
  }

  // ─── Generic Read/Write ───
  T? read<T>(String key) => _storage.read<T>(key);
  Future<void> write(String key, dynamic value) => _storage.write(key, value);
  Future<void> remove(String key) => _storage.remove(key);
  bool hasKey(String key) => _storage.hasData(key);

  // ─── User Progress ───
  int get coins => _storage.read(_kCoins) ?? 0;
  set coins(int v) => _storage.write(_kCoins, v);

  int get xp => _storage.read(_kXp) ?? 0;
  set xp(int v) => _storage.write(_kXp, v);

  int get lives => _storage.read(_kLives) ?? 5;
  set lives(int v) => _storage.write(_kLives, v);

  int get maxLives => _storage.read(_kMaxLives) ?? 5;
  set maxLives(int v) => _storage.write(_kMaxLives, v);

  String? get lastLifeAt => _storage.read(_kLastLifeAt);
  set lastLifeAt(String? v) => v == null ? _storage.remove(_kLastLifeAt) : _storage.write(_kLastLifeAt, v);

  // ─── Remote Config (cached locally) ───
  Map<String, String> get remoteConfig {
    final raw = _storage.read(_kRemoteConfig);
    if (raw == null) return {};
    try {
      return Map<String, String>.from(raw is String ? json.decode(raw) : raw);
    } catch (_) {
      return {};
    }
  }
  set remoteConfig(Map<String, String> v) => _storage.write(_kRemoteConfig, json.encode(v));

  String get language => _storage.read(_kLanguage) ?? 'en';
  set language(String v) => _storage.write(_kLanguage, v);

  int get levelCounter => _storage.read(_kLevelCounter) ?? 0;
  set levelCounter(int v) => _storage.write(_kLevelCounter, v);

  bool get isPremium => _storage.read(_kIsPremium) ?? false;
  set isPremium(bool v) => _storage.write(_kIsPremium, v);

  int get streakDays => _storage.read(_kStreakDays) ?? 0;
  set streakDays(int v) => _storage.write(_kStreakDays, v);

  bool get soundEnabled => _storage.read(_kSoundEnabled) ?? true;
  set soundEnabled(bool v) => _storage.write(_kSoundEnabled, v);

  bool get musicEnabled => _storage.read(_kMusicEnabled) ?? true;
  set musicEnabled(bool v) => _storage.write(_kMusicEnabled, v);

  bool get isDarkMode => _storage.read(_kIsDarkMode) ?? true;
  set isDarkMode(bool v) => _storage.write(_kIsDarkMode, v);

  int get mysteryBoxCounter => _storage.read(_kMysteryBoxCounter) ?? 0;
  set mysteryBoxCounter(int v) => _storage.write(_kMysteryBoxCounter, v);

  // ─── Auth Token ───
  String? get authToken => _storage.read(_kAuthToken);
  set authToken(String? v) => v == null ? _storage.remove(_kAuthToken) : _storage.write(_kAuthToken, v);

  // ─── Device ID (UUID, generated once, persisted forever) ───
  String? get deviceId => _storage.read(_kDeviceId);
  set deviceId(String? v) => v == null ? _storage.remove(_kDeviceId) : _storage.write(_kDeviceId, v);

  String? get fcmToken => _storage.read(_kFcmToken);
  set fcmToken(String? v) => v == null ? _storage.remove(_kFcmToken) : _storage.write(_kFcmToken, v);

  // ─── Profile ───
  String get playerName => _storage.read(_kPlayerName) ?? '';
  set playerName(String v) => _storage.write(_kPlayerName, v);

  String get phoneNumber => _storage.read(_kPhoneNumber) ?? '';
  set phoneNumber(String v) => _storage.write(_kPhoneNumber, v);

  // ─── Completed Levels ───
  Map<String, Set<int>> get completedLevels {
    final raw = _storage.read(_kCompletedLevels);
    if (raw == null) return {};
    try {
      final Map<String, dynamic> decoded = raw is String ? json.decode(raw) : Map<String, dynamic>.from(raw);
      return decoded.map((k, v) => MapEntry(k, Set<int>.from(v)));
    } catch (_) {
      return {};
    }
  }

  set completedLevels(Map<String, Set<int>> v) {
    _storage.write(_kCompletedLevels, json.encode(v.map((k, s) => MapEntry(k, s.toList()))));
  }

  // ─── Puzzle Cache ───
  Future<void> cachePuzzles(String type, String difficulty, String lang, List<Map<String, dynamic>> data) async {
    await _storage.write('${_kCachedPuzzles}_${type}_${difficulty}_$lang', json.encode(data));
  }

  List<Map<String, dynamic>>? getCachedPuzzles(String type, String difficulty, String lang) {
    final raw = _storage.read('${_kCachedPuzzles}_${type}_${difficulty}_$lang');
    if (raw == null) return null;
    try {
      return List<Map<String, dynamic>>.from(json.decode(raw));
    } catch (_) {
      return null;
    }
  }

  bool hasCachedPuzzles(String type, String difficulty, String lang) {
    return _storage.hasData('${_kCachedPuzzles}_${type}_${difficulty}_$lang');
  }

  // ─── Offline Progress ───
  List<Map<String, dynamic>> get pendingProgress {
    final raw = _storage.read(_kOfflineProgress);
    if (raw == null) return [];
    try {
      return List<Map<String, dynamic>>.from(json.decode(raw));
    } catch (_) {
      return [];
    }
  }

  Future<void> addOfflineProgress(Map<String, dynamic> progress) async {
    final list = pendingProgress..add(progress);
    await _storage.write(_kOfflineProgress, json.encode(list));
  }

  Future<void> clearPendingProgress() async {
    await _storage.remove(_kOfflineProgress);
  }

  // ─── Clear All ───
  Future<void> clearAll() async {
    await _storage.erase();
  }
}
