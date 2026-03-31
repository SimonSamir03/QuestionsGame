class UserModel {
  final int     id;
  final String  displayName;
  final String  phoneNumber;
  final String  language;
  final int     coins;
  final int     lives;
  final bool    isPremium;
  final int     streakDays;
  final String? lastStreakDate;
  final String? avatarUrl;
  final bool    soundEnabled;
  final bool    musicEnabled;
  final bool    isDarkMode;

  const UserModel({
    required this.id,
    required this.displayName,
    this.phoneNumber = '',
    required this.language,
    required this.coins,
    required this.lives,
    required this.isPremium,
    required this.streakDays,
    this.lastStreakDate,
    this.avatarUrl,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.isDarkMode,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id             : j['id']               as int,
    displayName    : j['display_name']     as String? ?? 'Player',
    phoneNumber    : j['phone_number']     as String? ?? '',
    language       : j['language']         as String? ?? 'en',
    coins          : (j['coins']           as num?)?.toInt() ?? 0,
    lives          : (j['lives']           as num?)?.toInt() ?? 5,
    isPremium      : j['is_premium']       as bool?   ?? false,
    streakDays     : (j['streak_days']     as num?)?.toInt() ?? 0,
    lastStreakDate : j['last_streak_date'] as String?,
    avatarUrl      : j['avatar_url']       as String?,
    soundEnabled   : j['sound_enabled']    as bool?   ?? true,
    musicEnabled   : j['music_enabled']    as bool?   ?? true,
    isDarkMode     : j['is_dark_mode']     as bool?   ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id'               : id,
    'display_name'     : displayName,
    'phone_number'     : phoneNumber,
    'language'         : language,
    'coins'            : coins,
    'lives'            : lives,
    'is_premium'       : isPremium,
    'streak_days'      : streakDays,
    'last_streak_date' : lastStreakDate,
    'avatar_url'       : avatarUrl,
    'sound_enabled'    : soundEnabled,
    'music_enabled'    : musicEnabled,
    'is_dark_mode'     : isDarkMode,
  };
}
