class Answer {
  final int id;
  final int questionId;
  final String answerText;
  final bool isCorrect;
  final int sortOrder;

  const Answer({
    required this.id,
    required this.questionId,
    required this.answerText,
    this.isCorrect = false,
    this.sortOrder = 0,
  });

  factory Answer.fromJson(Map<String, dynamic> j) => Answer(
        id: j['id'] as int,
        questionId: j['question_id'] as int,
        answerText: j['answer_text'] as String,
        isCorrect: j['is_correct'] == 1 || j['is_correct'] == true,
        sortOrder: j['sort_order'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'question_id': questionId,
        'answer_text': answerText,
        'is_correct': isCorrect ? 1 : 0,
        'sort_order': sortOrder,
      };
}
