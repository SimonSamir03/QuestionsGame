import 'package:flutter/material.dart';

/// A single item on the merge grid.
class MergeItem {
  final String category; // e.g. 'food', 'drink', 'nature', 'craft'
  final int level;       // 1–5

  const MergeItem({required this.category, required this.level});

  /// Two items can merge if same category + same level (and level < maxLevel).
  bool canMerge(MergeItem other) =>
      category == other.category && level == other.level && level < maxLevel;

  MergeItem merged() => MergeItem(category: category, level: level + 1);

  static const int maxLevel = 5;

  // ── Visual data ───────────────────────────────────────────────────────

  String get emoji => _emojis[category]?[level - 1] ?? '?';

  Color get color => _colors[category] ?? Colors.grey;

  static const Map<String, List<String>> _emojis = {
    'food':   ['🌾', '🥚', '🍞', '🥐', '🎂'],
    'drink':  ['💧', '🫖', '☕', '🧃', '🍹'],
    'nature': ['🌱', '🌿', '🌻', '🌳', '🏡'],
    'craft':  ['🪨', '⚙️', '🔨', '⛏️', '💎'],
    'sea':    ['🐚', '🦀', '🐟', '🐬', '🐋'],
    'sweet':  ['🍬', '🍪', '🧁', '🍰', '🎁'],
  };

  static const Map<String, Color> _colors = {
    'food':   Color(0xFFFFA726),
    'drink':  Color(0xFF42A5F5),
    'nature': Color(0xFF66BB6A),
    'craft':  Color(0xFF8D6E63),
    'sea':    Color(0xFF26C6DA),
    'sweet':  Color(0xFFEC407A),
  };

  static const List<String> categories = ['food', 'drink', 'nature', 'craft', 'sea', 'sweet'];
}

/// An order the player must fulfill by producing a specific item.
class MergeOrder {
  final MergeItem target;
  bool fulfilled;

  MergeOrder({required this.target, this.fulfilled = false});
}
