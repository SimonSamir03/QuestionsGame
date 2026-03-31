import 'dart:math';
import 'package:get/get.dart';
import '../models/ludo_models.dart';
import '../services/sound_service.dart';
import 'game_controller.dart';

class LudoController extends GetxController {
  final LudoMode mode;
  final String language;
  final LudoColor playerColor;
  final Function(LudoColor winner)? onGameEnd;

  LudoController({
    required this.mode,
    required this.language,
    this.playerColor = LudoColor.red,
    this.onGameEnd,
  });

  final players = <LudoPlayer>[].obs;
  final currentPlayerIndex = 0.obs;
  final diceValue = 0.obs;
  final hasRolled = false.obs;
  final isRolling = false.obs;
  final isProcessing = false.obs;
  final selectedPieceIndex = (-1).obs;
  final message = ''.obs;
  final gameOver = false.obs;
  final winner = Rxn<LudoColor>();
  final rankings = <LudoColor>[].obs;
  final consecutiveSixes = 0.obs;
  final boardTheme = LudoBoardTheme.classic.obs;

  final _rng = Random();
  final _sound = SoundService();
  bool get isAr => language == 'ar';

  LudoPlayer get currentPlayer => players[currentPlayerIndex.value];
  bool get isCurrentPlayerAi => currentPlayer.isAi;
  bool get isCurrentPlayerLocal => !currentPlayer.isAi && !currentPlayer.isOnline;

  @override
  void onInit() {
    super.onInit();
    _setupPlayers();
    _setTurnMessage();
  }

  // ── Setup ────────────────────────────────────────────────────────────────

  void _setupPlayers() {
    // Get player's display name
    final gc = Get.find<GameController>();
    final playerName = gc.playerName.value.isNotEmpty ? gc.playerName.value : (isAr ? 'أنت' : 'You');

    // All 4 colors in order, player's chosen color first
    final allColors = [playerColor, ...LudoColor.values.where((c) => c != playerColor)];

    switch (mode) {
      case LudoMode.vsAi:
        // Player + 1 AI
        players.add(LudoPlayer(color: playerColor, name: playerName));
        final aiColor = allColors[1];
        players.add(LudoPlayer(color: aiColor, name: isAr ? 'بوت' : 'Bot', isAi: true));
        break;
      case LudoMode.local2:
        players.add(LudoPlayer(color: allColors[0], name: playerName));
        players.add(LudoPlayer(color: allColors[1], name: isAr ? 'لاعب 2' : 'Player 2'));
        break;
      case LudoMode.local3:
        players.add(LudoPlayer(color: allColors[0], name: playerName));
        players.add(LudoPlayer(color: allColors[1], name: isAr ? 'لاعب 2' : 'Player 2'));
        players.add(LudoPlayer(color: allColors[2], name: isAr ? 'لاعب 3' : 'Player 3'));
        break;
      case LudoMode.local4:
        players.add(LudoPlayer(color: allColors[0], name: playerName));
        players.add(LudoPlayer(color: allColors[1], name: isAr ? 'لاعب 2' : 'Player 2'));
        players.add(LudoPlayer(color: allColors[2], name: isAr ? 'لاعب 3' : 'Player 3'));
        players.add(LudoPlayer(color: allColors[3], name: isAr ? 'لاعب 4' : 'Player 4'));
        break;
      case LudoMode.online:
        players.add(LudoPlayer(color: playerColor, name: playerName));
        final onlineColor = allColors[1];
        players.add(LudoPlayer(color: onlineColor, name: isAr ? 'خصم' : 'Opponent', isOnline: true));
        break;
    }
  }

  // ── Dice ──────────────────────────────────────────────────────────────────

  void rollDice() {
    if (hasRolled.value || isRolling.value || isProcessing.value || gameOver.value) return;
    if (isCurrentPlayerAi) return;

    _performRoll();
  }

  void _performRoll() {
    isRolling.value = true;
    diceValue.value = 0;
    _sound.playDiceRoll();

    // Animate dice roll
    int count = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 60));
      diceValue.value = _rng.nextInt(6) + 1;
      count++;
      return count < 10;
    }).then((_) {
      diceValue.value = _rng.nextInt(6) + 1;
      isRolling.value = false;
      hasRolled.value = true;

      // Check for 3 consecutive sixes
      if (diceValue.value == 6) {
        consecutiveSixes.value++;
        if (consecutiveSixes.value >= 3) {
          message.value = isAr ? 'ثلاث ستات متتالية! تم تخطي الدور' : 'Three 6s in a row! Turn skipped';
          consecutiveSixes.value = 0;
          Future.delayed(const Duration(milliseconds: 1000), _nextTurn);
          return;
        }
      } else {
        consecutiveSixes.value = 0;
      }

      _afterRoll();
    });
  }

  void _afterRoll() {
    final movable = _getMovablePieces();

    if (movable.isEmpty) {
      message.value = isAr ? 'لا يوجد حركة متاحة' : 'No moves available';
      Future.delayed(const Duration(milliseconds: 800), _nextTurn);
      return;
    }

    if (isCurrentPlayerAi) {
      Future.delayed(const Duration(milliseconds: 500), _aiMove);
      return;
    }

    if (movable.length == 1) {
      // Auto-move if only one piece can move
      _movePiece(movable.first);
      return;
    }

    message.value = isAr ? 'اختر قطعة للتحريك' : 'Select a piece to move';
  }

  List<LudoPiece> _getMovablePieces() {
    return currentPlayer.pieces.where((p) => p.canMove(diceValue.value)).toList();
  }

  // ── Movement ─────────────────────────────────────────────────────────────

  void selectPiece(LudoPiece piece) {
    if (!hasRolled.value || isProcessing.value || gameOver.value) return;
    if (isCurrentPlayerAi) return;
    if (piece.color != currentPlayer.color) return;
    if (!piece.canMove(diceValue.value)) return;

    _movePiece(piece);
  }

  void _movePiece(LudoPiece piece) async {
    isProcessing.value = true;
    selectedPieceIndex.value = -1;
    final dice = diceValue.value;

    if (piece.isInYard && dice == 6) {
      // Move out of yard to start position
      piece.position = piece.color.startPos;
      piece.stepsTaken = 0;
      _sound.playPieceMove();
      players.refresh();
      await Future.delayed(const Duration(milliseconds: 200));
      _checkCapture(piece);
    } else if (piece.isInHomeColumn) {
      // Step by step in home column
      final homePos = piece.position - 100;
      for (int s = 1; s <= dice; s++) {
        _sound.playPieceMove();
        final newHomePos = homePos + s;
        if (newHomePos >= 6) {
          piece.position = 106; // finished!
          players.refresh();
          await Future.delayed(const Duration(milliseconds: 150));
          _onPieceFinished(piece);
          break;
        } else {
          piece.position = 100 + newHomePos;
          players.refresh();
          await Future.delayed(const Duration(milliseconds: 150));
        }
      }
    } else if (piece.isOnTrack) {
      // Step by step on track
      for (int s = 1; s <= dice; s++) {
        _sound.playPieceMove();
        final newSteps = piece.stepsTaken + 1;

        if (newSteps > 50 && newSteps <= 56) {
          // Enter home column
          piece.position = 100 + (newSteps - 51);
          piece.stepsTaken = newSteps;
          players.refresh();
          await Future.delayed(const Duration(milliseconds: 150));
          if (piece.position == 106) {
            _onPieceFinished(piece);
            break;
          }
        } else if (newSteps == 56) {
          piece.position = 106;
          piece.stepsTaken = newSteps;
          players.refresh();
          await Future.delayed(const Duration(milliseconds: 150));
          _onPieceFinished(piece);
          break;
        } else {
          // Normal track step
          piece.position = (piece.position + 1) % 52;
          piece.stepsTaken = newSteps;
          players.refresh();
          await Future.delayed(const Duration(milliseconds: 150));
        }
      }

      // Check capture only at final position
      if (piece.isOnTrack) {
        _checkCapture(piece);
      }
    }

    players.refresh();

    await Future.delayed(const Duration(milliseconds: 200));
    isProcessing.value = false;

    // Check win
    if (currentPlayer.allFinished) {
      _onPlayerFinished(currentPlayer);
      return;
    }

    // Roll again on 6
    if (dice == 6) {
      hasRolled.value = false;
      message.value = isAr ? 'رميت 6! ارمِ مرة أخرى' : 'Rolled 6! Roll again';
      if (isCurrentPlayerAi) {
        Future.delayed(const Duration(milliseconds: 600), () => _performRoll());
      }
      return;
    }

    _nextTurn();
  }

  void _checkCapture(LudoPiece piece) {
    if (LudoBoard.isSafe(piece.position)) return;

    for (final player in players) {
      if (player.color == piece.color) continue;
      for (final other in player.pieces) {
        if (other.isOnTrack && other.position == piece.position) {
          // Capture! Send back to yard
          _sound.playCapture();
          other.position = -1;
          other.stepsTaken = 0;
          message.value = isAr
              ? '${piece.color.label(true)} أكل ${other.color.label(true)}!'
              : '${piece.color.label(false)} captured ${other.color.label(false)}!';
        }
      }
    }
  }

  void _onPieceFinished(LudoPiece piece) {
    _sound.playPieceFinish();
    message.value = isAr
        ? 'قطعة ${piece.color.label(true)} وصلت!'
        : '${piece.color.label(false)} piece reached home!';
  }

  void _onPlayerFinished(LudoPlayer player) {
    rankings.add(player.color);

    // Check if game is fully over (only 1 player remaining)
    final remaining = players.where((p) => !p.allFinished).toList();
    if (remaining.length <= 1) {
      if (remaining.length == 1) rankings.add(remaining.first.color);
      gameOver.value = true;
      winner.value = rankings.first;
      _sound.playGameWin();
      message.value = isAr
          ? '${player.name} فاز!'
          : '${player.name} wins!';
      Future.delayed(const Duration(seconds: 1), () {
        onGameEnd?.call(rankings.first);
      });
      return;
    }

    // Continue game without this player
    _nextTurn();
  }

  // ── Turn Management ──────────────────────────────────────────────────────

  void _nextTurn() {
    hasRolled.value = false;
    selectedPieceIndex.value = -1;

    // Find next active player
    int next = currentPlayerIndex.value;
    do {
      next = (next + 1) % players.length;
    } while (players[next].allFinished && next != currentPlayerIndex.value);

    currentPlayerIndex.value = next;
    _setTurnMessage();

    if (isCurrentPlayerAi) {
      Future.delayed(const Duration(milliseconds: 800), () => _performRoll());
    }
  }

  void _setTurnMessage() {
    if (gameOver.value) return;
    final name = currentPlayer.name;
    message.value = isAr ? 'دور $name' : "$name's turn";
  }

  // ── AI ────────────────────────────────────────────────────────────────────

  void _aiMove() {
    final movable = _getMovablePieces();
    if (movable.isEmpty) {
      _nextTurn();
      return;
    }

    // AI strategy:
    // 1. Capture if possible
    // 2. Move piece out of yard if rolled 6
    // 3. Move piece closest to home
    // 4. Move piece that's in danger

    LudoPiece? best;

    // Priority 1: Capture
    for (final piece in movable) {
      final targetPos = _simulatePos(piece);
      if (targetPos >= 0 && targetPos < 52 && !LudoBoard.isSafe(targetPos)) {
        for (final player in players) {
          if (player.color == currentPlayer.color) continue;
          for (final other in player.pieces) {
            if (other.isOnTrack && other.position == targetPos) {
              best = piece;
              break;
            }
          }
          if (best != null) break;
        }
      }
      if (best != null) break;
    }

    // Priority 2: Move out of yard
    if (best == null && diceValue.value == 6) {
      best = movable.firstWhereOrNull((p) => p.isInYard);
    }

    // Priority 3: Move piece closest to finishing
    if (best == null) {
      movable.sort((a, b) => b.stepsTaken.compareTo(a.stepsTaken));
      best = movable.first;
    }

    _movePiece(best);
  }

  int _simulatePos(LudoPiece piece) {
    if (piece.isInYard) return piece.color.startPos;
    if (piece.isOnTrack) return (piece.position + diceValue.value) % 52;
    return -1;
  }

  // ── Restart ──────────────────────────────────────────────────────────────

  void restart() {
    for (final p in players) {
      p.reset();
    }
    currentPlayerIndex.value = 0;
    diceValue.value = 0;
    hasRolled.value = false;
    isRolling.value = false;
    isProcessing.value = false;
    selectedPieceIndex.value = -1;
    gameOver.value = false;
    winner.value = null;
    rankings.clear();
    consecutiveSixes.value = 0;
    _setTurnMessage();

    if (isCurrentPlayerAi) {
      Future.delayed(const Duration(milliseconds: 800), () => _performRoll());
    }
  }
}
