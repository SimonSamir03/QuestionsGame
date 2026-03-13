import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/puzzle_model.dart';

class ApiService {
  // Auto-detect: localhost for web, 10.0.2.2 for Android emulator
  static String get baseUrl => kIsWeb
      ? 'http://localhost:8000/api'
      : 'http://10.0.2.2:8000/api';
  static String? _authToken;

  static void setAuthToken(String token) => _authToken = token;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  static const Duration _timeout = Duration(seconds: 3);

  // ============ PUZZLES ============
  static Future<List<Puzzle>?> getPuzzles(String type, String difficulty, String language, {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/puzzles?type=$type&difficulty=$difficulty&language=$language&page=$page'),
        headers: _headers,
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List).map((p) => Puzzle.fromJson(p)).toList();
      }
    } catch (e) {
      print('API Error: $e');
    }
    return null;
  }

  static Future<Puzzle?> getDailyChallenge() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/daily-challenge'), headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Puzzle.fromJson(data['puzzle']);
      }
    } catch (e) {
      print('API Error: $e');
    }
    return null;
  }

  // ============ AUTH ============
  static Future<Map<String, dynamic>?> register(String name, String email, String password, String language) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: json.encode({'name': name, 'email': email, 'password': password, 'language': language}),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _authToken = data['token'];
        return data;
      }
    } catch (e) {
      print('Register Error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _authToken = data['token'];
        return data;
      }
    } catch (e) {
      print('Login Error: $e');
    }
    return null;
  }

  // ============ GAME ============
  static Future<Map<String, dynamic>?> submitAnswer(int puzzleId, String answer, int levelNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit-answer'),
        headers: _headers,
        body: json.encode({'puzzle_id': puzzleId, 'answer': answer, 'level_number': levelNumber}),
      );
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Submit Error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> rewardAd(String rewardType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reward-ad'),
        headers: _headers,
        body: json.encode({'reward_type': rewardType}),
      );
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Reward Error: $e');
    }
    return null;
  }

  // ============ WORD CATEGORIES ============
  static Future<Map<String, dynamic>?> getRandomLetter(String language) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/word-categories/letter?language=$language'),
        headers: _headers,
      ).timeout(_timeout);
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Letter Error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> submitWordCategoryRound(String letter, String language, Map<String, String> answers) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/word-categories/submit'),
        headers: _headers,
        body: json.encode({'letter': letter, 'language': language, 'answers': answers}),
      );
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Word Category Error: $e');
    }
    return null;
  }

  // ============ DAILY REWARDS ============
  static Future<Map<String, dynamic>?> getDailyRewardStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/daily-reward/status'), headers: _headers);
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Daily Reward Error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> claimDailyReward() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/daily-reward/claim'), headers: _headers);
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Claim Error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> restoreStreak() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/daily-reward/restore-streak'), headers: _headers);
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Restore Error: $e');
    }
    return null;
  }

  // ============ LEADERBOARD ============
  static Future<Map<String, dynamic>?> getLeaderboard({String period = 'global', int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard?period=$period&limit=$limit'),
        headers: _headers,
      );
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Leaderboard Error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getMyRank({String period = 'global'}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/leaderboard/my-rank?period=$period'), headers: _headers);
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Rank Error: $e');
    }
    return null;
  }

  // ============ PURCHASES ============
  static Future<Map<String, dynamic>?> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'), headers: _headers);
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Products Error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> recordPurchase(String productId, String store, String transactionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/purchase'),
        headers: _headers,
        body: json.encode({'product_id': productId, 'store': store, 'transaction_id': transactionId}),
      );
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Purchase Error: $e');
    }
    return null;
  }

  // ============ CHALLENGES ============
  static Future<Map<String, dynamic>?> createChallenge(int opponentId, String gameType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/challenges'),
        headers: _headers,
        body: json.encode({'opponent_id': opponentId, 'game_type': gameType}),
      );
      if (response.statusCode == 201) return json.decode(response.body);
    } catch (e) {
      print('Challenge Error: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> getMyChallenges() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/challenges/mine'), headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['challenges'];
      }
    } catch (e) {
      print('Challenges Error: $e');
    }
    return null;
  }
}
