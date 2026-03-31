class DailyRewardStatusModel {
  final bool   canClaim;
  final bool   streakBroken;
  final int    currentStreak;
  final int    dayNumber;         // 1–7
  final String todayRewardType;  // coins | mystery
  final int    todayRewardAmount;
  final int    lastRewardAmount;
  final List<Map<String, dynamic>>? schedule; // optional server-side schedule

  const DailyRewardStatusModel({
    required this.canClaim,
    required this.streakBroken,
    required this.currentStreak,
    required this.dayNumber,
    required this.todayRewardType,
    required this.todayRewardAmount,
    required this.lastRewardAmount,
    this.schedule,
  });

  factory DailyRewardStatusModel.fromJson(Map<String, dynamic> j) =>
      DailyRewardStatusModel(
        canClaim          : j['can_claim']             as bool?  ?? false,
        streakBroken      : j['streak_broken']         as bool?  ?? false,
        currentStreak     : (j['current_streak']       as num?)?.toInt() ?? 0,
        dayNumber         : (j['day_number']           as num?)?.toInt() ?? 1,
        todayRewardType   : j['today_reward_type']     as String? ?? 'coins',
        todayRewardAmount : (j['today_reward_amount']  as num?)?.toInt() ?? 0,
        lastRewardAmount  : (j['last_reward_amount']   as num?)?.toInt() ?? 0,
        schedule          : (j['schedule'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );
}
