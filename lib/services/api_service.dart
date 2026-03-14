import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import '../models/puzzle_model.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = StorageService().authToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
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

  Future<Response?> _put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      _log('PUT $path', e);
      return null;
    }
  }

  Future<Response?> _delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      _log('DELETE $path', e);
      return null;
    }
  }

  void _log(String label, DioException e) {
    if (kDebugMode) {
      print('API Error [$label]: ${e.message}');
    }
  }

  // ─── AUTH ───
  Future<Map<String, dynamic>?> register(String name, String email, String password, String language) async {
    final res = await _post('/register', data: {
      'name': name, 'email': email, 'password': password, 'language': language,
    });
    if (res?.statusCode == 201) {
      StorageService().authToken = res!.data['token'];
      return Map<String, dynamic>.from(res.data);
    }
    return null;
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final res = await _post('/login', data: {'email': email, 'password': password});
    if (res?.statusCode == 200) {
      StorageService().authToken = res!.data['token'];
      return Map<String, dynamic>.from(res.data);
    }
    return null;
  }

  Future<void> logout() async {
    await _post('/logout');
    StorageService().authToken = null;
  }

  // ─── GAMES ───
  Future<List<dynamic>?> getGames() async {
    final res = await _get('/games');
    return res?.data['data'];
  }

  // ─── PUZZLES ───
  Future<List<Puzzle>?> getPuzzles(String type, String difficulty, String language, {int page = 1}) async {
    final res = await _get('/puzzles', query: {
      'type': type, 'difficulty': difficulty, 'language': language, 'page': page,
    });
    if (res?.statusCode == 200) {
      return (res!.data['data'] as List).map((p) => Puzzle.fromJson(p)).toList();
    }
    return null;
  }

  Future<Puzzle?> getDailyChallenge() async {
    final res = await _get('/daily-challenge');
    if (res?.statusCode == 200) return Puzzle.fromJson(res!.data['puzzle']);
    return null;
  }

  // ─── GAME ACTIONS ───
  Future<Map<String, dynamic>?> submitAnswer(int puzzleId, String answer, int levelNumber) async {
    final res = await _post('/submit-answer', data: {
      'puzzle_id': puzzleId, 'answer': answer, 'level_number': levelNumber,
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
  Future<Map<String, dynamic>?> getLeaderboard({String period = 'global', int limit = 50}) async {
    final res = await _get('/leaderboard', query: {'period': period, 'limit': limit});
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
}
