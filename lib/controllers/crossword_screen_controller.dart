import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_service.dart';
import '../services/crossword_data.dart';
import '../services/classic_crossword_data.dart';
import '../services/crossword_generator.dart';

class CrosswordScreenController extends GetxController {
  final String language;
  final int gameId;

  CrosswordScreenController({required this.language, required this.gameId});

  final classicPuzzles = <ClassicCrosswordPuzzle>[].obs;
  final wordSearchCategories = <CrosswordCategory>[].obs;
  final isLoading = true.obs;

  final _api = ApiService();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<bool> _hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<void> loadData() async {
    isLoading.value = true;
    bool apiLoaded = false;

    final online = await _hasInternet();
    if (online) {
      final data = await _api.getCrosswordCategories(gameId, language);
      if (data != null && data.isNotEmpty) {
        _parseCategories(data);
        apiLoaded = true;
      }
    }

    // Fallback to local only if API failed/offline
    if (!apiLoaded) {
      final localWordSearch = CrosswordData.getCategories(language);
      final localClassic = ClassicCrosswordData.getRawPuzzles(language);

      if (localWordSearch.isNotEmpty && wordSearchCategories.isEmpty) {
        wordSearchCategories.value = localWordSearch;
      }
      if (localClassic.isNotEmpty && classicPuzzles.isEmpty) {
        classicPuzzles.value = localClassic.map((raw) =>
          CrosswordGenerator.generate(
            id: raw.id,
            name: raw.name,
            emoji: raw.emoji,
            clues: raw.clues.map((c) => {'answer': c.answer, 'clue': c.clue}).toList(),
            rtl: language == 'ar',
          ),
        ).toList();
      }
    }

    isLoading.value = false;
  }

  void _parseCategories(List<Map<String, dynamic>> data) {
    final classic = <ClassicCrosswordPuzzle>[];
    final wordSearch = <CrosswordCategory>[];

    for (final j in data) {
      final meta = j['metadata'] is Map
          ? Map<String, dynamic>.from(j['metadata'] as Map)
          : <String, dynamic>{};

      if (meta.containsKey('clues')) {
        // Classic crossword — auto-generate grid from clues
        final clues = (meta['clues'] as List?)?.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return {'answer': m['answer'] as String? ?? '', 'clue': m['clue'] as String? ?? ''};
        }).toList() ?? [];

        final puzzle = CrosswordGenerator.generate(
          id: j['answer'] as String? ?? '${j['id']}',
          name: meta['name'] as String? ?? j['question'] as String? ?? '',
          emoji: meta['emoji'] as String? ?? '',
          clues: clues,
          rtl: language == 'ar',
        );
        classic.add(puzzle);
      } else if (meta.containsKey('words')) {
        wordSearch.add(CrosswordCategory(
          id: j['answer'] as String? ?? '${j['id']}',
          name: meta['name'] as String? ?? j['question'] as String? ?? '',
          emoji: meta['emoji'] as String? ?? '',
          words: List<String>.from(meta['words'] ?? []),
        ));
      }
    }

    if (classic.isNotEmpty) classicPuzzles.value = classic;
    if (wordSearch.isNotEmpty) wordSearchCategories.value = wordSearch;
  }
}
