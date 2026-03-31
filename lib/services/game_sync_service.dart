import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import '../controllers/challenge_controller.dart';
import 'api_service.dart';

/// Centralized service for syncing game results to the backend.
/// All calls are fire-and-forget — failures are silently ignored
/// so the user experience is never blocked by network issues.
class GameSyncService {
  static final GameSyncService _instance = GameSyncService._();
  factory GameSyncService() => _instance;
  GameSyncService._();

  final _api = ApiService();

  /// Submit answer for quiz/word games (updates progress + awards coins server-side)
  void submitAnswer({required int questionId, required String answer, required int levelNumber}) {
    _fire(() => _api.submitAnswer(questionId, answer, levelNumber));
  }

  /// Save score to leaderboard + track 'score' challenges
  void submitScore({required int gameId, required int score, int? timeTaken}) {
    _fire(() => _api.submitScore(gameId, score, timeTaken: timeTaken));
    _trackChallenge(goalType: 'score', amount: score);
  }

  /// Save level progress + track 'levels' challenges
  void saveProgress({required int gameId, required int level, required String difficulty, required int score}) {
    _fire(() => _api.updateUserProgress(gameId, level, difficulty, score));
    _trackChallenge(goalType: 'levels', amount: 1);
  }

  /// Sync coins, xp, and lives to backend
  void syncCoinsAndLives(int coins, int lives) {
    _fire(() async {
      final result = await _api.syncCoinsAndLives(coins, lives);
      if (kDebugMode && result != null) {
        if (kDebugMode) {
          print('SYNC: server coins=${result['coins']} lives=${result['lives']}');
        }
      }
      return result;
    });
  }

  /// Track streak for challenges
  void trackStreak(int streakDays) {
    _trackChallenge(goalType: 'streak', amount: streakDays);
  }

  /// Update challenges that match the goal type
  void _trackChallenge({required String goalType, required int amount}) {
    try {
      if (!Get.isRegistered<ChallengeController>()) return;
      final ctrl = Get.find<ChallengeController>();
      ctrl.trackProgress(goalType: goalType, amount: amount);
    } catch (_) {}
  }

  /// Fire-and-forget wrapper — never throws, never blocks UI
  void _fire(Future<dynamic> Function() fn) {
    fn().then((result) {
      if (kDebugMode) print('SYNC: success → $result');
    }).catchError((e) {
      if (kDebugMode) print('SYNC: error → $e');
    });
  }
}
