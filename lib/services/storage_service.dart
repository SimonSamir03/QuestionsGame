import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _box = GetStorage();

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
  static const _kAuthToken = 'authToken';
  static const _kCachedPuzzles = 'cached_puzzles';
  static const _kOfflineProgress = 'offline_progress';

  // ─── Initialize ───
  static Future<void> init() async {
    await GetStorage.init();
  }

  // ─── Generic Read/Write ───
  T? read<T>(String key) => _box.read<T>(key);
  Future<void> write(String key, dynamic value) => _box.write(key, value);
  Future<void> remove(String key) => _box.remove(key);
  bool hasKey(String key) => _box.hasData(key);

  // ─── User Progress ───
  int get coins => _box.read(_kCoins) ?? 0;
  set coins(int v) => _box.write(_kCoins, v);

  int get lives => _box.read(_kLives) ?? 5;
  set lives(int v) => _box.write(_kLives, v);

  String get language => _box.read(_kLanguage) ?? 'en';
  set language(String v) => _box.write(_kLanguage, v);

  int get levelCounter => _box.read(_kLevelCounter) ?? 0;
  set levelCounter(int v) => _box.write(_kLevelCounter, v);

  bool get isPremium => _box.read(_kIsPremium) ?? false;
  set isPremium(bool v) => _box.write(_kIsPremium, v);

  int get streakDays => _box.read(_kStreakDays) ?? 0;
  set streakDays(int v) => _box.write(_kStreakDays, v);

  bool get soundEnabled => _box.read(_kSoundEnabled) ?? true;
  set soundEnabled(bool v) => _box.write(_kSoundEnabled, v);

  bool get musicEnabled => _box.read(_kMusicEnabled) ?? true;
  set musicEnabled(bool v) => _box.write(_kMusicEnabled, v);

  int get mysteryBoxCounter => _box.read(_kMysteryBoxCounter) ?? 0;
  set mysteryBoxCounter(int v) => _box.write(_kMysteryBoxCounter, v);

  // ─── Auth Token ───
  String? get authToken => _box.read(_kAuthToken);
  set authToken(String? v) => v == null ? _box.remove(_kAuthToken) : _box.write(_kAuthToken, v);

  // ─── Completed Levels ───
  Map<String, Set<int>> get completedLevels {
    final raw = _box.read(_kCompletedLevels);
    if (raw == null) return {};
    try {
      final Map<String, dynamic> decoded = raw is String ? json.decode(raw) : Map<String, dynamic>.from(raw);
      return decoded.map((k, v) => MapEntry(k, Set<int>.from(v)));
    } catch (_) {
      return {};
    }
  }

  set completedLevels(Map<String, Set<int>> v) {
    _box.write(_kCompletedLevels, json.encode(v.map((k, s) => MapEntry(k, s.toList()))));
  }

  // ─── Puzzle Cache ───
  Future<void> cachePuzzles(String type, String difficulty, String lang, List<Map<String, dynamic>> data) async {
    await _box.write('${_kCachedPuzzles}_${type}_${difficulty}_$lang', json.encode(data));
  }

  List<Map<String, dynamic>>? getCachedPuzzles(String type, String difficulty, String lang) {
    final raw = _box.read('${_kCachedPuzzles}_${type}_${difficulty}_$lang');
    if (raw == null) return null;
    try {
      return List<Map<String, dynamic>>.from(json.decode(raw));
    } catch (_) {
      return null;
    }
  }

  bool hasCachedPuzzles(String type, String difficulty, String lang) {
    return _box.hasData('${_kCachedPuzzles}_${type}_${difficulty}_$lang');
  }

  // ─── Offline Progress ───
  List<Map<String, dynamic>> get pendingProgress {
    final raw = _box.read(_kOfflineProgress);
    if (raw == null) return [];
    try {
      return List<Map<String, dynamic>>.from(json.decode(raw));
    } catch (_) {
      return [];
    }
  }

  Future<void> addOfflineProgress(Map<String, dynamic> progress) async {
    final list = pendingProgress..add(progress);
    await _box.write(_kOfflineProgress, json.encode(list));
  }

  Future<void> clearPendingProgress() async {
    await _box.remove(_kOfflineProgress);
  }

  // ─── Clear All ───
  Future<void> clearAll() async {
    await _box.erase();
  }
}
