import 'dart:math';
import 'package:flutter/material.dart' show Color;
import 'package:get/get.dart';
import '../services/sound_service.dart';
import 'game_controller.dart';

enum SnakesLaddersMode { vsAi, local2, local3, local4 }

class SnakesLaddersPlayer {
  final String name;
  final Color color;
  final bool isAi;
  int position; // 0 = off board, 1-100 = on board

  SnakesLaddersPlayer({
    required this.name,
    required this.color,
    this.isAi = false,
    this.position = 0,
  });

  void reset() => position = 0;
}

class SnakesLaddersController extends GetxController {
  final SnakesLaddersMode mode;
  final String language;
  final Function(int winnerIndex)? onGameEnd;

  SnakesLaddersController({
    required this.mode,
    required this.language,
    this.onGameEnd,
  });

  final players = <SnakesLaddersPlayer>[].obs;
  final currentPlayerIndex = 0.obs;
  final diceValue = 0.obs;
  final hasRolled = false.obs;
  final isRolling = false.obs;
  final isMoving = false.obs;
  final message = ''.obs;
  final gameOver = false.obs;
  final winnerIndex = (-1).obs;

  final _rng = Random();
  final _sound = SoundService();
  bool get isAr => language == 'ar';

  SnakesLaddersPlayer get currentPlayer => players[currentPlayerIndex.value];
  bool get isCurrentPlayerAi => currentPlayer.isAi;

  // Snakes: head -> tail (go down)
  static const Map<int, int> snakes = {
    98: 78,
    95: 56,
    93: 73,
    87: 36,
    64: 60,
    62: 19,
    54: 34,
    17: 7,
  };

  // Ladders: bottom -> top (go up)
  static const Map<int, int> ladders = {
    2: 38,
    4: 14,
    8: 31,
    21: 42,
    28: 84,
    36: 44,
    51: 67,
    71: 91,
    80: 100,
  };

  @override
  void onInit() {
    super.onInit();
    _setupPlayers();
    _setTurnMessage();
  }

  void _setupPlayers() {
    final gc = Get.find<GameController>();
    final playerName = gc.playerName.value.isNotEmpty
        ? gc.playerName.value
        : (isAr ? 'أنت' : 'You');

    const colors = [Color(0xFFE74C3C), Color(0xFF3498DB), Color(0xFF2ECC71), Color(0xFFF39C12)];
    final arNames = [playerName, 'لاعب 2', 'لاعب 3', 'لاعب 4'];
    final enNames = [playerName, 'Player 2', 'Player 3', 'Player 4'];

    int count;
    switch (mode) {
      case SnakesLaddersMode.vsAi:
        count = 2;
        break;
      case SnakesLaddersMode.local2:
        count = 2;
        break;
      case SnakesLaddersMode.local3:
        count = 3;
        break;
      case SnakesLaddersMode.local4:
        count = 4;
        break;
    }

    for (int i = 0; i < count; i++) {
      players.add(SnakesLaddersPlayer(
        name: isAr ? arNames[i] : enNames[i],
        color: colors[i],
        isAi: mode == SnakesLaddersMode.vsAi && i > 0,
      ));
    }
  }

  void rollDice() {
    if (hasRolled.value || isRolling.value || isMoving.value || gameOver.value) return;
    if (isCurrentPlayerAi) return;

    _sound.playClick();
    _performRoll();
  }

  void _performRoll() {
    isRolling.value = true;
    diceValue.value = 0;
    _sound.playDiceRoll();

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
      _afterRoll();
    });
  }

  void _afterRoll() {
    final dice = diceValue.value;
    final player = currentPlayer;
    final currentPos = player.position;
    final newPos = currentPos + dice;

    if (newPos > 100) {
      message.value = isAr ? 'الرقم أكبر من المطلوب!' : 'Roll too high!';
      Future.delayed(const Duration(milliseconds: 800), _nextTurn);
      return;
    }

    _movePlayer(newPos);
  }

  void _movePlayer(int targetPos) async {
    isMoving.value = true;
    final player = currentPlayer;
    final startPos = player.position;

    // Animate step by step
    for (int pos = startPos + 1; pos <= targetPos; pos++) {
      player.position = pos;
      players.refresh();
      _sound.playPieceMove();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Check win
    if (player.position == 100) {
      _declareWinner();
      return;
    }

    // Check snake
    if (snakes.containsKey(player.position)) {
      final snakeTo = snakes[player.position]!;
      message.value = isAr
          ? 'ثعبان! نزلت من ${player.position} إلى $snakeTo'
          : 'Snake! Slid down from ${player.position} to $snakeTo';
      await Future.delayed(const Duration(milliseconds: 500));
      player.position = snakeTo;
      players.refresh();
      _sound.playWrong();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    // Check ladder
    else if (ladders.containsKey(player.position)) {
      final ladderTo = ladders[player.position]!;
      message.value = isAr
          ? 'سلم! صعدت من ${player.position} إلى $ladderTo'
          : 'Ladder! Climbed from ${player.position} to $ladderTo';
      await Future.delayed(const Duration(milliseconds: 500));
      player.position = ladderTo;
      players.refresh();
      _sound.playCorrect();
      await Future.delayed(const Duration(milliseconds: 300));

      // Check win after ladder
      if (player.position == 100) {
        _declareWinner();
        return;
      }
    }

    isMoving.value = false;

    // Roll again on 6
    if (diceValue.value == 6) {
      hasRolled.value = false;
      message.value = isAr ? 'رميت 6! ارمِ مرة أخرى' : 'Rolled 6! Roll again';
      if (isCurrentPlayerAi) {
        Future.delayed(const Duration(milliseconds: 800), _performRoll);
      }
      return;
    }

    _nextTurn();
  }

  void _declareWinner() {
    final player = currentPlayer;
    gameOver.value = true;
    winnerIndex.value = currentPlayerIndex.value;
    _sound.playPieceFinish();
    final isPlayerWin = mode == SnakesLaddersMode.vsAi
        ? currentPlayerIndex.value == 0
        : true;
    if (isPlayerWin) {
      _sound.playGameWin();
    } else {
      _sound.playGameLose();
    }
    message.value = isAr
        ? '${player.name} فاز!'
        : '${player.name} wins!';
    isMoving.value = false;
    Future.delayed(const Duration(seconds: 1), () {
      onGameEnd?.call(currentPlayerIndex.value);
    });
  }

  void _nextTurn() {
    hasRolled.value = false;
    currentPlayerIndex.value = (currentPlayerIndex.value + 1) % players.length;
    _setTurnMessage();

    if (isCurrentPlayerAi) {
      Future.delayed(const Duration(milliseconds: 800), _performRoll);
    }
  }

  void _setTurnMessage() {
    if (gameOver.value) return;
    final name = currentPlayer.name;
    message.value = isAr ? 'دور $name' : "$name's turn";
  }

  void restart() {
    for (final p in players) {
      p.reset();
    }
    currentPlayerIndex.value = 0;
    diceValue.value = 0;
    hasRolled.value = false;
    isRolling.value = false;
    isMoving.value = false;
    gameOver.value = false;
    winnerIndex.value = -1;
    message.value = '';
    _setTurnMessage();

    if (isCurrentPlayerAi) {
      Future.delayed(const Duration(milliseconds: 800), _performRoll);
    }
  }
}
