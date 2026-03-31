import 'dart:math';
import 'package:get/get.dart';
import '../models/merge_item.dart';
import '../services/storage_service.dart';
import '../services/ads_service.dart';
import '../services/sound_service.dart';
import 'game_controller.dart';

class MergeGameController extends GetxController {
  static const int rows = 9;
  static const int cols = 7;
  static const int totalCells = rows * cols;

  final _gc = Get.find<GameController>();

  // Grid: null = empty cell
  final grid = RxList<MergeItem?>(List.filled(totalCells, null));

  // Selection
  final selectedIndex = (-1).obs;

  // Hint: pair of indices to highlight
  final hintA = (-1).obs;
  final hintB = (-1).obs;
  final hintUsed = false.obs;

  // State
  final score = 0.obs;
  final bestScore = 0.obs;
  final mergeCount = 0.obs;
  final isGameOver = false.obs;
  final isWin = false.obs;

  final _rng = Random();
  final _storage = StorageService();

  // ── Convenience getters (read from shared GameController) ──────────
  int get coins => _gc.coins.value;
  int get lives => _gc.lives.value;

  @override
  void onInit() {
    super.onInit();
    bestScore.value = _storage.read<int>('merge_best') ?? 0;
    _generateInitialGrid();
  }

  // ── Grid helpers ────────────────────────────────────────────────────

  List<int> get emptyCells {
    final result = <int>[];
    for (int i = 0; i < totalCells; i++) {
      if (grid[i] == null) result.add(i);
    }
    return result;
  }

  bool get gridFull => emptyCells.isEmpty;

  // ── Initial setup ──────────────────────────────────────────────────

  void _generateInitialGrid() {
    for (int i = 0; i < totalCells; i++) {
      grid[i] = _randomItem(maxLvl: 2);
    }
    grid.refresh();
  }

  MergeItem _randomItem({int maxLvl = 2}) {
    final cat = MergeItem.categories[_rng.nextInt(MergeItem.categories.length)];
    final lvl = 1 + _rng.nextInt(maxLvl.clamp(1, 3));
    return MergeItem(category: cat, level: lvl);
  }

  // ── Tap / Merge ────────────────────────────────────────────────────

  void onCellTap(int index) {
    if (isGameOver.value) return;
    if (index < 0 || index >= totalCells) return;
    final item = grid[index];

    if (item == null) {
      selectedIndex.value = -1;
      return;
    }

    if (selectedIndex.value < 0) {
      selectedIndex.value = index;
      return;
    }

    if (selectedIndex.value == index) {
      selectedIndex.value = -1;
      return;
    }

    final selectedItem = grid[selectedIndex.value];
    if (selectedItem != null && selectedItem.canMerge(item)) {
      _merge(selectedIndex.value, index);
    } else {
      selectedIndex.value = index;
    }
  }

  final _sound = SoundService();

  void _merge(int fromIdx, int toIdx) {
    final item = grid[fromIdx]!;
    final merged = item.merged();

    grid[fromIdx] = null;
    grid[toIdx] = merged;
    grid.refresh();
    selectedIndex.value = -1;
    _sound.playMerge();

    // Reward coins for merging
    final points = merged.level * 5;
    score.value += points;
    if (_gc.isOnline.value) _gc.addXp(points, source: 'merge');
    _updateBest();

    mergeCount.value++;

    // Show interstitial every 15 merges
    if (mergeCount.value % 15 == 0 && !_gc.isPremium.value) {
      AdsService().showInterstitial();
    }

    _checkWin();
    _checkGameOver();
  }

  // ── Spawn (costs coins) ────────────────────────────────────────────

  int get spawnCost => _gc.spawnCostGems;

  void spawnItem() {
    if (_gc.coins.value < spawnCost || gridFull) return;
    _gc.spendCoins(spawnCost);
    final empty = emptyCells;
    if (empty.isEmpty) return;
    final idx = empty[_rng.nextInt(empty.length)];
    grid[idx] = _randomItem(maxLvl: 2);
    grid.refresh();
    _sound.playSpawn();
    _checkGameOver();
  }

  void spawnMultiple(int count) {
    for (int i = 0; i < count; i++) {
      if (_gc.coins.value < spawnCost || gridFull) break;
      spawnItem();
    }
  }

  // ── Hint ─────────────────────────────────────────────────────────

  void useHint() {
    // Find first mergeable pair
    for (int i = 0; i < totalCells; i++) {
      final a = grid[i];
      if (a == null || a.level >= MergeItem.maxLevel) continue;
      for (int j = i + 1; j < totalCells; j++) {
        final b = grid[j];
        if (b != null && a.canMerge(b)) {
          hintA.value = i;
          hintB.value = j;
          hintUsed.value = true;
          // Auto-clear hint after 3 seconds
          Future.delayed(const Duration(seconds: 3), _clearHint);
          return;
        }
      }
    }
  }

  void _clearHint() {
    hintA.value = -1;
    hintB.value = -1;
  }

  bool isHinted(int index) => index == hintA.value || index == hintB.value;

  // ── Win (grid cleared) ──────────────────────────────────────────

  void _checkWin() {
    // All cells empty → player cleared the board
    for (int i = 0; i < totalCells; i++) {
      if (grid[i] != null) return;
    }
    isWin.value = true;
    isGameOver.value = true;
    _sound.playGameWin();
    final bonus = _gc.mergeWinBonusXp;
    score.value += bonus;
    if (_gc.isOnline.value) _gc.addXp(bonus, source: 'merge_win');
    _updateBest();
  }

  // ── Game Over ────────────────────────────────────────────────────

  void _checkGameOver() {
    if (isWin.value || !gridFull) return;
    // Grid is full — check if any merge is possible
    for (int i = 0; i < totalCells; i++) {
      final a = grid[i];
      if (a == null || a.level >= MergeItem.maxLevel) continue;
      for (int j = i + 1; j < totalCells; j++) {
        final b = grid[j];
        if (b != null && a.canMerge(b)) return; // at least one merge exists
      }
    }
    // No merges possible → game over
    isGameOver.value = true;
    _sound.playGameLose();
    _gc.loseLife();
  }

  // ── Helpers ────────────────────────────────────────────────────────

  void _updateBest() {
    if (score.value > bestScore.value) {
      bestScore.value = score.value;
      _storage.write('merge_best', bestScore.value);
    }
  }

  // ── Restart (costs 1 life) ─────────────────────────────────────────

  void restart() {
    if (_gc.lives.value <= 0) return;
    _gc.loseLife();
    grid.assignAll(List.filled(totalCells, null));
    isGameOver.value = false;
    isWin.value = false;
    score.value = 0;
    mergeCount.value = 0;
    selectedIndex.value = -1;
    hintUsed.value = false;
    _clearHint();
    _generateInitialGrid();
  }
}
