import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/question_model.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://code-tech.shop/api/brainplay',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final storage = StorageService();
        if (storage.authToken != null) {
          options.headers['Authorization'] = 'Bearer ${storage.authToken}';
        }
        final lang = storage.language;
        options.headers['Accept-Language'] = lang;
        return handler.next(options);
      },
      onError: (error, handler) {
        // Auto logout on 401
        if (error.response?.statusCode == 401) {
          StorageService().authToken = null;
        }
        return handler.next(error);
      },
    ));
  }

  // ─── Generic Methods ───
  Future<Response?> _get(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      _log('GET $path', e);
      return null;
    }
  }

  Future<Response?> _post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      _log('POST $path', e);
      return null;
    }
  }


  void _log(String label, DioException e) {
    if (kDebugMode) {
      print('API Error [$label]: ${e.message}');
      print('  → type   : ${e.type}');
      print('  → status : ${e.response?.statusCode}');
      print('  → body   : ${e.response?.data}');
    }
  }

  // ─── CONFIG ───
  Future<Map<String, dynamic>?> getConfig() async {
    final res = await _get('/config');
    if (res?.statusCode == 200 && res?.data is Map) {
      return Map<String, dynamic>.from(res!.data);
    }
    return null;
  }

  // ─── AUTH ───

  /// Called on every app launch. Creates or re-authenticates the device.
  /// Returns { is_new_user, token, user } or null on failure.
  Future<Map<String, dynamic>?> deviceAuth({
    required String deviceId,
    required String platform,
    String? model,
    String? deviceName,
    String? osVersion,
    String? appVersion,
    String? fcmToken,
  }) async {
    final res = await _post('/auth/device', data: {
      'device_id'   : deviceId,
      'platform'    : platform,
      if (model      != null) 'model'       : model,
      if (deviceName != null) 'device_name' : deviceName,
      if (osVersion  != null) 'os_version'  : osVersion,
      if (appVersion != null) 'app_version' : appVersion,
      if (fcmToken   != null) 'fcm_token'   : fcmToken,
    });
    if (res != null && (res.statusCode == 200 || res.statusCode == 201)) {
      StorageService().authToken = res.data['token'] as String;
      return Map<String, dynamic>.from(res.data);
    }
    return null;
  }

  Future<Map<String, dynamic>?> syncCoinsAndLives(int coins, int lives) async {
    final res = await _post('/user/update', data: {'coins': coins, 'lives': lives});
    if (kDebugMode) print('BALANCE: coins=$coins lives=$lives status=${res?.statusCode} body=${res?.data}');
    if (res?.statusCode == 200) return Map<String, dynamic>.from(res!.data);
    return null;
  }

  Future<Map<String, dynamic>?> updateProfile({required String displayName, required String phoneNumber}) async {
    final res = await _post('/user/update', data: {
      'display_name': displayName,
      'phone_number': phoneNumber,
    });
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<void> syncSettings({required bool soundEnabled, required bool musicEnabled, required bool isDarkMode}) async {
    await _post('/user/update', data: {
      'sound_enabled': soundEnabled,
      'music_enabled': musicEnabled,
      'is_dark_mode': isDarkMode,
    });
  }

  Future<void> syncLanguage(String language) async {
    await _post('/user/update', data: {'language': language});
  }

  Future<void> syncFcmToken(String token) async {
    final res = await _post('/user/fcm-token', data: {'fcm_token': token});
    if (kDebugMode) print('FCM SYNC: status=${res?.statusCode} body=${res?.data}');
  }

  Future<void> logout() async {
    await _post('/auth/logout');
    StorageService().authToken = null;
  }

  // ─── HEARTBEAT ───
  Future<void> ping() async {
    await _post('/ping');
  }

  // ─── GAMES ───
  Future<List<dynamic>?> getGames() async {
    final res = await _get('/games');
    return res?.data['data'];
  }

  // ─── QUESTIONS ───
  Future<List<Question>?> getQuizQuestions(int gameId, String difficulty, String language, {int page = 1}) async {
    final res = await _get('/questions', query: {
      'game_id': gameId, 'difficulty': difficulty, 'language': language, 'page': page,
    });
    if (res?.statusCode == 200) {
      return (res!.data['data'] as List).map((j) {
        final m = Map<String, dynamic>.from(j as Map);
        // API returns 'options' — convert to 'answers' format for Question model
        if (m['options'] is List && m['answers'] == null) {
          m['answers'] = (m['options'] as List).map((o) {
            final opt = Map<String, dynamic>.from(o as Map);
            return {
              'id': opt['id'] ?? 0,
              'question_id': m['id'],
              'answer_text': opt['text'],
              'is_correct': opt['is_correct'] ?? false,
              'sort_order': 0,
            };
          }).toList();
        }
        m['game_id'] ??= 0;
        return Question.fromJson(m);
      }).toList();
    }
    return null;
  }

  Future<List<Question>?> getWordQuestions(int gameId, String difficulty, String language, {int page = 1}) async {
    final res = await _get('/questions', query: {
      'game_id': gameId, 'difficulty': difficulty, 'language': language, 'page': page,
    });
    if (res?.statusCode == 200) {
      return (res!.data['data'] as List).map((j) {
        final m = Map<String, dynamic>.from(j as Map);
        m['game_id'] ??= 0;
        return Question.fromJson(m);
      }).toList();
    }
    return null;
  }

  // ─── CROSSWORD DATA ───
  Future<List<Map<String, dynamic>>?> getCrosswordCategories(int gameId, String language) async {
    final res = await _get('/questions', query: {'game_id': gameId, 'language': language});
    if (res?.statusCode == 200) {
      return (res!.data['data'] as List)
          .map((j) => Map<String, dynamic>.from(j as Map))
          .toList();
    }
    return null;
  }

  // ─── GAME ACTIONS ───
  Future<Map<String, dynamic>?> submitAnswer(int puzzleId, String answer, int levelNumber) async {
    final res = await _post('/submit-answer', data: {
      'question_id': puzzleId, 'answer': answer, 'level_number': levelNumber,
    });
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<Map<String, dynamic>?> rewardAd(String rewardType) async {
    final res = await _post('/reward-ad', data: {'reward_type': rewardType});
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  // ─── WORD CATEGORIES ───
  Future<Map<String, dynamic>?> getRandomLetter(String language) async {
    final res = await _get('/word-categories/letter', query: {'language': language});
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<Map<String, dynamic>?> submitWordCategoryRound(String letter, String language, Map<String, String> answers) async {
    final res = await _post('/word-categories/submit', data: {
      'letter': letter, 'language': language, 'answers': answers,
    });
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  // ─── DAILY REWARDS ───
  Future<Map<String, dynamic>?> getDailyRewardStatus() async {
    final res = await _get('/daily-reward/status');
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<Map<String, dynamic>?> claimDailyReward() async {
    final res = await _post('/daily-reward/claim');
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<Map<String, dynamic>?> restoreStreak() async {
    final res = await _post('/daily-reward/restore-streak');
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  // ─── LEADERBOARD ───
  Future<Map<String, dynamic>?> getLeaderboard({String period = 'global', int limit = 50, int? gameId}) async {
    final res = await _get('/leaderboard', query: {
      'period': period,
      'limit': limit,
      if (gameId != null) 'game_id': gameId,
    });
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<Map<String, dynamic>?> getMyRank({String period = 'global'}) async {
    final res = await _get('/leaderboard/my-rank', query: {'period': period});
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  // ─── SCORES ───
  Future<Map<String, dynamic>?> submitScore(int gameId, int score, {int? timeTaken}) async {
    final res = await _post('/scores', data: {
      'game_id': gameId, 'score': score, if (timeTaken != null) 'time_taken': timeTaken,
    });
    return res?.statusCode == 201 ? Map<String, dynamic>.from(res!.data) : null;
  }

  // ─── USER PROGRESS ───
  Future<Map<String, dynamic>?> getUserProgress() async {
    final res = await _get('/user/progress');
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<Map<String, dynamic>?> updateUserProgress(int gameId, int level, String difficulty, int score) async {
    final res = await _post('/user/progress', data: {
      'game_id': gameId, 'level': level, 'difficulty': difficulty, 'score': score,
    });
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  // ─── PURCHASES ───
  Future<Map<String, dynamic>?> getProducts() async {
    final res = await _get('/products');
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<Map<String, dynamic>?> recordPurchase(String productId, String store, String transactionId) async {
    final res = await _post('/purchase', data: {
      'product_id': productId, 'store': store, 'transaction_id': transactionId,
    });
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  // ─── CHALLENGES ───
  Future<Map<String, dynamic>?> createChallenge(int opponentId, String gameType) async {
    final res = await _post('/challenges', data: {
      'opponent_id': opponentId, 'game_type': gameType,
    });
    return res?.statusCode == 201 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<List<dynamic>?> getMyChallenges() async {
    final res = await _get('/challenges/mine');
    return res?.statusCode == 200 ? res!.data['challenges'] : null;
  }

  Future<Map<String, dynamic>?> updateChallengeProgress(int challengeId, int progress) async {
    final res = await _post('/challenges/$challengeId/progress', data: {
      'progress': progress,
    });
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  // ─── NOTIFICATIONS ───
  Future<List<dynamic>?> getNotifications({int page = 1}) async {
    final res = await _get('/notifications', query: {'page': page});
    return res?.statusCode == 200 ? res!.data['notifications'] : null;
  }

  // ─── WALLET ───
  Future<Map<String, dynamic>?> getWallet() async {
    final res = await _get('/wallet');
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<Map<String, dynamic>?> getWithdrawalHistory({int page = 1}) async {
    final res = await _get('/wallet/history', query: {'page': page});
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<Map<String, dynamic>?> requestWithdrawal({
    required int coinsAmount,
    required String paymentMethod,
    required String paymentDetails,
  }) async {
    final res = await _post('/wallet/withdraw', data: {
      'coins_amount': coinsAmount,
      'payment_method': paymentMethod,
      'payment_details': paymentDetails,
    });
    if (res?.statusCode == 201) return Map<String, dynamic>.from(res!.data);
    if (res?.data is Map) return Map<String, dynamic>.from(res!.data);
    return null;
  }

  Future<Map<String, dynamic>?> logAdWatch({required String rewardType, required int coinsEarned}) async {
    final res = await _post('/wallet/log-ad', data: {
      'reward_type': rewardType,
      'coins_earned': coinsEarned,
    });
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<Map<String, dynamic>?> addXp({required int amount, required String source}) async {
    final res = await _post('/wallet/add-xp', data: {
      'amount': amount,
      'source': source,
    });
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }

  Future<Map<String, dynamic>?> syncBalance({required int coins, required int xp, required int lives}) async {
    final res = await _post('/user/update', data: {
      'coins': coins,
      'xp': xp,
      'lives': lives,
    });
    return res?.statusCode == 200 ? Map<String, dynamic>.from(res!.data) : null;
  }
}
