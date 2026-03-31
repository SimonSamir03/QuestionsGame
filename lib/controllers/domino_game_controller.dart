import 'dart:math';
import 'package:get/get.dart';

/// Represents a single domino tile [left|right] with values 0–6.
class DominoTile {
  final int left;
  final int right;

  const DominoTile(this.left, this.right);

  int get totalDots => left + right;
  bool get isDouble => left == right;

  /// Whether this tile can connect to the given end value.
  bool canMatch(int value) => left == value || right == value;

  /// Returns the outward-facing value when the tile connects at [connectValue].
  int otherSide(int connectValue) => left == connectValue ? right : left;

  @override
  bool operator ==(Object other) =>
      other is DominoTile &&
      ((left == other.left && right == other.right) ||
       (left == other.right && right == other.left));

  @override
  int get hashCode => left <= right ? left * 7 + right : right * 7 + left;

  @override
  String toString() => '[$left|$right]';
}

enum GameState { playing, playerWon, aiWon, draw }
enum TurnState { playerTurn, aiTurn }

class DominoGameController extends GetxController {
  final String language;
  final Function(bool won) onGameEnd;

  DominoGameController({required this.language, required this.onGameEnd});

  final playerHand = <DominoTile>[].obs;
  final aiHand = <DominoTile>[].obs;
  final board = <DominoTile>[].obs;
  final boneyard = <DominoTile>[].obs;

  final leftEnd = 0.obs;
  final rightEnd = 0.obs;

  final selectedTile = Rxn<DominoTile>();
  final gameState = GameState.playing.obs;
  final turnState = TurnState.playerTurn.obs;
  final message = ''.obs;
  final isProcessing = false.obs;
  final hintUsed = false.obs;
  final hintTile = Rxn<DominoTile>();
  final _stopwatch = Stopwatch();

  int get elapsedSeconds => _stopwatch.elapsed.inSeconds;

  @override
  void onInit() {
    super.onInit();
    _startGame();
  }

  void _startGame() {
    _stopwatch.reset();
    _stopwatch.start();
    // Generate full double-six set: 28 tiles
    final allTiles = <DominoTile>[];
    for (int i = 0; i <= 6; i++) {
      for (int j = i; j <= 6; j++) {
        allTiles.add(DominoTile(i, j));
      }
    }
    allTiles.shuffle(Random());

    playerHand.value = allTiles.sublist(0, 7);
    aiHand.value = allTiles.sublist(7, 14);
    boneyard.value = allTiles.sublist(14);
    board.clear();
    selectedTile.value = null;
    gameState.value = GameState.playing;
    message.value = '';
    isProcessing.value = false;

    // Find who has the highest double to start
    DominoTile? startTile;
    bool playerStarts = true;

    for (int d = 6; d >= 0; d--) {
      final dt = DominoTile(d, d);
      if (playerHand.contains(dt)) {
        startTile = playerHand.firstWhere((t) => t == dt);
        playerStarts = true;
        break;
      }
      if (aiHand.contains(dt)) {
        startTile = aiHand.firstWhere((t) => t == dt);
        playerStarts = false;
        break;
      }
    }

    if (startTile != null) {
      if (playerStarts) {
        playerHand.remove(startTile);
      } else {
        aiHand.remove(startTile);
      }
      board.add(startTile);
      leftEnd.value = startTile.left;
      rightEnd.value = startTile.right;

      if (playerStarts) {
        turnState.value = TurnState.playerTurn;
        _setMessage(false);
      } else {
        turnState.value = TurnState.playerTurn;
        _setMessage(false);
      }
    } else {
      // No doubles — player places first
      turnState.value = TurnState.playerTurn;
      _setMessage(false);
    }

    _checkGameEnd();
  }

  void _setMessage(bool isAi) {
    if (gameState.value != GameState.playing) return;
    if (isAi) {
      message.value = language == 'ar' ? 'دور الخصم...' : 'Opponent thinking...';
    } else {
      message.value = language == 'ar' ? 'دورك! اختر قطعة' : 'Your turn! Pick a tile';
    }
  }

  /// Highlight the best tile to play.
  void useHint() {
    if (hintUsed.value || gameState.value != GameState.playing) return;
    hintUsed.value = true;
    final sorted = [...playerHand]..sort((a, b) => b.totalDots.compareTo(a.totalDots));
    for (final tile in sorted) {
      if (board.isEmpty || tile.canMatch(leftEnd.value) || tile.canMatch(rightEnd.value)) {
        hintTile.value = tile;
        return;
      }
    }
  }

  /// Player selects a tile from hand.
  void selectTile(DominoTile tile) {
    if (turnState.value != TurnState.playerTurn || isProcessing.value) return;
    if (gameState.value != GameState.playing) return;

    final ends = getPlayableEnds(tile);
    // Auto-play when there's exactly one option
    if (ends.length == 1) {
      selectedTile.value = tile;
      playTile(ends.first);
      return;
    }
    selectedTile.value = selectedTile.value == tile ? null : tile;
  }

  /// Get playable ends for a given tile.
  List<String> getPlayableEnds(DominoTile tile) {
    if (board.isEmpty) return ['left'];
    final ends = <String>[];
    if (tile.canMatch(leftEnd.value)) ends.add('left');
    if (tile.canMatch(rightEnd.value)) ends.add('right');
    return ends;
  }

  /// Player places the selected tile on the given end ("left" or "right").
  void playTile(String end) {
    final tile = selectedTile.value;
    if (tile == null || turnState.value != TurnState.playerTurn) return;
    if (gameState.value != GameState.playing) return;

    if (board.isEmpty) {
      _placeTile(tile, 'left', playerHand);
    } else {
      _placeTile(tile, end, playerHand);
    }

    selectedTile.value = null;
    if (_checkGameEnd()) return;

    // AI turn
    turnState.value = TurnState.aiTurn;
    _setMessage(true);
    isProcessing.value = true;
    Future.delayed(const Duration(milliseconds: 800), () {
      _aiPlay();
    });
  }

  /// Player draws from boneyard.
  void drawTile() {
    if (turnState.value != TurnState.playerTurn || isProcessing.value) return;
    if (gameState.value != GameState.playing) return;

    // Only allow drawing if player has no playable tiles
    if (_hasPlayable(playerHand)) {
      message.value = language == 'ar'
          ? 'لديك قطعة يمكن لعبها!'
          : 'You have a playable tile!';
      return;
    }

    if (boneyard.isEmpty) {
      // Must pass
      message.value = language == 'ar' ? 'لا يمكنك السحب، تم التمرير' : 'No tiles to draw, passing...';
      turnState.value = TurnState.aiTurn;
      _setMessage(true);
      isProcessing.value = true;
      Future.delayed(const Duration(milliseconds: 800), () {
        _aiPlay();
      });
      return;
    }

    final drawn = boneyard.removeAt(0);
    playerHand.add(drawn);
    playerHand.refresh();
    boneyard.refresh();
  }

  void _placeTile(DominoTile tile, String end, RxList<DominoTile> hand) {
    hand.remove(tile);

    if (board.isEmpty) {
      board.add(tile);
      leftEnd.value = tile.left;
      rightEnd.value = tile.right;
      return;
    }

    if (end == 'left') {
      final matchVal = leftEnd.value;
      // Orient tile so connecting side faces the chain
      final oriented = tile.right == matchVal
          ? tile
          : DominoTile(tile.right, tile.left);
      board.insert(0, oriented);
      leftEnd.value = oriented.left;
    } else {
      final matchVal = rightEnd.value;
      final oriented = tile.left == matchVal
          ? tile
          : DominoTile(tile.right, tile.left);
      board.add(oriented);
      rightEnd.value = oriented.right;
    }
  }

  void _aiPlay() {
    if (gameState.value != GameState.playing) {
      isProcessing.value = false;
      return;
    }

    // Try to find a playable tile (prefer highest dot count)
    final sorted = [...aiHand]..sort((a, b) => b.totalDots.compareTo(a.totalDots));

    for (final tile in sorted) {
      if (board.isEmpty) {
        _placeTile(tile, 'left', aiHand);
        _afterAiTurn();
        return;
      }
      if (tile.canMatch(rightEnd.value)) {
        _placeTile(tile, 'right', aiHand);
        _afterAiTurn();
        return;
      }
      if (tile.canMatch(leftEnd.value)) {
        _placeTile(tile, 'left', aiHand);
        _afterAiTurn();
        return;
      }
    }

    // Can't play — draw from boneyard
    if (boneyard.isNotEmpty) {
      final drawn = boneyard.removeAt(0);
      aiHand.add(drawn);
      aiHand.refresh();
      boneyard.refresh();

      // Try again with the new tile
      if (drawn.canMatch(rightEnd.value)) {
        _placeTile(drawn, 'right', aiHand);
      } else if (drawn.canMatch(leftEnd.value)) {
        _placeTile(drawn, 'left', aiHand);
      }
      // If still can't play, pass
    }

    _afterAiTurn();
  }

  void _afterAiTurn() {
    isProcessing.value = false;
    if (_checkGameEnd()) return;
    turnState.value = TurnState.playerTurn;
    _setMessage(false);
  }

  bool _hasPlayable(List<DominoTile> hand) {
    if (board.isEmpty) return hand.isNotEmpty;
    return hand.any((t) => t.canMatch(leftEnd.value) || t.canMatch(rightEnd.value));
  }

  bool _checkGameEnd() {
    if (playerHand.isEmpty) {
      _stopwatch.stop();
      gameState.value = GameState.playerWon;
      message.value = language == 'ar' ? 'فزت! 🎉' : 'You Won! 🎉';
      Future.delayed(const Duration(seconds: 1), () => onGameEnd(true));
      return true;
    }
    if (aiHand.isEmpty) {
      _stopwatch.stop();
      gameState.value = GameState.aiWon;
      message.value = language == 'ar' ? 'الخصم فاز!' : 'Opponent Wins!';
      Future.delayed(const Duration(seconds: 1), () => onGameEnd(false));
      return true;
    }

    // Check for blocked game (neither can play and boneyard empty)
    if (boneyard.isEmpty &&
        !_hasPlayable(playerHand) &&
        !_hasPlayable(aiHand)) {
      final playerDots = playerHand.fold<int>(0, (s, t) => s + t.totalDots);
      final aiDots = aiHand.fold<int>(0, (s, t) => s + t.totalDots);

      _stopwatch.stop();
      if (playerDots <= aiDots) {
        gameState.value = GameState.playerWon;
        message.value = language == 'ar'
            ? 'مسدود! فزت بأقل نقاط ($playerDots مقابل $aiDots)'
            : 'Blocked! You win with fewer dots ($playerDots vs $aiDots)';
        Future.delayed(const Duration(seconds: 1), () => onGameEnd(true));
      } else {
        gameState.value = GameState.aiWon;
        message.value = language == 'ar'
            ? 'مسدود! الخصم فاز ($aiDots مقابل $playerDots)'
            : 'Blocked! Opponent wins ($aiDots vs $playerDots)';
        Future.delayed(const Duration(seconds: 1), () => onGameEnd(false));
      }
      return true;
    }

    return false;
  }

  void restart() {
    _startGame();
  }
}
