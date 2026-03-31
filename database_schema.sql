-- ═══════════════════════════════════════════════════════════════
-- BrainPlay — MySQL Database Schema
-- Auth    : device-based (no email / password)
-- i18n    : translation-table pattern (one row per locale)
-- Engine  : InnoDB | Charset : utf8mb4_unicode_ci
-- ═══════════════════════════════════════════════════════════════
--
-- AUTH FLOW
-- ─────────
-- 1. App generates a UUID on first launch → saved in GetStorage.
-- 2. Every launch → POST /api/auth/device
--    { device_id, platform, model, os_version, app_version }
-- 3. Laravel:
--    • device not found → INSERT user + device → return user + token
--    • device found     → UPDATE last_seen     → return user + token
-- 4. App saves token; every request sends  Authorization: Bearer <token>
--
-- i18n PATTERN
-- ────────────
-- Catalogue tables (games, shop_items, challenges) store only
-- language-agnostic fields.  All translatable text lives in a
-- companion *_translations table with a `locale` column ('en','ar',…).
-- Adding a new language = INSERT new rows, zero schema change.
--
-- Exception: brainplay_questions / brainplay_answers already have a
-- `language` column because puzzle content is inherently language-
-- specific (an Arabic word puzzle cannot be "translated" to English).
-- ═══════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS brainplay
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE brainplay;

-- ─────────────────────────────────────────────────────────────────
-- 1. USERS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_users (
    id                BIGINT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
    display_name      VARCHAR(100)     NOT NULL DEFAULT 'Player',
    phone_number      VARCHAR(20)      NULL,
    language          ENUM('en','ar')  DEFAULT 'en',
    coins             INT UNSIGNED     DEFAULT 0    COMMENT 'gems — the real-money currency (earned from ads)',
    xp                INT UNSIGNED     DEFAULT 0    COMMENT 'experience points (earned from gameplay)',
    lives             INT UNSIGNED     DEFAULT 5,
    max_lives         INT UNSIGNED     DEFAULT 5,
    last_life_at      TIMESTAMP        NULL         COMMENT 'last time a life was recovered',
    is_premium        TINYINT(1)       DEFAULT 0,
    streak_days       INT UNSIGNED     DEFAULT 0,
    last_streak_date  DATE             NULL,
    avatar_url        VARCHAR(500)     NULL,
    sound_enabled     TINYINT(1)       DEFAULT 1,
    music_enabled     TINYINT(1)       DEFAULT 1,
    is_dark_mode      TINYINT(1)       DEFAULT 1,
    created_at        TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_streak (streak_days DESC),
    INDEX idx_xp     (xp DESC)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 2. DEVICES
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_devices (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id      BIGINT UNSIGNED NOT NULL,
    device_id    VARCHAR(100)    NOT NULL UNIQUE COMMENT 'UUID generated on client',
    platform     ENUM('android','ios','web') NOT NULL,
    model        VARCHAR(150)    NULL  COMMENT 'e.g. Samsung Galaxy A54',
    device_name  VARCHAR(150)    NULL  COMMENT 'e.g. Simon''s Phone',
    os_version   VARCHAR(50)     NULL  COMMENT 'e.g. Android 14',
    app_version  VARCHAR(20)     NULL  COMMENT 'e.g. 1.0.3',
    fcm_token    VARCHAR(500)    NULL  COMMENT 'Firebase Cloud Messaging token',
    first_seen   TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    last_seen    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES brainplay_users(id) ON DELETE CASCADE,
    INDEX idx_device_id    (device_id),
    INDEX idx_user_devices (user_id)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 3. AUTH TOKENS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_auth_tokens (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL,
    device_id   BIGINT UNSIGNED NOT NULL,
    token       VARCHAR(500)    NOT NULL UNIQUE,
    expires_at  TIMESTAMP       NULL COMMENT 'NULL = never expires',
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)  REFERENCES brainplay_users(id)   ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES brainplay_devices(id) ON DELETE CASCADE,
    INDEX idx_token      (token),
    INDEX idx_user_token (user_id)
) ENGINE=InnoDB;

-- ═══════════════════════════════════════════════════════════════
-- GAMES CATALOGUE  (base + translations)
-- ═══════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────
-- 4a. GAMES  (language-agnostic fields only)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_games (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    slug        VARCHAR(50)  NOT NULL UNIQUE,
    emoji       VARCHAR(10)  NULL,
    is_active   TINYINT(1)   DEFAULT 1,
    sort_order  INT          DEFAULT 0,
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO brainplay_games (slug, emoji, sort_order) VALUES
('word_rearrange',    '🔤', 1),
('quiz',             '❓', 2),
('word_categories',  '🅰️', 4),
('crossword',        '🔍', 5),
('classic_crossword','✏️', 6),
('block_puzzle',     '🟦', 7),
('domino',           '🁡', 8),
('merge',            '🔀', 9),
('ludo',             '🎲', 10),
('snakes_ladders',   '🐍', 11);

-- ─────────────────────────────────────────────────────────────────
-- 4b. GAME TRANSLATIONS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_game_translations (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    game_id      BIGINT UNSIGNED NOT NULL,
    locale       VARCHAR(5)      NOT NULL COMMENT 'e.g. en, ar, fr',
    name         VARCHAR(100)    NOT NULL,
    description  TEXT            NULL,
    FOREIGN KEY (game_id) REFERENCES brainplay_games(id) ON DELETE CASCADE,
    UNIQUE KEY uq_game_locale (game_id, locale)
) ENGINE=InnoDB;

INSERT INTO brainplay_game_translations (game_id, locale, name, description) VALUES
-- English
(1, 'en', 'Word Rearrange',      'Arrange letters to form words'),
(2, 'en', 'Quick Quiz',        'Answer knowledge questions'),
(4, 'en', 'Word Categories',   'Write words starting with a random letter'),
(5, 'en', 'Crossword',       'Find hidden words in the grid'),
(6, 'en', 'Classic Crossword', 'Solve the crossword puzzle'),
(7, 'en', 'Block Puzzle',      'Fill the grid with blocks'),
(8, 'en', 'Domino Chain',      'Find the missing domino tile'),
(9, 'en', 'Merge Craft',      'Merge items to fulfill orders'),
(10, 'en', 'Ludo',             'Classic board game for 2-4 players'),
(11, 'en', 'Snakes & Ladders', 'Race to 100 — watch out for snakes!'),
-- Arabic
(1, 'ar', 'ترتيب الحروف',      'رتب الحروف لتكوين كلمات'),
(2, 'ar', 'أسئلة سريعة',       'أجب على أسئلة المعرفة'),
(3, 'ar', 'تحدي الحروف',        'اكتب كلمات تبدأ بحرف عشوائي'),
(4, 'ar', 'البحث عن الكلمات',   'ابحث عن الكلمات المخفية في الشبكة'),
(5, 'ar', 'الكلمات المتقاطعة',  'احل الكلمات المتقاطعة'),
(6, 'ar', 'ألغاز المكعبات',     'اسحب المكعبات لملء الصفوف والأعمدة'),
(8, 'ar', 'سلسلة الدومينو',     'أوجد قطعة الدومينو المفقودة'),
(9, 'ar', 'دمج وصنع',          'ادمج العناصر لتنفيذ الطلبات'),
(10, 'ar', 'لودو',              'لعبة لوحية كلاسيكية لـ 2-4 لاعبين'),
(11, 'ar', 'سلم وثعبان',       'سابق إلى 100 — احذر من الثعابين!');

-- ─────────────────────────────────────────────────────────────────
-- 5. QUESTIONS / PUZZLES
-- (language column kept — puzzle content is language-specific, not translatable)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_questions (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    game_id     BIGINT UNSIGNED NOT NULL,
    question    TEXT            NOT NULL,
    answer      VARCHAR(255)    NOT NULL,
    difficulty  ENUM('easy','medium','hard','expert') DEFAULT 'easy',
    language    ENUM('en','ar') DEFAULT 'en',
    metadata    JSON            NULL,
    is_active   TINYINT(1)      DEFAULT 1,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (game_id) REFERENCES brainplay_games(id) ON DELETE CASCADE,
    INDEX idx_game_active_diff (game_id, is_active, difficulty, language)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 6. ANSWERS  (multiple-choice options — language follows parent question)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_answers (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    question_id  BIGINT UNSIGNED NOT NULL,
    answer_text  VARCHAR(255)    NOT NULL,
    is_correct   TINYINT(1)      DEFAULT 0,
    sort_order   INT             DEFAULT 0,
    FOREIGN KEY (question_id) REFERENCES brainplay_questions(id) ON DELETE CASCADE,
    INDEX idx_question (question_id)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 7. USER PROGRESS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_user_progress (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT UNSIGNED NOT NULL,
    game_id       BIGINT UNSIGNED NOT NULL,
    level         INT UNSIGNED    NOT NULL,
    difficulty    ENUM('easy','medium','hard','expert') DEFAULT 'easy',
    score         INT UNSIGNED    DEFAULT 0,
    is_completed  TINYINT(1)      DEFAULT 0,
    attempts      INT UNSIGNED    DEFAULT 0,
    completed_at  TIMESTAMP       NULL,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES brainplay_users(id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES brainplay_games(id) ON DELETE CASCADE,
    UNIQUE KEY uq_user_game_level (user_id, game_id, level, difficulty),
    INDEX idx_user_game (user_id, game_id)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 8. SCORES  (leaderboard)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_scores (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL,
    game_id     BIGINT UNSIGNED NOT NULL,
    score       INT UNSIGNED    NOT NULL,
    time_taken  INT UNSIGNED    NULL COMMENT 'seconds',
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES brainplay_users(id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES brainplay_games(id) ON DELETE CASCADE,
    INDEX idx_score_desc (score DESC),
    INDEX idx_user_score (user_id, score DESC),
    INDEX idx_created    (created_at)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 9a. DAILY REWARD SCHEDULE  (7-day progression, editable from DB)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_daily_reward_schedule (
    day_number    INT UNSIGNED  NOT NULL PRIMARY KEY COMMENT '1–7',
    reward_type   ENUM('coins','mystery') DEFAULT 'coins',
    reward_amount INT UNSIGNED  DEFAULT 0
) ENGINE=InnoDB;

INSERT INTO brainplay_daily_reward_schedule (day_number, reward_type, reward_amount) VALUES
(1, 'coins',   20),
(2, 'coins',   40),
(3, 'coins',   60),
(4, 'coins',   80),
(5, 'coins',  100),
(6, 'coins',  120),
(7, 'mystery', 200);

-- ─────────────────────────────────────────────────────────────────
-- 9b. DAILY REWARDS  (claim history)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_daily_rewards (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id        BIGINT UNSIGNED NOT NULL,
    day_number     INT UNSIGNED    NOT NULL COMMENT '1–7 cycle',
    reward_type    ENUM('coins','mystery') DEFAULT 'coins',
    reward_amount  INT UNSIGNED    DEFAULT 0,
    claimed_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES brainplay_users(id) ON DELETE CASCADE,
    INDEX idx_user_claimed (user_id, claimed_at DESC)
) ENGINE=InnoDB;

-- ═══════════════════════════════════════════════════════════════
-- SHOP CATALOGUE  (base + translations)
-- ═══════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────
-- 10a. SHOP ITEMS  (language-agnostic fields only)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_shop_items (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    slug           VARCHAR(50)     NOT NULL UNIQUE,
    type           ENUM('coins','lives','premium','mystery_box') NOT NULL,
    price_coins    INT UNSIGNED    DEFAULT 0  COMMENT 'cost in in-game coins',
    price_usd      DECIMAL(8,2)    DEFAULT 0  COMMENT 'real-money IAP price',
    reward_amount  INT UNSIGNED    DEFAULT 0  COMMENT 'coins / lives granted',
    emoji          VARCHAR(10)     NULL,
    is_active      TINYINT(1)      DEFAULT 1,
    sort_order     INT             DEFAULT 0,
    created_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO brainplay_shop_items (slug, type, price_usd, price_coins, reward_amount, emoji, sort_order) VALUES
-- IAP (real money)
('premium',      'premium',  4.99, 0,    0,    '👑', 1),
('coins_100',    'coins',    0.99, 0,    100,  '🪙', 2),
('coins_500',    'coins',    3.99, 0,    500,  '💰', 3),
('coins_1000',   'coins',    6.99, 0,    1000, '🏦', 4),
('lives_5',      'lives',    0.99, 0,    5,    '❤️', 5),
-- In-game coins
('mystery_box',  'mystery_box', 0, 100,  0,    '🎁', 6),
('extra_life',   'lives',       0,  50,  1,    '❤️', 7);

-- ─────────────────────────────────────────────────────────────────
-- 10b. SHOP ITEM TRANSLATIONS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_shop_item_translations (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    item_id      BIGINT UNSIGNED NOT NULL,
    locale       VARCHAR(5)      NOT NULL,
    name         VARCHAR(100)    NOT NULL,
    description  TEXT            NULL,

    FOREIGN KEY (item_id) REFERENCES brainplay_shop_items(id) ON DELETE CASCADE,
    UNIQUE KEY uq_item_locale (item_id, locale)
) ENGINE=InnoDB;

INSERT INTO brainplay_shop_item_translations (item_id, locale, name, description) VALUES
-- English
(1, 'en', 'Premium',       'Remove ads & unlock all features'),
(2, 'en', '100 Coins',     'Small coin pack'),
(3, 'en', '500 Coins',     'Medium coin pack'),
(4, 'en', '1000 Coins',    'Large coin pack'),
(5, 'en', '5 Lives',       'Refill your lives'),
(6, 'en', 'Mystery Box',   'Surprise reward — costs 100 coins'),
(7, 'en', 'Extra Life',    'Buy 1 life — costs 50 coins'),
-- Arabic
(1, 'ar', 'بريميوم',       'أزل الإعلانات وافتح كل المميزات'),
(2, 'ar', '١٠٠ عملة',     'حزمة عملات صغيرة'),
(3, 'ar', '٥٠٠ عملة',     'حزمة عملات متوسطة'),
(4, 'ar', '١٠٠٠ عملة',    'حزمة عملات كبيرة'),
(5, 'ar', '٥ أرواح',      'أعد شحن أرواحك'),
(6, 'ar', 'صندوق مفاجأة', 'مكافأة مفاجئة — يكلف ١٠٠ عملة'),
(7, 'ar', 'حياة إضافية',  'اشتر حياة واحدة — يكلف ٥٠ عملة');

-- ─────────────────────────────────────────────────────────────────
-- 11. SHOP PURCHASES  (coin-based)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_shop_purchases (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL,
    item_id     BIGINT UNSIGNED NOT NULL,
    quantity    INT UNSIGNED    DEFAULT 1,
    coins_spent INT UNSIGNED    DEFAULT 0,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES brainplay_users(id)      ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES brainplay_shop_items(id) ON DELETE CASCADE,
    INDEX idx_user_shop (user_id, created_at DESC)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 12. IAP PURCHASES  (real-money transactions)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_purchases (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT UNSIGNED NOT NULL,
    product_id      VARCHAR(100)    NOT NULL,
    store           ENUM('google','apple') NOT NULL,
    transaction_id  VARCHAR(255)    NOT NULL UNIQUE,
    amount_cents    INT UNSIGNED    DEFAULT 0,
    currency        VARCHAR(3)      DEFAULT 'USD',
    status          ENUM('pending','completed','refunded') DEFAULT 'completed',
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES brainplay_users(id) ON DELETE CASCADE,
    INDEX idx_user_purchases (user_id),
    INDEX idx_transaction    (transaction_id)
) ENGINE=InnoDB;

-- ═══════════════════════════════════════════════════════════════
-- CHALLENGES  (base + translations)
-- ═══════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────
-- 13a. CHALLENGES  (language-agnostic fields only)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_challenges (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    game_id       BIGINT UNSIGNED NULL COMMENT 'NULL = any game',
    type          ENUM('daily','weekly','special') DEFAULT 'daily',
    goal_type     ENUM('score','levels','streak')  DEFAULT 'score',
    goal_value    INT UNSIGNED    NOT NULL,
    reward_coins  INT UNSIGNED    DEFAULT 0,
    reward_lives  INT UNSIGNED    DEFAULT 0,
    difficulty    ENUM('easy','medium','hard','expert') DEFAULT 'easy',
    starts_at     DATETIME        NOT NULL,
    ends_at       DATETIME        NOT NULL,
    is_active     TINYINT(1)      DEFAULT 1,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (game_id) REFERENCES brainplay_games(id) ON DELETE SET NULL,
    INDEX idx_active_period (is_active, starts_at, ends_at)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 13b. CHALLENGE TRANSLATIONS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_challenge_translations (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    challenge_id  BIGINT UNSIGNED NOT NULL,
    locale        VARCHAR(5)      NOT NULL,
    title         VARCHAR(150)    NOT NULL,
    description   TEXT            NULL,

    FOREIGN KEY (challenge_id) REFERENCES brainplay_challenges(id) ON DELETE CASCADE,
    UNIQUE KEY uq_challenge_locale (challenge_id, locale)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 14. USER CHALLENGES
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_user_challenges (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT UNSIGNED NOT NULL,
    challenge_id  BIGINT UNSIGNED NOT NULL,
    progress      INT UNSIGNED    DEFAULT 0,
    is_completed  TINYINT(1)      DEFAULT 0,
    completed_at  TIMESTAMP       NULL,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)      REFERENCES brainplay_users(id)      ON DELETE CASCADE,
    FOREIGN KEY (challenge_id) REFERENCES brainplay_challenges(id) ON DELETE CASCADE,
    UNIQUE KEY uq_user_challenge (user_id, challenge_id),
    INDEX idx_user_challenges (user_id, is_completed)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 15. CATEGORY WORDS  (valid words per category+letter for validation)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_category_words (
    id        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category  VARCHAR(50)     NOT NULL COMMENT 'e.g. animal, country, food',
    letter    VARCHAR(5)      NOT NULL COMMENT 'starting letter',
    word      VARCHAR(100)    NOT NULL,
    language  ENUM('en','ar') DEFAULT 'en',

    UNIQUE KEY uq_cat_word_lang (category, word, language),
    INDEX idx_lookup (category, letter, language)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 16. WORD CATEGORY ROUNDS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_word_category_rounds (
    id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id          BIGINT UNSIGNED NOT NULL,
    letter           VARCHAR(5)      NOT NULL,
    language         ENUM('en','ar') DEFAULT 'en',
    answers          JSON            NOT NULL COMMENT '{"animal":"Cat","color":"Cream",…}',
    correct_count    INT UNSIGNED    DEFAULT 0,
    total_categories INT UNSIGNED    DEFAULT 6,
    score            INT UNSIGNED    DEFAULT 0,
    won              TINYINT(1)      DEFAULT 0,
    created_at       TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES brainplay_users(id) ON DELETE CASCADE,
    INDEX idx_user_rounds (user_id, created_at DESC)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 17. NOTIFICATIONS (admin-sent push notifications)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_notifications (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title_en    VARCHAR(200)    NOT NULL,
    title_ar    VARCHAR(200)    NOT NULL,
    body_en     TEXT            NOT NULL,
    body_ar     TEXT            NOT NULL,
    image_url   VARCHAR(500)    NULL,
    data        JSON            NULL COMMENT 'optional payload e.g. {"route":"/shop"}',
    target      ENUM('all','custom') NOT NULL DEFAULT 'all' COMMENT 'all = broadcast, custom = specific users',
    sent_at     TIMESTAMP       NULL,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_sent (sent_at DESC),
    INDEX idx_target (target)
) ENGINE=InnoDB;

-- Pivot: which devices receive a "custom" notification
CREATE TABLE brainplay_notification_devices (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    notification_id BIGINT UNSIGNED NOT NULL,
    device_id       BIGINT UNSIGNED NOT NULL,
    read_at         TIMESTAMP       NULL,

    FOREIGN KEY (notification_id) REFERENCES brainplay_notifications(id) ON DELETE CASCADE,
    FOREIGN KEY (device_id)       REFERENCES brainplay_devices(id)       ON DELETE CASCADE,
    UNIQUE KEY uq_notif_device (notification_id, device_id),
    INDEX idx_device_notif (device_id, read_at)
) ENGINE=InnoDB;

-- ═══════════════════════════════════════════════════════════════
-- WALLET & WITHDRAWALS
-- ═══════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────
-- 18. WALLET CONFIGURATION  (admin-editable key-value settings)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_wallet_config (
    id     BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `key`  VARCHAR(50) NOT NULL UNIQUE,
    value  VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

INSERT INTO brainplay_wallet_config (`key`, value) VALUES
('coins_per_dollar',       '10000'),   -- 10,000 gems = $1
('min_withdraw_coins',     '50000'),   -- minimum 50,000 gems ($5)
('max_daily_ad_watches',   '50'),      -- max rewarded ad watches per day
('ad_cooldown_seconds',    '30'),      -- min seconds between ad watches
('withdrawal_enabled',     '1'),       -- 0 = disable withdrawals globally
('min_account_age_days',   '30'),      -- account must be 30 days old
('min_xp_to_withdraw',     '500'),     -- must have 500+ XP (proves real play)
('life_recovery_minutes',  '30'),      -- 1 life recovers every 30 min
('xp_per_correct_answer',  '10'),      -- XP for quiz/word correct
('xp_per_game_win',        '25'),      -- XP for board game wins
('xp_per_crossword',       '15'),      -- XP for crossword completion
('xp_per_classic_crossword','20'),     -- XP for classic crossword
('gems_per_ad',            '5'),       -- gems earned per ad watch
('hint_cost_gems',         '20'),      -- gems to use a hint
('spawn_cost_gems',        '5'),       -- gems to spawn in merge game
('merge_win_bonus_xp',     '50'),      -- XP bonus for merge game win
('word_category_timer',    '30'),      -- seconds for word category round
('interstitial_frequency', '3'),       -- show interstitial every N games
('mystery_box_frequency',  '4'),       -- show mystery box every N games
('streak_x15_days',        '3'),       -- days for 1.5x streak multiplier
('streak_x2_days',         '7'),       -- days for 2x streak multiplier
('streak_x3_days',         '30'),      -- days for 3x streak multiplier
('payment_methods',        'vodafone_cash,instapay,paypal');

-- ─────────────────────────────────────────────────────────────────
-- 19. WITHDRAWAL REQUESTS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_withdrawals (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT UNSIGNED NOT NULL,
    coins_amount    INT UNSIGNED    NOT NULL COMMENT 'coins deducted from user',
    money_amount    DECIMAL(10,2)   NOT NULL COMMENT 'real money to pay',
    currency        VARCHAR(5)      DEFAULT 'EGP',
    payment_method  VARCHAR(50)     NOT NULL COMMENT 'vodafone_cash, instapay, paypal',
    payment_details VARCHAR(255)    NOT NULL COMMENT 'phone number, account, email, etc.',
    status          ENUM('pending','approved','rejected','paid') DEFAULT 'pending',
    admin_note      TEXT            NULL,
    reviewed_at     TIMESTAMP       NULL,
    paid_at         TIMESTAMP       NULL,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES brainplay_users(id) ON DELETE CASCADE,
    INDEX idx_user_withdrawals (user_id, status),
    INDEX idx_status           (status, created_at DESC)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────────────────────────
-- 20. AD WATCH LOG  (anti-fraud: track rewarded ad watches)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE brainplay_ad_watches (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL,
    reward_type VARCHAR(30)     NOT NULL COMMENT 'coins, life, double_coins',
    coins_earned INT UNSIGNED   DEFAULT 0,
    watched_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES brainplay_users(id) ON DELETE CASCADE,
    INDEX idx_user_daily (user_id, watched_at)
) ENGINE=InnoDB;
