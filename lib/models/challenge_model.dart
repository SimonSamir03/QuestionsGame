class ChallengeModel {
  final int     id;
  final String  type;        // daily | weekly | special
  final String  goalType;    // score | levels | streak
  final int     goalValue;
  final int     rewardCoins;
  final int     rewardLives;
  final String  difficulty;
  final String  endsAt;
  final String  title;
  final String? description;
  final int     progress;
  final bool    isCompleted;

  const ChallengeModel({
    required this.id,
    required this.type,
    required this.goalType,
    required this.goalValue,
    required this.rewardCoins,
    required this.rewardLives,
    required this.difficulty,
    required this.endsAt,
    required this.title,
    this.description,
    required this.progress,
    required this.isCompleted,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> j) => ChallengeModel(
    id           : j['id']            as int,
    type         : j['type']          as String? ?? 'daily',
    goalType     : j['goal_type']     as String? ?? 'score',
    goalValue    : (j['goal_value']   as num?)?.toInt()   ?? 0,
    rewardCoins  : (j['reward_coins'] as num?)?.toInt()   ?? 0,
    rewardLives  : (j['reward_lives'] as num?)?.toInt()   ?? 0,
    difficulty   : j['difficulty']    as String? ?? 'easy',
    endsAt       : j['ends_at']       as String? ?? '',
    title        : j['title']         as String? ?? '',
    description  : j['description']   as String?,
    progress     : (j['progress']     as num?)?.toInt()   ?? 0,
    isCompleted  : j['is_completed']  as bool?   ?? false,
  );

  double get progressPercent =>
      goalValue > 0 ? (progress / goalValue).clamp(0.0, 1.0) : 0;
}
