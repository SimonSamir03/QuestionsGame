import 'package:flutter/material.dart';

/// Player colors in Ludo
enum LudoColor { red, green, yellow, blue }

/// Game mode
enum LudoMode { vsAi, local2, local3, local4, online }

/// Board visual themes
enum LudoBoardTheme {
  classic, // Current wooden board
  royal,   // Dark luxury board (dark walnut wood, gold accents)
  garden,  // Green nature theme
  ocean,   // Blue water theme
}

extension LudoColorExt on LudoColor {
  Color get color {
    switch (this) {
      case LudoColor.red: return Colors.red;
      case LudoColor.green: return Colors.green;
      case LudoColor.yellow: return Colors.amber;
      case LudoColor.blue: return Colors.blue;
    }
  }

  Color get lightColor {
    switch (this) {
      case LudoColor.red: return Colors.red.shade100;
      case LudoColor.green: return Colors.green.shade100;
      case LudoColor.yellow: return Colors.amber.shade100;
      case LudoColor.blue: return Colors.blue.shade100;
    }
  }

  String label(bool isAr) {
    switch (this) {
      case LudoColor.red: return isAr ? 'أحمر' : 'Red';
      case LudoColor.green: return isAr ? 'أخضر' : 'Green';
      case LudoColor.yellow: return isAr ? 'أصفر' : 'Yellow';
      case LudoColor.blue: return isAr ? 'أزرق' : 'Blue';
    }
  }

  /// Starting position on the main track (0-51)
  int get startPos {
    switch (this) {
      case LudoColor.red: return 39;    // bottom-left
      case LudoColor.green: return 0;   // top-left
      case LudoColor.yellow: return 13; // top-right
      case LudoColor.blue: return 26;   // bottom-right
    }
  }

  /// Position just before entering home column
  int get homeEntryPos {
    switch (this) {
      case LudoColor.red: return 37;    // bottom-left, enters going up
      case LudoColor.green: return 50;  // top-left, enters going right
      case LudoColor.yellow: return 11; // top-right, enters going down
      case LudoColor.blue: return 24;   // bottom-right, enters going left
    }
  }
}

/// A single piece on the board
class LudoPiece {
  final LudoColor color;
  final int index; // 0-3, which piece of this color

  /// -1 = in yard (home base), 0-51 = main track, 100-105 = home column
  int position;

  /// Steps taken on the track (used to calculate home entry)
  int stepsTaken;

  bool get isInYard => position == -1;
  bool get isOnTrack => position >= 0 && position < 52;
  bool get isInHomeColumn => position >= 100 && position <= 105;
  bool get isFinished => position == 106;

  LudoPiece({
    required this.color,
    required this.index,
    this.position = -1,
    this.stepsTaken = 0,
  });

  /// Absolute position on the main track for this piece
  int get absoluteTrackPos {
    if (!isOnTrack) return -1;
    return position;
  }

  /// Can this piece move the given number of steps?
  bool canMove(int dice) {
    if (isFinished) return false;

    if (isInYard) return dice == 6;

    if (isInHomeColumn) {
      final homePos = position - 100; // 0-5
      final newHomePos = homePos + dice;
      return newHomePos <= 6; // 6 = finished
    }

    // On track
    final newSteps = stepsTaken + dice;
    if (newSteps > 56) return false; // overshot home
    return true;
  }

  @override
  String toString() => '${color.name}[$index] pos=$position steps=$stepsTaken';
}

/// A player in the game
class LudoPlayer {
  final LudoColor color;
  final String name;
  final bool isAi;
  final bool isOnline;
  final List<LudoPiece> pieces;

  bool get allFinished => pieces.every((p) => p.isFinished);
  int get finishedCount => pieces.where((p) => p.isFinished).length;
  int get piecesOnTrack => pieces.where((p) => p.isOnTrack || p.isInHomeColumn).length;

  LudoPlayer({
    required this.color,
    required this.name,
    this.isAi = false,
    this.isOnline = false,
  }) : pieces = List.generate(4, (i) => LudoPiece(color: color, index: i));

  void reset() {
    for (final p in pieces) {
      p.position = -1;
      p.stepsTaken = 0;
    }
  }
}

/// Board layout constants
class LudoBoard {
  static const int trackSize = 52;
  static const int homeColumnSize = 6;

  /// Safe positions on the main track (can't be captured here)
  static final Set<int> safePositions = {
    0, 8, 13, 21, 26, 34, 39, 47, // start positions + star positions
  };

  static bool isSafe(int pos) => safePositions.contains(pos);

  /// Convert a piece's logical position to grid coordinates (15x15 board)
  static Offset getGridPosition(LudoPiece piece) {
    if (piece.isInYard) return _yardPosition(piece.color, piece.index);
    if (piece.isFinished) return const Offset(7, 7); // center
    if (piece.isInHomeColumn) return _homeColumnPosition(piece.color, piece.position - 100);
    return _trackPosition(piece.position);
  }

  static Offset _yardPosition(LudoColor color, int index) {
    // Center of each yard's inner white box (6x6 yard, 0.8 margin each side = 4.4 inner)
    // Inner box center offsets from yard top-left: 3.0, 3.0
    // Piece spacing: ±0.28 * 4.4 = ±1.232
    final yardTopLeft = {
      LudoColor.red: const Offset(0, 9),     // bottom-left
      LudoColor.green: const Offset(0, 0),    // top-left
      LudoColor.yellow: const Offset(9, 0),   // top-right
      LudoColor.blue: const Offset(9, 9),     // bottom-right
    };
    final tl = yardTopLeft[color]!;
    final cx = tl.dx + 3.0;
    final cy = tl.dy + 3.0;
    const spacing = 1.23;
    final positions = [
      Offset(cx - spacing, cy - spacing), // top-left
      Offset(cx + spacing, cy - spacing), // top-right
      Offset(cx - spacing, cy + spacing), // bottom-left
      Offset(cx + spacing, cy + spacing), // bottom-right
    ];
    return positions[index];
  }

  /// Main track positions mapped to 15x15 grid
  static Offset _trackPosition(int pos) {
    const List<Offset> track = [
      // Red start (top-left to top-middle) — positions 0-4
      Offset(1, 6), Offset(2, 6), Offset(3, 6), Offset(4, 6), Offset(5, 6),
      // Going up — positions 5-10
      Offset(6, 5), Offset(6, 4), Offset(6, 3), Offset(6, 2), Offset(6, 1), Offset(6, 0),
      // Top-right corner — positions 11-12
      Offset(7, 0), Offset(8, 0),
      // Green start — going down — positions 13-17
      Offset(8, 1), Offset(8, 2), Offset(8, 3), Offset(8, 4), Offset(8, 5),
      // Going right — positions 18-23
      Offset(9, 6), Offset(10, 6), Offset(11, 6), Offset(12, 6), Offset(13, 6), Offset(14, 6),
      // Right-bottom corner — positions 24-25
      Offset(14, 7), Offset(14, 8),
      // Yellow start — going left — positions 26-30
      Offset(13, 8), Offset(12, 8), Offset(11, 8), Offset(10, 8), Offset(9, 8),
      // Going down — positions 31-36
      Offset(8, 9), Offset(8, 10), Offset(8, 11), Offset(8, 12), Offset(8, 13), Offset(8, 14),
      // Bottom-left corner — positions 37-38
      Offset(7, 14), Offset(6, 14),
      // Blue start — going up — positions 39-43
      Offset(6, 13), Offset(6, 12), Offset(6, 11), Offset(6, 10), Offset(6, 9),
      // Going left — positions 44-49
      Offset(5, 8), Offset(4, 8), Offset(3, 8), Offset(2, 8), Offset(1, 8), Offset(0, 8),
      // Bottom-left to top-left corner — positions 50-51
      Offset(0, 7), Offset(0, 6),
    ];
    return track[pos % trackSize];
  }

  /// Home column positions for each color
  static Offset _homeColumnPosition(LudoColor color, int step) {
    switch (color) {
      case LudoColor.red:
        return Offset(7, 13.0 - step); // bottom to center
      case LudoColor.green:
        return Offset(1.0 + step, 7);  // left to center
      case LudoColor.yellow:
        return Offset(7, 1.0 + step);  // top to center
      case LudoColor.blue:
        return Offset(13.0 - step, 7); // right to center
    }
  }
}
