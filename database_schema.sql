-- ═══════════════════════════════════════════════════════════════
-- BrainPlay - MySQL Database Schema
-- ═══════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS brainplay CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE brainplay;

-- ─── Users ───
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    language ENUM('en', 'ar') DEFAULT 'en',
    coins INT UNSIGNED DEFAULT 0,
    lives INT UNSIGNED DEFAULT 5,
    is_premium TINYINT(1) DEFAULT 0,
    streak_days INT UNSIGNED DEFAULT 0,
    last_streak_date DATE NULL,
    avatar_url VARCHAR(500) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_streak (streak_days DESC)
) ENGINE=InnoDB;

-- ─── Games ───
CREATE TABLE games (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    slug VARCHAR(50) NOT NULL UNIQUE,
    name_en VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NOT NULL,
    description_en TEXT NULL,
    description_ar TEXT NULL,
    emoji VARCHAR(10) NULL,
    is_active TINYINT(1) DEFAULT 1,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO games (slug, name_en, name_ar, emoji, sort_order) VALUES
('word', 'Word Builder', 'ترتيب الحروف', '🔤', 1),
('quiz', 'Quick Quiz', 'أسئلة سريعة', '❓', 2),
('count', 'Count Puzzle', 'عد الأشكال', '🔢', 3),
('word_categories', 'Word Categories', 'تحدي الحروف', '🅰️', 4),
('crossword', 'Word Search', 'البحث عن الكلمات', '🔍', 5),
('classic_crossword', 'Classic Crossword', 'الكلمات المتقاطعة', '✏️', 6);

-- ─── Questions ───
CREATE TABLE questions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    game_id BIGINT UNSIGNED NOT NULL,
    type VARCHAR(50) NOT NULL,
    question TEXT NOT NULL,
    answer VARCHAR(255) NOT NULL,
    difficulty ENUM('easy', 'medium', 'hard', 'expert') DEFAULT 'easy',
    language ENUM('en', 'ar') DEFAULT 'en',
    metadata JSON NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    INDEX idx_type_diff_lang (type, difficulty, language),
    INDEX idx_game_active (game_id, is_active)
) ENGINE=InnoDB;

-- ─── Answers (options for multiple choice) ───
CREATE TABLE answers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    question_id BIGINT UNSIGNED NOT NULL,
    answer_text VARCHAR(255) NOT NULL,
    is_correct TINYINT(1) DEFAULT 0,
    sort_order INT DEFAULT 0,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    INDEX idx_question (question_id)
) ENGINE=InnoDB;

-- ─── User Progress ───
CREATE TABLE user_progress (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    game_id BIGINT UNSIGNED NOT NULL,
    level INT UNSIGNED NOT NULL,
    difficulty ENUM('easy', 'medium', 'hard', 'expert') DEFAULT 'easy',
    score INT UNSIGNED DEFAULT 0,
    is_completed TINYINT(1) DEFAULT 0,
    attempts INT UNSIGNED DEFAULT 0,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    UNIQUE KEY uq_user_game_level (user_id, game_id, level, difficulty),
    INDEX idx_user_game (user_id, game_id)
) ENGINE=InnoDB;

-- ─── Scores (leaderboard entries) ───
CREATE TABLE scores (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    game_id BIGINT UNSIGNED NOT NULL,
    score INT UNSIGNED NOT NULL,
    time_taken INT UNSIGNED NULL COMMENT 'seconds',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    INDEX idx_score_desc (score DESC),
    INDEX idx_user_score (user_id, score DESC),
    INDEX idx_created (created_at)
) ENGINE=InnoDB;

-- ─── Daily Rewards ───
CREATE TABLE daily_rewards (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    day_number INT UNSIGNED NOT NULL COMMENT '1-7 cycle',
    reward_type ENUM('coins', 'mystery') DEFAULT 'coins',
    reward_amount INT UNSIGNED DEFAULT 0,
    claimed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_claimed (user_id, claimed_at DESC)
) ENGINE=InnoDB;

-- ─── Purchases ───
CREATE TABLE purchases (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    product_id VARCHAR(100) NOT NULL,
    store ENUM('google', 'apple') NOT NULL,
    transaction_id VARCHAR(255) NOT NULL UNIQUE,
    amount_cents INT UNSIGNED DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'USD',
    status ENUM('pending', 'completed', 'refunded') DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_purchases (user_id),
    INDEX idx_transaction (transaction_id)
) ENGINE=InnoDB;

-- ─── Auth Tokens ───
CREATE TABLE auth_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    token VARCHAR(500) NOT NULL UNIQUE,
    device_info VARCHAR(255) NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_user_tokens (user_id)
) ENGINE=InnoDB;

-- ─── Word Category Rounds ───
CREATE TABLE word_category_rounds (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    letter VARCHAR(5) NOT NULL,
    language ENUM('en', 'ar') DEFAULT 'en',
    answers JSON NOT NULL,
    correct_count INT UNSIGNED DEFAULT 0,
    total_categories INT UNSIGNED DEFAULT 6,
    score INT UNSIGNED DEFAULT 0,
    won TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_rounds (user_id, created_at DESC)
) ENGINE=InnoDB;
