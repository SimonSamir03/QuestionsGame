# BrainPlay REST API Design

Base URL: `https://api.brainplay.app/api`

## Authentication

### POST /register
Register a new user.
- Body: `{ name, email, password, language }`
- Response 201: `{ user: {...}, token: "..." }`

### POST /login
- Body: `{ email, password }`
- Response 200: `{ user: {...}, token: "..." }`

### POST /logout
- Headers: `Authorization: Bearer <token>`
- Response 200: `{ message: "Logged out" }`

---

## Games

### GET /games
List all active games.
- Response 200: `{ data: [{ id, slug, name_en, name_ar, emoji }] }`

---

## Puzzles / Questions

### GET /puzzles
Get puzzles for a game type.
- Query: `type, difficulty, language, page`
- Response 200: `{ data: [{ id, type, question, answer, options, difficulty, language }], meta: { current_page, last_page } }`

### GET /daily-challenge
Get today's daily challenge puzzle.
- Response 200: `{ puzzle: {...} }`

---

## Game Actions

### POST /submit-answer
Submit an answer for a puzzle.
- Headers: `Authorization: Bearer <token>`
- Body: `{ puzzle_id, answer, level_number }`
- Response 200: `{ correct: true/false, coins_earned: 10, new_total: 150 }`

### POST /reward-ad
Record an ad reward.
- Headers: `Authorization: Bearer <token>`
- Body: `{ reward_type: "coins"|"life"|"double" }`
- Response 200: `{ reward: { type, amount }, new_balance: {...} }`

---

## Word Categories

### GET /word-categories/letter
Get a random letter and categories.
- Query: `language`
- Response 200: `{ letter: "B", categories: ["name","job","object","food","animal","country"] }`

### POST /word-categories/submit
Submit word category round answers.
- Body: `{ letter, language, answers: { name: "...", job: "..." } }`
- Response 200: `{ results: {...}, correct_count, total_categories, score, won }`

---

## Daily Rewards

### GET /daily-reward/status
- Headers: `Authorization: Bearer <token>`
- Response 200: `{ current_streak, can_claim, streak_broken, last_claim_date }`

### POST /daily-reward/claim
- Headers: `Authorization: Bearer <token>`
- Response 200: `{ reward: { type, amount }, streak_day, new_balance }`

### POST /daily-reward/restore-streak
Restore broken streak (after watching ad).
- Headers: `Authorization: Bearer <token>`
- Response 200: `{ restored: true, current_streak }`

---

## Leaderboard

### GET /leaderboard
- Query: `period=daily|weekly|monthly|global, limit=50`
- Response 200: `{ leaderboard: [{ rank, name, score, avatar_url }] }`

### GET /leaderboard/my-rank
- Headers: `Authorization: Bearer <token>`
- Query: `period`
- Response 200: `{ rank, score, total_players }`

---

## Scores

### POST /scores
Submit a game score.
- Headers: `Authorization: Bearer <token>`
- Body: `{ game_id, score, time_taken? }`
- Response 201: `{ score: {...}, rank }`

---

## User Progress

### GET /user/progress
Get all progress for the authenticated user.
- Headers: `Authorization: Bearer <token>`
- Response 200: `{ progress: [{ game_id, level, difficulty, score, is_completed }] }`

### POST /user/progress
Update progress for a specific game level.
- Headers: `Authorization: Bearer <token>`
- Body: `{ game_id, level, difficulty, score }`
- Response 200: `{ progress: {...} }`

---

## Purchases

### GET /products
List available products.
- Response 200: `{ products: [{ id, name, price, type }] }`

### POST /purchase
Record a purchase.
- Headers: `Authorization: Bearer <token>`
- Body: `{ product_id, store, transaction_id }`
- Response 200: `{ purchase: {...}, new_balance }`

---

## Challenges

### POST /challenges
Create a challenge.
- Headers: `Authorization: Bearer <token>`
- Body: `{ opponent_id, game_type }`
- Response 201: `{ challenge: {...} }`

### GET /challenges/mine
Get user's challenges.
- Headers: `Authorization: Bearer <token>`
- Response 200: `{ challenges: [...] }`

---

## Error Responses
- 400: `{ error: "Validation error", details: {...} }`
- 401: `{ error: "Unauthorized" }`
- 404: `{ error: "Not found" }`
- 500: `{ error: "Server error" }`
