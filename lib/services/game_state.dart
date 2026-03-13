import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState extends ChangeNotifier {
  int _coins = 0;
  int _lives = 5;
  String _language = 'en';
  int _levelCounter = 0;
  bool _isPremium = false;
  int _streakDays = 0;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  int _mysteryBoxCounter = 0;
  // Track completed levels: key = "gameType_difficulty", value = set of completed level indices
  Map<String, Set<int>> _completedLevels = {};

  int get coins => _coins;
  int get lives => _lives;
  String get language => _language;
  int get levelCounter => _levelCounter;
  bool get isPremium => _isPremium;
  int get streakDays => _streakDays;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  int get mysteryBoxCounter => _mysteryBoxCounter;
  bool get shouldShowInterstitial => _levelCounter > 0 && _levelCounter % 3 == 0;
  bool get shouldShowMysteryBox => _levelCounter > 0 && _levelCounter % 4 == 0;

  /// Check if a level is unlocked (level 0 always unlocked, others need previous completed)
  bool isLevelUnlocked(String gameType, String difficulty, int index) {
    if (index == 0) return true;
    final key = '${gameType}_$difficulty';
    return _completedLevels[key]?.contains(index - 1) ?? false;
  }

  /// Check if a level is completed
  bool isLevelCompleted(String gameType, String difficulty, int index) {
    final key = '${gameType}_$difficulty';
    return _completedLevels[key]?.contains(index) ?? false;
  }

  /// Mark a level as completed
  void completeLevel(String gameType, String difficulty, int index) {
    final key = '${gameType}_$difficulty';
    _completedLevels[key] ??= {};
    _completedLevels[key]!.add(index);
    _saveState();
    notifyListeners();
  }

  GameState() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 0;
    _lives = prefs.getInt('lives') ?? 5;
    _language = prefs.getString('language') ?? 'en';
    _levelCounter = prefs.getInt('levelCounter') ?? 0;
    _isPremium = prefs.getBool('isPremium') ?? false;
    _streakDays = prefs.getInt('streakDays') ?? 0;
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    _mysteryBoxCounter = prefs.getInt('mysteryBoxCounter') ?? 0;
    // Load completed levels
    final completedJson = prefs.getString('completedLevels');
    if (completedJson != null) {
      final Map<String, dynamic> decoded = json.decode(completedJson);
      _completedLevels = decoded.map((k, v) => MapEntry(k, Set<int>.from(v)));
    }
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
    await prefs.setInt('lives', _lives);
    await prefs.setString('language', _language);
    await prefs.setInt('levelCounter', _levelCounter);
    await prefs.setBool('isPremium', _isPremium);
    await prefs.setInt('streakDays', _streakDays);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
    await prefs.setInt('mysteryBoxCounter', _mysteryBoxCounter);
    // Save completed levels
    final completedJson = json.encode(
      _completedLevels.map((k, v) => MapEntry(k, v.toList())),
    );
    await prefs.setString('completedLevels', completedJson);
  }

  void setLanguage(String lang) {
    _language = lang;
    _saveState();
    notifyListeners();
  }

  void addCoins(int amount) {
    _coins += amount;
    _saveState();
    notifyListeners();
  }

  void spendCoins(int amount) {
    _coins = (_coins - amount).clamp(0, 999999);
    _saveState();
    notifyListeners();
  }

  void loseLife() {
    if (_lives > 0) _lives--;
    _saveState();
    notifyListeners();
  }

  void addLife([int count = 1]) {
    _lives += count;
    _saveState();
    notifyListeners();
  }

  void incrementLevelCounter() {
    _levelCounter++;
    _mysteryBoxCounter++;
    _saveState();
    notifyListeners();
  }

  void setPremium(bool value) {
    _isPremium = value;
    _saveState();
    notifyListeners();
  }

  void setStreakDays(int days) {
    _streakDays = days;
    _saveState();
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    _saveState();
    notifyListeners();
  }

  void setMusicEnabled(bool value) {
    _musicEnabled = value;
    _saveState();
    notifyListeners();
  }

  void resetMysteryBoxCounter() {
    _mysteryBoxCounter = 0;
    _saveState();
    notifyListeners();
  }
}
