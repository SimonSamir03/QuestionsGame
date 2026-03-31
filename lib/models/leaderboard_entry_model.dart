class LeaderboardEntryModel {
  final int     userId;
  final String  name;
  final String? avatarUrl;
  final int     score;
  final int     coins;
  final int     lives;

  const LeaderboardEntryModel({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.score,
    this.coins = 0,
    this.lives = 0,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> j) =>
      LeaderboardEntryModel(
        userId    : (j['user_id'] as num).toInt(),
        name      : j['name']       as String? ?? 'Player',
        avatarUrl : j['avatar_url'] as String?,
        score     : int.tryParse('${j['score']}') ?? 0,
        coins     : int.tryParse('${j['coins'] ?? 0}') ?? 0,
        lives     : int.tryParse('${j['lives'] ?? 0}') ?? 0,
      );
}
