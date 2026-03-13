class Puzzle {
  final int id;
  final String type;
  final String question;
  final String answer;
  final List<String>? options;
  final String difficulty;
  final String language;

  Puzzle({
    required this.id,
    required this.type,
    required this.question,
    required this.answer,
    this.options,
    required this.difficulty,
    required this.language,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      difficulty: json['difficulty'] ?? 'easy',
      language: json['language'] ?? 'en',
    );
  }
}
