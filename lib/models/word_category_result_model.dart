class CategoryResult {
  final String answer;
  final bool   isValid;

  const CategoryResult({required this.answer, required this.isValid});

  factory CategoryResult.fromJson(Map<String, dynamic> j) => CategoryResult(
    answer  : j['answer']   as String? ?? '',
    isValid : j['is_valid'] as bool?   ?? false,
  );
}

class WordCategoryResultModel {
  final String  letter;
  final int     correctCount;
  final int     total;
  final int     score;
  final bool    won;
  final int     coinsEarned;
  final Map<String, CategoryResult> results;

  const WordCategoryResultModel({
    required this.letter,
    required this.correctCount,
    required this.total,
    required this.score,
    required this.won,
    required this.coinsEarned,
    required this.results,
  });

  factory WordCategoryResultModel.fromJson(Map<String, dynamic> j) =>
      WordCategoryResultModel(
        letter       : j['letter']        as String? ?? '',
        correctCount : (j['correct_count'] as num?)?.toInt() ?? 0,
        total        : (j['total']         as num?)?.toInt() ?? 0,
        score        : (j['score']         as num?)?.toInt() ?? 0,
        won          : j['won']            as bool?   ?? false,
        coinsEarned  : (j['coins_earned']  as num?)?.toInt() ?? 0,
        results      : (j['results'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, CategoryResult.fromJson(Map<String, dynamic>.from(v as Map))),
        ) ?? {},
      );
}
