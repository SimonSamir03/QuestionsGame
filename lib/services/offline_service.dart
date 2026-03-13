import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/puzzle_model.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  static const String _puzzleCacheKey = 'cached_puzzles';
  static const String _progressKey = 'offline_progress';
  // Cache puzzles for offline play
  Future<void> cachePuzzles(String type, String difficulty, String language, List<Puzzle> puzzles) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_puzzleCacheKey}_${type}_${difficulty}_$language';
    final jsonList = puzzles.map((p) {
      return {
        'id': p.id,
        'type': p.type,
        'question': p.question,
        'answer': p.answer,
        'options': p.options,
        'difficulty': p.difficulty,
        'language': p.language,
      };
    }).toList();
    await prefs.setString(key, json.encode(jsonList));
  }

  // Get cached puzzles
  Future<List<Puzzle>?> getCachedPuzzles(String type, String difficulty, String language) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_puzzleCacheKey}_${type}_${difficulty}_$language';
    final cached = prefs.getString(key);
    if (cached == null) return null;
    try {
      final List<dynamic> jsonList = json.decode(cached);
      return jsonList.map((p) => Puzzle.fromJson(p)).toList();
    } catch (e) {
      return null;
    }
  }

  // Save progress offline
  Future<void> saveProgress(int puzzleId, int levelNumber, int score, bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    final progressData = prefs.getString(_progressKey);
    List<Map<String, dynamic>> progress = [];
    if (progressData != null) {
      progress = List<Map<String, dynamic>>.from(json.decode(progressData));
    }
    progress.add({
      'puzzle_id': puzzleId,
      'level_number': levelNumber,
      'score': score,
      'completed': completed,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_progressKey, json.encode(progress));
  }

  // Get pending offline progress to sync
  Future<List<Map<String, dynamic>>> getPendingProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressData = prefs.getString(_progressKey);
    if (progressData == null) return [];
    return List<Map<String, dynamic>>.from(json.decode(progressData));
  }

  // Clear synced progress
  Future<void> clearPendingProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }

  // Check if puzzles are cached for a type
  Future<bool> hasCachedPuzzles(String type, String difficulty, String language) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_puzzleCacheKey}_${type}_${difficulty}_$language';
    return prefs.containsKey(key);
  }
}
