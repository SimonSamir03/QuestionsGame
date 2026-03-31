import 'package:brainplay/constants/constants.dart';
import 'package:get/get.dart';

/// GetX translations for English (en) and Arabic (ar).
///
/// Usage:
///   'key'.tr                          — simple string
///   'key'.trParams({'n': '$value'})   — parametric string (replaces @n)
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': _en,
        'ar': _ar,
      };

  // ─── English ────────────────────────────────────────────────────────────────

  static const Map<String, String> _en = {
    // ── App ──
    'app_tagline': kAppTaglineEn,

    // ── Home ──
    'choose_game': 'Choose a Game',
    'game_word': 'Word Builder',
    'game_word_sub': 'Arrange letters to form words',
    'game_quiz': 'Quick Quiz',
    'game_quiz_sub': 'Answer knowledge questions',
    'game_domino': 'Domino Chain',
    'game_domino_sub': 'Find the missing domino tile',
    'game_word_categories': 'Word Categories',
    'game_word_categories_sub': 'Write words starting with a random letter',
    'game_word_search': 'Word Search',
    'game_word_search_sub': 'Find hidden words in the grid',
    'daily_reward': 'Daily Reward',
    'daily_reward_sub': 'Claim your daily reward!',
    'nav_ranks': 'Ranks',
    'nav_shop': 'Shop',
    'nav_challenges': 'Challenges',
    'challenges_title': 'Challenges',
    'no_challenges': 'No active challenges right now',
    'nav_daily': 'Daily',
    'word': 'Word Builder',
    'quiz': 'Quick Quiz',
    'domino': 'Domino Chain',
    'word_categories': 'Word Categories',
    'crossword': 'Crossword',
    'classic_crossword': 'Classic Crossword',
    'block_puzzle': 'Block Puzzle',
    'domino_choose_mode': 'Choose Domino Mode',
    'domino_classic': 'Classic Domino',
    'domino_classic_sub': 'Match tiles and empty your hand first',
    'domino_all_fives': 'All Fives',
    'domino_all_fives_sub': 'Score points when ends sum to multiples of 5',

    // ── Game Language Picker ──
    'choose_play_language': 'Choose Language',
    'choose_play_language_sub': 'Select the language you want to play in',

    // ── Game Screen ──
    'level_label': 'Level @n',

    // ── Level Screen ──
    'new_challenges': 'New Challenges Every Day ♾️',
    'no_puzzles': 'No puzzles available',
    'no_lives_title': 'No Lives Left!',
    'no_lives_body': 'Watch an ad to get a life',
    'btn_later': 'Later',
    'btn_watch_ad': 'Watch Ad',

    // ── Difficulty labels ──
    'diff_easy': 'Easy',
    'diff_medium': 'Medium',
    'diff_hard': 'Hard',
    'diff_expert': 'Expert',

    // ── Result Screen ──
    'result_correct': 'Excellent!',
    'result_wrong': 'Try Again',
    'lives_count': '@n lives',
    'btn_double_coins': 'Double your coins!',
    'btn_watch_continue': 'Watch ad to continue',
    'btn_next_level': 'Next Level',
    'btn_back_home': 'Back to Home',
    'btn_try_again': 'Try Again',
    'btn_home': 'Home',

    // ── Settings ──
    'settings_title': 'Settings',
    'settings_appearance': 'Appearance',
    'settings_dark_mode': 'Dark Mode',
    'settings_audio': 'Audio',
    'settings_sound': 'Sound Effects',
    'settings_music': 'Background Music',
    'settings_language': 'Language',
    'settings_profile': 'Profile',
    'settings_player_name': 'Player Name',
    'settings_phone': 'Phone Number',
    'settings_phone_hint': 'For receiving rewards',
    'settings_save': 'Save',
    'coins': 'Coins',
    'lives': 'Lives',
    'settings_account': 'Account',
    'settings_status': 'Status',
    'settings_premium': 'Premium',
    'settings_free': 'Free',
    'settings_streak': 'Streak',
    'settings_days': '@n days',
    'settings_about': 'About',
    'settings_version': 'Version',
    'settings_developer': 'Developer',

    // ── Shop ──
    'shop_title': 'Shop',
    'shop_premium': 'Premium',
    'shop_coins': 'Coins',
    'shop_100_coins': '100 Coins',
    'shop_500_coins': '500 Coins',
    'shop_1000_coins': '1000 Coins',
    'shop_lives': 'Lives',
    'shop_5_lives': '5 Lives',
    'shop_free_rewards': 'Free Rewards',
    'shop_ad_coins': 'Watch Ad = 5 Coins',
    'shop_ad_life': 'Watch Ad = Extra Life',
    'shop_plus_5_coins': '+5 Coins!',
    'shop_plus_1_life': '+1 Life!',
    'shop_remove_ads': 'Remove All Ads',
    'shop_remove_ads_sub': 'Enjoy ad-free gameplay',
    'shop_upgraded': 'Upgraded!',
    'shop_confirm_title': 'Confirm Purchase',
    'shop_confirm_body': 'Do you want to buy this item?',
    'btn_cancel': 'Cancel',
    'shop_purchase_ok': 'Purchase successful!',
    'btn_buy': 'Buy',

    // ── Leaderboard ──
    'leaderboard_title': 'Leaderboard',
    'tab_daily': 'Daily',
    'tab_weekly': 'Weekly',
    'tab_monthly': 'Monthly',
    'tab_global': 'Global',
    'leaderboard_empty': 'No results yet',

    // ── Daily Reward ──
    'daily_reward_title': 'Daily Rewards',
    'streak_label': 'Day Streak',
    'day_label': 'Day @n',
    'mystery_label': 'Mystery',
    'btn_claim': 'Claim Reward!',
    'btn_restore_streak': 'Watch ad to restore streak',

    // ── Notifications ──
    'notifications_title': 'Notifications',
    'notifications_empty': 'No notifications yet',
    'notifications_mark_all': 'Mark all read',
    'notification_detail': 'Notification',

    // ── Mystery Box ──
    'mystery_box_title': 'Mystery Box',
    'mystery_box_got': 'You got a Mystery Box!',
    'mystery_box_tap': 'Tap to open it',
    'btn_open_box': 'Open Box!',
    'mystery_box_you_got': 'You got:',
    'btn_watch_another': 'Watch Ad for Another Box',
    'btn_continue': 'Continue',

    // ── Crossword Screen ──
    'word_games_title': 'Word Games',
    'classic_crossword_sub': 'Solve words from across & down clues',
    'word_search': 'Word Search',
    'word_search_sub': 'Find hidden words in the grid',
    'words_count': '@n words',

    // ── Word Categories ──
    'word_categories_title': 'Word Categories',
    'round_won': 'You Won! 🎉',
    'round_lost': 'You Lost! 😢',
    'round_won_score': '+@score points',
    'round_lost_score': '@correct/6 correct — all must be correct!',
    'lives_left': '@n lives left',
    'btn_play_again': 'Play Again',
  };

  // ─── Arabic ─────────────────────────────────────────────────────────────────

  static const Map<String, String> _ar = {
    // ── App ──
    'app_tagline': kAppTaglineAr,

    // ── Home ──
    'choose_game': 'اختر لعبة',
    'game_word': 'ترتيب الحروف',
    'game_word_sub': 'رتب الحروف لتكوين كلمات',
    'game_quiz': 'أسئلة سريعة',
    'game_quiz_sub': 'أجب على أسئلة المعرفة',
    'game_domino': 'سلسلة الدومينو',
    'game_domino_sub': 'أوجد قطعة الدومينو المفقودة',
    'game_word_categories': 'تحدي الحروف',
    'game_word_categories_sub': 'اكتب كلمات تبدأ بحرف عشوائي',
    'game_word_search': 'الكلمات المتقاطعة',
    'game_word_search_sub': 'ابحث عن الكلمات المخفية في الشبكة',
    'daily_reward': 'المكافأة اليومية',
    'daily_reward_sub': 'اجمع مكافأتك اليومية!',
    'nav_ranks': 'الترتيب',
    'nav_shop': 'المتجر',
    'nav_challenges': 'التحديات',
    'challenges_title': 'التحديات',
    'no_challenges': 'لا توجد تحديات نشطة حاليا',
    'nav_daily': 'يومي',
    'word': 'ترتيب الحروف',
    'quiz': 'أسئلة سريعة',
    'domino': 'سلسلة الدومينو',
    'word_categories': 'تحدي الحروف',
    'crossword': 'الكلمات المتقاطعة',
    'classic_crossword': 'الكلمات المتقاطعة الكلاسيكية',
    'block_puzzle': 'ألغاز القطع',
    'domino_choose_mode': 'اختر وضع الدومينو',
    'domino_classic': 'دومينو كلاسيك',
    'domino_classic_sub': 'طابق القطع وفرّغ يدك أولاً',
    'domino_all_fives': 'كل الخمسات',
    'domino_all_fives_sub': 'سجّل نقاط عندما يكون مجموع الأطراف من مضاعفات 5',

    // ── Game Language Picker ──
    'choose_play_language': 'اختر اللغة',
    'choose_play_language_sub': 'اختر اللغة التي تريد اللعب بها',

    // ── Game Screen ──
    'level_label': 'مستوى @n',

    // ── Level Screen ──
    'new_challenges': 'تحديات جديدة كل يوم ♾️',
    'no_puzzles': 'لا توجد ألغاز',
    'no_lives_title': 'نفدت الحياة!',
    'no_lives_body': 'شاهد إعلان للحصول على حياة',
    'btn_later': 'لاحقاً',
    'btn_watch_ad': 'شاهد إعلان',

    // ── Difficulty labels ──
    'diff_easy': 'سهل',
    'diff_medium': 'متوسط',
    'diff_hard': 'صعب',
    'diff_expert': 'خبير',

    // ── Result Screen ──
    'result_correct': 'أحسنت!',
    'result_wrong': 'حاول مرة أخرى',
    'lives_count': '@n حياة',
    'btn_double_coins': 'ضاعف عملاتك!',
    'btn_watch_continue': 'شاهد إعلان للاستمرار',
    'btn_next_level': 'المستوى التالي',
    'btn_back_home': 'الرئيسية',
    'btn_try_again': 'حاول مرة أخرى',
    'btn_home': 'الرئيسية',

    // ── Settings ──
    'settings_title': 'الإعدادات',
    'settings_appearance': 'المظهر',
    'settings_dark_mode': 'الوضع الداكن',
    'settings_audio': 'الصوت',
    'settings_sound': 'المؤثرات الصوتية',
    'settings_music': 'الموسيقى',
    'settings_language': 'اللغة',
    'settings_profile': 'الملف الشخصي',
    'settings_player_name': 'اسم اللاعب',
    'settings_phone': 'رقم الهاتف',
    'settings_phone_hint': 'لاستلام المكافآت',
    'settings_save': 'حفظ',
    'coins': 'عملات',
    'lives': 'أرواح',
    'settings_account': 'الحساب',
    'settings_status': 'الحالة',
    'settings_premium': 'بريميوم',
    'settings_free': 'مجاني',
    'settings_streak': 'أيام متتالية',
    'settings_days': '@n يوم',
    'settings_about': 'حول التطبيق',
    'settings_version': 'الإصدار',
    'settings_developer': 'المطور',

    // ── Shop ──
    'shop_title': 'المتجر',
    'shop_premium': 'بريميوم',
    'shop_coins': 'عملات',
    'shop_100_coins': '100 عملة',
    'shop_500_coins': '500 عملة',
    'shop_1000_coins': '1000 عملة',
    'shop_lives': 'حياة',
    'shop_5_lives': '5 حياة',
    'shop_free_rewards': 'مكافآت مجانية',
    'shop_ad_coins': 'شاهد إعلان = 5 عملات',
    'shop_ad_life': 'شاهد إعلان = حياة إضافية',
    'shop_plus_5_coins': '+5 عملات!',
    'shop_plus_1_life': '+1 حياة!',
    'shop_remove_ads': 'إزالة جميع الإعلانات',
    'shop_remove_ads_sub': 'استمتع بلعب بدون إعلانات',
    'shop_upgraded': 'تم الترقية!',
    'shop_confirm_title': 'تأكيد الشراء',
    'shop_confirm_body': 'هل تريد شراء هذا المنتج؟',
    'btn_cancel': 'إلغاء',
    'shop_purchase_ok': 'تم الشراء بنجاح!',
    'btn_buy': 'شراء',

    // ── Leaderboard ──
    'leaderboard_title': 'لوحة المتصدرين',
    'tab_daily': 'يومي',
    'tab_weekly': 'أسبوعي',
    'tab_monthly': 'شهري',
    'tab_global': 'عام',
    'leaderboard_empty': 'لا توجد نتائج بعد',

    // ── Daily Reward ──
    'daily_reward_title': 'المكافأة اليومية',
    'streak_label': 'أيام متتالية',
    'day_label': 'يوم @n',
    'mystery_label': 'غامض',
    'btn_claim': 'اجمع المكافأة!',
    'btn_restore_streak': 'شاهد إعلان لاستعادة السلسلة',

    // ── Notifications ──
    'notifications_title': 'الإشعارات',
    'notifications_empty': 'لا توجد إشعارات بعد',
    'notifications_mark_all': 'قراءة الكل',
    'notification_detail': 'الإشعار',

    // ── Mystery Box ──
    'mystery_box_title': 'صندوق الغموض',
    'mystery_box_got': 'لديك صندوق غموض!',
    'mystery_box_tap': 'اضغط لفتحه',
    'btn_open_box': 'افتح الصندوق!',
    'mystery_box_you_got': 'حصلت على:',
    'btn_watch_another': 'شاهد إعلان لصندوق آخر',
    'btn_continue': 'متابعة',

    // ── Crossword Screen ──
    'word_games_title': 'ألعاب الكلمات',
    'classic_crossword_sub': 'حل الكلمات من الأدلة أفقي ورأسي',
    'word_search': 'البحث عن الكلمات',
    'word_search_sub': 'ابحث عن الكلمات المخفية في الشبكة',
    'words_count': '@n كلمة',

    // ── Word Categories ──
    'word_categories_title': 'تحدي الحروف',
    'round_won': 'فزت! 🎉',
    'round_lost': 'خسرت! 😢',
    'round_won_score': '+@score نقطة',
    'round_lost_score': '@correct/6 صح — لازم كلهم يبقوا صح!',
    'lives_left': '@n حياة متبقية',
    'btn_play_again': 'العب مرة أخرى',
  };
}
