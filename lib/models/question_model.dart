import 'answer_model.dart';

class Question {
  final int id;
  final int gameId;
  final String question;
  final String answer;
  final String difficulty;
  final String language;
  final Map<String, dynamic>? metadata;
  final bool isActive;
  final DateTime? createdAt;
  final List<Answer>? answers;

  const Question({
    required this.id,
    required this.gameId,
    required this.question,
    required this.answer,
    this.difficulty = 'easy',
    this.language = 'en',
    this.metadata,
    this.isActive = true,
    this.createdAt,
    this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> j) {
    List<Answer>? answers;
    if (j['answers'] is List) {
      answers = (j['answers'] as List)
          .map((a) => Answer.fromJson(Map<String, dynamic>.from(a as Map)))
          .toList();
    }

    return Question(
      id: j['id'] as int,
      gameId: j['game_id'] as int,
      question: j['question'] as String,
      answer: j['answer'] as String,
      difficulty: j['difficulty'] as String? ?? 'easy',
      language: j['language'] as String? ?? 'en',
      metadata: j['metadata'] is Map
          ? Map<String, dynamic>.from(j['metadata'] as Map)
          : null,
      isActive: j['is_active'] == 1 || j['is_active'] == true,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'] as String)
          : null,
      answers: answers,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'game_id': gameId,
        'question': question,
        'answer': answer,
        'difficulty': difficulty,
        'language': language,
        if (metadata != null) 'metadata': metadata,
        'is_active': isActive ? 1 : 0,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (answers != null)
          'answers': answers!.map((a) => a.toJson()).toList(),
      };
}
