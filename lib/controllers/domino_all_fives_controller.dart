import 'dart:math';
import 'package:get/get.dart';
import 'domino_game_controller.dart';
import '../services/sound_service.dart';

/// All Fives (Muggins) domino game controller.
///
/// Scoring rules:
/// - No scoring until all 4 sides of the spinner have at least one tile.
/// - After that, when the sum of open ends is a multiple of 5, the scorer
///   gets (sum / 5) points (every 5 = 1 point).
/// - First double played is the spinner (opens 4 directions).
/// - Top/bottom branches open after both left and right have at least 1 tile.
/// - Round ends when a player empties hand or game is blocked.
/// - Round winner gets opponents remaining pips / 5.
/// - First to [targetScore] wins the match.
class DominoAllFivesController extends GetxController {
  final String language;
  final Function(bool won) onGameEnd;
  static const int targetScore = 50;

  DominoAllFivesController({required this.language, required this.onGameEnd});

  // ── Chains (for UI display) ────────────────────────────────────────────────
  final spinnerTile = Rxn<DominoTile>();
  final leftChain = <DominoTile>[].obs;   // tiles going left from spinner (outward order)
  final rightChain = <DominoTile>[].obs;  // tiles going right from spinner (outward order)
  final topChain = <DominoTile>[].obs;    // tiles going up from spinner (outward order)
  final bottomChain = <DominoTile>[].obs; // tiles going down from spinner (outward order)

  // ── Hands & boneyard ───────────────────────────────────────────────────────
  final playerHand = <DominoTile>[].obs;
  final aiHand = <DominoTile>[].obs;
  final boneyard = <DominoTile>[].obs;

  // ── Open end values ────────────────────────────────────────────────────────
  final leftEnd = 0.obs;
  final rightEnd = 0.obs;
  final topEnd = Rxn<int>();
  final bottomEnd = Rxn<int>();
  final spinnerValue = Rxn<int>();

  /// Whether top/bottom are open (left AND right each have >= 1 tile).
  bool get topBottomOpen => leftChain.isNotEmpty && rightChain.isNotEmpty;

  /// Whether all four sides of the spinner have at least one tile.
  /// Scoring only begins after this is true.
  bool get allFourSidesPlayed =>
      leftChain.isNotEmpty &&
      rightChain.isNotEmpty &&
      topChain.isNotEmpty &&
      bottomChain.isNotEmpty;

  int get totalTilesOnBoard =>
      (spinnerTile.value != null ? 1 : 0) +
      leftChain.length + rightChain.length +
      topChain.length + bottomChain.length;

  // ── Scoring ────────────────────────────────────────────────────────────────
  final playerScore = 0.obs;
  final aiScore = 0.obs;
  final playerRoundScore = 0.obs;
  final aiRoundScore = 0.obs;
  final lastScoringPlay = ''.obs;

  // ── State ──────────────────────────────────────────────────────────────────
  final selectedTile = Rxn<DominoTile>();
  final gameState = GameState.playing.obs;
  final turnState = TurnState.playerTurn.obs;
  final message = ''.obs;
  final isProcessing = false.obs;
  final hintUsed = false.obs;
  final hintTile = Rxn<DominoTile>();
  final _sound = SoundService();
  final roundNumber = 1.obs;
  final matchOver = false.obs;
  final playerDrawCount = 0.obs;
  static const int maxDrawsPerTurn = 2;

  @override
  void onInit() {
    super.onInit();
    _startRound();
  }

  // ── Round setup ────────────────────────────────────────────────────────────

  void _startRound() {
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

    spinnerTile.value = null;
    leftChain.clear();
    rightChain.clear();
    topChain.clear();
    bottomChain.clear();
    leftEnd.value = 0;
    rightEnd.value = 0;
    topEnd.value = null;
    bottomEnd.value = null;
    spinnerValue.value = null;

    selectedTile.value = null;
    gameState.value = GameState.playing;
    message.value = '';
    isProcessing.value = false;
    playerRoundScore.value = 0;
    aiRoundScore.value = 0;
    lastScoringPlay.value = '';

    // Highest double starts
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

      // Place spinner
      spinnerTile.value = startTile;
      spinnerValue.value = startTile.left;
      leftEnd.value = startTile.left;
      rightEnd.value = startTile.right;

      // No scoring until all four sides are played
      turnState.value = playerStarts ? TurnState.playerTurn : TurnState.aiTurn;
      if (turnState.value == TurnState.aiTurn) {
        _setMessage(true);
        isProcessing.value = true;
        Future.delayed(const Duration(milliseconds: 800), () => _aiPlay());
      } else {
        _setMessage(false);
      }
    } else {
      turnState.value = TurnState.playerTurn;
      _setMessage(false);
    }
  }

  // ── Open ends sum ──────────────────────────────────────────────────────────

  int calculateOpenEndsSum() {
    if (spinnerTile.value == null) return 0;
    final sv = spinnerValue.value!;

    // Only spinner on board
    if (leftChain.isEmpty && rightChain.isEmpty && topChain.isEmpty && bottomChain.isEmpty) {
      return sv * 2;
    }

    int sum = 0;

    // Helper: doubles count both sides (e.g. 6-6 = 12)
    int endValue(List<DominoTile> chain, int endVal) {
      final lastTile = chain.last;
      return lastTile.isDouble ? endVal * 2 : endVal;
    }

    // Each direction: if has tiles, count the open end; if empty, count spinner value
    sum += leftChain.isNotEmpty ? endValue(leftChain, leftEnd.value) : sv;
    sum += rightChain.isNotEmpty ? endValue(rightChain, rightEnd.value) : sv;

    if (allFourSidesPlayed) {
      sum += topChain.isNotEmpty ? endValue(topChain, topEnd.value!) : sv;
      sum += bottomChain.isNotEmpty ? endValue(bottomChain, bottomEnd.value!) : sv;
    } else {
      // Before all 4 sides filled, only count sides that have tiles
      if (topChain.isNotEmpty) sum += endValue(topChain, topEnd.value!);
      if (bottomChain.isNotEmpty) sum += endValue(bottomChain, bottomEnd.value!);
    }

    return sum;
  }

  // ── Playable ends ──────────────────────────────────────────────────────────

  List<String> getPlayableEnds(DominoTile tile) {
    if (spinnerTile.value == null) return ['left']; // first tile
    final ends = <String>[];
    final sv = spinnerValue.value!;

    if (!allFourSidesPlayed) {
      // Phase 1: Must fill all 4 sides of the spinner first.
      // Only allow playing on EMPTY sides, matching the spinner value.
      if (leftChain.isEmpty && tile.canMatch(sv)) ends.add('left');
      if (rightChain.isEmpty && tile.canMatch(sv)) ends.add('right');
      if (topChain.isEmpty && tile.canMatch(sv)) ends.add('top');
      if (bottomChain.isEmpty && tile.canMatch(sv)) ends.add('bottom');
      return ends;
    }

    // Phase 2: All 4 sides filled — play on any open end
    if (tile.canMatch(leftEnd.value)) ends.add('left');
    if (tile.canMatch(rightEnd.value)) ends.add('right');
    if (tile.canMatch(topEnd.value!)) ends.add('top');
    if (tile.canMatch(bottomEnd.value!)) ends.add('bottom');

    return ends;
  }

  bool _hasPlayable(List<DominoTile> hand) {
    if (spinnerTile.value == null) return hand.isNotEmpty;
    return hand.any((t) => getPlayableEnds(t).isNotEmpty);
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  void _setMessage(bool isAi) {
    if (gameState.value != GameState.playing) return;
    if (isAi) {
      message.value = language == 'ar' ? '\u062f\u0648\u0631 \u0627\u0644\u062e\u0635\u0645...' : 'Opponent thinking...';
    } else {
      message.value = language == 'ar' ? '\u062f\u0648\u0631\u0643! \u0627\u062e\u062a\u0631 \u0642\u0637\u0639\u0629' : 'Your turn! Pick a tile';
    }
  }

  /// Highlight the best scoring tile to play.
  void useHint() {
    if (hintUsed.value || gameState.value != GameState.playing) return;
    hintUsed.value = true;
    for (final tile in playerHand) {
      if (getPlayableEnds(tile).isNotEmpty) {
        hintTile.value = tile;
        return;
      }
    }
  }

  // ── Player actions ─────────────────────────────────────────────────────────

  void selectTile(DominoTile tile) {
    if (turnState.value != TurnState.playerTurn || isProcessing.value) return;
    if (gameState.value != GameState.playing) return;
    selectedTile.value = selectedTile.value == tile ? null : tile;
  }

  void playTile(String end) {
    final tile = selectedTile.value;
    if (tile == null || turnState.value != TurnState.playerTurn) return;
    if (gameState.value != GameState.playing) return;

    _placeTile(tile, end, playerHand);
    _sound.playTilePlace();

    final openSum = calculateOpenEndsSum();
    if (openSum > 0 && openSum % 5 == 0) {
      final points = openSum ~/ 5;
      playerRoundScore.value += points;
      playerScore.value += points;
      _sound.playReward();
      lastScoringPlay.value = language == 'ar' ? '\u0623\u0646\u062a: +$points' : 'You: +$points';
    }

    selectedTile.value = null;
    playerDrawCount.value = 0;
    if (_checkRoundEnd()) return;
    if (_checkMatchEnd()) return;

    turnState.value = TurnState.aiTurn;
    _setMessage(true);
    isProcessing.value = true;
    Future.delayed(const Duration(milliseconds: 800), () => _aiPlay());
  }

  void drawTile() {
    if (turnState.value != TurnState.playerTurn || isProcessing.value) return;
    if (gameState.value != GameState.playing) return;

    if (_hasPlayable(playerHand)) {
      message.value = language == 'ar'
          ? '\u0644\u062f\u064a\u0643 \u0642\u0637\u0639\u0629 \u064a\u0645\u0643\u0646 \u0644\u0639\u0628\u0647\u0627!'
          : 'You have a playable tile!';
      return;
    }

    if (boneyard.isEmpty || playerDrawCount.value >= maxDrawsPerTurn) {
      message.value = language == 'ar'
          ? '\u0644\u0627 \u064a\u0645\u0643\u0646\u0643 \u0627\u0644\u0633\u062d\u0628\u060c \u062a\u0645 \u0627\u0644\u062a\u0645\u0631\u064a\u0631'
          : 'No more draws, passing...';
      playerDrawCount.value = 0;
      turnState.value = TurnState.aiTurn;
      _setMessage(true);
      isProcessing.value = true;
      Future.delayed(const Duration(milliseconds: 800), () => _aiPlay());
      return;
    }

    final drawn = boneyard.removeAt(0);
    playerHand.add(drawn);
    playerDrawCount.value++;
    _sound.playClick();
    playerHand.refresh();
    boneyard.refresh();
  }

  // ── Place tile ─────────────────────────────────────────────────────────────

  void _placeTile(DominoTile tile, String end, RxList<DominoTile> hand) {
    hand.remove(tile);

    // First tile = spinner (must be a double)
    if (spinnerTile.value == null) {
      spinnerTile.value = tile;
      spinnerValue.value = tile.left; // doubles: left == right
      leftEnd.value = tile.left;
      rightEnd.value = tile.right;
      return;
    }

    switch (end) {
      case 'left':
        // Left chain: tiles go outward to the left.
        // Rendered horizontally [left|right] — right side connects inward.
        final matchValL = leftEnd.value;
        if (!tile.canMatch(matchValL)) return;
        final outwardL = tile.otherSide(matchValL);
        // Orient so right == matchVal (connecting side faces spinner)
        final orientedL = tile.right == matchValL
            ? tile
            : DominoTile(tile.right, tile.left);
        leftChain.add(orientedL);
        leftEnd.value = outwardL;
        break;

      case 'right':
        // Right chain: tiles go outward to the right.
        // Rendered horizontally [left|right] — left side connects inward.
        final matchValR = rightEnd.value;
        if (!tile.canMatch(matchValR)) return;
        final outwardR = tile.otherSide(matchValR);
        // Orient so left == matchVal (connecting side faces spinner)
        final orientedR = tile.left == matchValR
            ? tile
            : DominoTile(tile.right, tile.left);
        rightChain.add(orientedR);
        rightEnd.value = outwardR;
        break;

      case 'top':
        // Top chain: tiles go upward. Rendered vertically (left=top, right=bottom).
        // Bottom (right) connects inward toward spinner, top (left) faces outward.
        final matchValT = topChain.isNotEmpty ? topEnd.value! : spinnerValue.value!;
        if (!tile.canMatch(matchValT)) return;
        final outwardT = tile.otherSide(matchValT);
        // Orient so right == matchVal (bottom connects to spinner/prev)
        final orientedT = tile.right == matchValT
            ? tile
            : DominoTile(tile.right, tile.left);
        topChain.add(orientedT);
        topEnd.value = outwardT;
        break;

      case 'bottom':
        // Bottom chain: tiles go downward. Rendered vertically (left=top, right=bottom).
        // Top (left) connects inward toward spinner, bottom (right) faces outward.
        final matchValB = bottomChain.isNotEmpty ? bottomEnd.value! : spinnerValue.value!;
        if (!tile.canMatch(matchValB)) return;
        final outwardB = tile.otherSide(matchValB);
        // Orient so left == matchVal (top connects to spinner/prev)
        final orientedB = tile.left == matchValB
            ? tile
            : DominoTile(tile.right, tile.left);
        bottomChain.add(orientedB);
        bottomEnd.value = outwardB;
        break;
    }
  }

  // ── AI ─────────────────────────────────────────────────────────────────────

  void _aiPlay() {
    if (gameState.value != GameState.playing) {
      isProcessing.value = false;
      return;
    }

    DominoTile? bestTile;
    String bestEnd = 'right';
    int bestScore = -1;

    final sorted = [...aiHand]..sort((a, b) => b.totalDots.compareTo(a.totalDots));

    for (final tile in sorted) {
      final ends = getPlayableEnds(tile);
      for (final end in ends) {
        final simScore = _simulateScore(tile, end);
        if (simScore > bestScore || (simScore == bestScore && bestTile == null)) {
          bestScore = simScore;
          bestTile = tile;
          bestEnd = end;
        }
      }
    }

    if (bestTile != null) {
      _placeTile(bestTile, bestEnd, aiHand);
      _sound.playTilePlace();

      final openSum = calculateOpenEndsSum();
      if (openSum > 0 && openSum % 5 == 0) {
        final points = openSum ~/ 5;
        aiRoundScore.value += points;
        aiScore.value += points;
        lastScoringPlay.value = language == 'ar' ? '\u0627\u0644\u062e\u0635\u0645: +$points' : 'AI: +$points';
      }

      _afterAiTurn();
      return;
    }

    // Can't play - draw up to 2 tiles
    int aiDraws = 0;
    while (boneyard.isNotEmpty && aiDraws < maxDrawsPerTurn) {
      final drawn = boneyard.removeAt(0);
      aiHand.add(drawn);
      aiDraws++;
      aiHand.refresh();
      boneyard.refresh();

      final ends = getPlayableEnds(drawn);
      if (ends.isNotEmpty) {
        String playEnd = ends.first;
        int best = -1;
        for (final e in ends) {
          final s = _simulateScore(drawn, e);
          if (s > best) {
            best = s;
            playEnd = e;
          }
        }
        _placeTile(drawn, playEnd, aiHand);

        final openSum = calculateOpenEndsSum();
        if (openSum > 0 && openSum % 5 == 0) {
          final points = openSum ~/ 5;
          aiRoundScore.value += points;
          aiScore.value += points;
          lastScoringPlay.value = language == 'ar' ? '\u0627\u0644\u062e\u0635\u0645: +$points' : 'AI: +$points';
        }
        break; // played the drawn tile, stop drawing
      }
    }

    _afterAiTurn();
  }

  /// Simulate placing a tile and return the score — WITHOUT modifying reactive state.
  int _simulateScore(DominoTile tile, String end) {
    final sv = spinnerValue.value!;

    // Calculate what the end values would be after placement
    int simLeft = leftEnd.value;
    int simRight = rightEnd.value;
    int? simTop = topEnd.value;
    int? simBot = bottomEnd.value;
    int simLeftLen = leftChain.length;
    int simRightLen = rightChain.length;
    int simTopLen = topChain.length;
    int simBotLen = bottomChain.length;
    bool simIsDouble = false;

    switch (end) {
      case 'left':
        final outward = tile.otherSide(simLeft);
        simLeft = outward;
        simLeftLen++;
        simIsDouble = tile.isDouble;
        break;
      case 'right':
        final outward = tile.otherSide(simRight);
        simRight = outward;
        simRightLen++;
        simIsDouble = tile.isDouble;
        break;
      case 'top':
        final matchVal = simTopLen > 0 ? simTop! : sv;
        simTop = tile.otherSide(matchVal);
        simTopLen++;
        simIsDouble = tile.isDouble;
        break;
      case 'bottom':
        final matchVal = simBotLen > 0 ? simBot! : sv;
        simBot = tile.otherSide(matchVal);
        simBotLen++;
        simIsDouble = tile.isDouble;
        break;
    }

    // Calculate open ends sum
    int sum = 0;
    final allFour = simLeftLen > 0 && simRightLen > 0 && simTopLen > 0 && simBotLen > 0;

    // Helper: if the last tile on that end is a double, count value * 2
    int endVal(int val, String dir) {
      if (dir == end && simIsDouble) return val * 2;
      // For existing chains, check if last tile is double
      List<DominoTile> chain;
      switch (dir) {
        case 'left': chain = leftChain; break;
        case 'right': chain = rightChain; break;
        case 'top': chain = topChain; break;
        case 'bottom': chain = bottomChain; break;
        default: return val;
      }
      if (dir != end && chain.isNotEmpty && chain.last.isDouble) return val * 2;
      return val;
    }

    sum += simLeftLen > 0 ? endVal(simLeft, 'left') : sv;
    sum += simRightLen > 0 ? endVal(simRight, 'right') : sv;
    if (allFour) {
      sum += endVal(simTop!, 'top');
      sum += endVal(simBot!, 'bottom');
    } else {
      if (simTopLen > 0) sum += endVal(simTop!, 'top');
      if (simBotLen > 0) sum += endVal(simBot!, 'bottom');
    }

    return (sum > 0 && sum % 5 == 0) ? sum ~/ 5 : 0;
  }

  void _afterAiTurn() {
    isProcessing.value = false;
    if (_checkRoundEnd()) return;
    if (_checkMatchEnd()) return;
    turnState.value = TurnState.playerTurn;
    _setMessage(false);
  }

  // ── Round / match end ──────────────────────────────────────────────────────

  bool _checkRoundEnd() {
    bool roundOver = false;
    bool playerWonRound = false;

    if (playerHand.isEmpty) {
      roundOver = true;
      playerWonRound = true;
    } else if (aiHand.isEmpty) {
      roundOver = true;
      playerWonRound = false;
    } else if (boneyard.isEmpty && !_hasPlayable(playerHand) && !_hasPlayable(aiHand)) {
      roundOver = true;
      final playerDots = playerHand.fold<int>(0, (s, t) => s + t.totalDots);
      final aiDots = aiHand.fold<int>(0, (s, t) => s + t.totalDots);
      playerWonRound = playerDots <= aiDots;
    }

    if (!roundOver) return false;

    final loserPips = playerWonRound
        ? aiHand.fold<int>(0, (s, t) => s + t.totalDots)
        : playerHand.fold<int>(0, (s, t) => s + t.totalDots);
    final bonus = loserPips ~/ 5;

    if (playerWonRound) {
      // Deduct opponent's remaining pips/5 from their score
      aiScore.value = (aiScore.value - bonus).clamp(0, aiScore.value);
    } else {
      aiScore.value += bonus;
    }

    if (_checkMatchEnd()) return true;

    gameState.value = GameState.playing;
    final isAr = language == 'ar';
    message.value = playerWonRound
        ? (isAr ? '\u0641\u0632\u062a \u0628\u0627\u0644\u062c\u0648\u0644\u0629! +$bonus \u0646\u0642\u0637\u0629' : 'Round won! +$bonus pts')
        : (isAr ? '\u0627\u0644\u062e\u0635\u0645 \u0641\u0627\u0632 \u0628\u0627\u0644\u062c\u0648\u0644\u0629! +$bonus \u0646\u0642\u0637\u0629' : 'AI won round! +$bonus pts');

    Future.delayed(const Duration(seconds: 2), () {
      roundNumber.value++;
      _startRound();
    });

    return true;
  }

  bool _checkMatchEnd() {
    if (playerScore.value >= targetScore) {
      gameState.value = GameState.playerWon;
      matchOver.value = true;
      _sound.playGameWin();
      message.value = language == 'ar'
          ? '\u0641\u0632\u062a \u0628\u0627\u0644\u0645\u0628\u0627\u0631\u0627\u0629! ${playerScore.value} \u0646\u0642\u0637\u0629'
          : 'You win the match! ${playerScore.value} pts';
      Future.delayed(const Duration(seconds: 1), () => onGameEnd(true));
      return true;
    }
    if (aiScore.value >= targetScore) {
      gameState.value = GameState.aiWon;
      matchOver.value = true;
      _sound.playGameLose();
      message.value = language == 'ar'
          ? '\u0627\u0644\u062e\u0635\u0645 \u0641\u0627\u0632 \u0628\u0627\u0644\u0645\u0628\u0627\u0631\u0627\u0629! ${aiScore.value} \u0646\u0642\u0637\u0629'
          : 'AI wins the match! ${aiScore.value} pts';
      Future.delayed(const Duration(seconds: 1), () => onGameEnd(false));
      return true;
    }
    return false;
  }

  void restart() {
    playerScore.value = 0;
    aiScore.value = 0;
    roundNumber.value = 1;
    matchOver.value = false;
    _startRound();
  }
}
