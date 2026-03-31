/// A single placed word in the crossword grid (with computed position)
class CrosswordEntry {
  final int number;
  final String direction; // 'across' or 'down'
  final int row;
  final int col;
  final String answer;
  final String clue;

  const CrosswordEntry({
    required this.number,
    required this.direction,
    required this.row,
    required this.col,
    required this.answer,
    required this.clue,
  });

  int get length => answer.length;
}

/// A complete crossword puzzle
class ClassicCrosswordPuzzle {
  final String id;
  final String name;
  final String emoji;
  final int gridRows;
  final int gridCols;
  final List<CrosswordEntry> entries;

  const ClassicCrosswordPuzzle({
    required this.id,
    required this.name,
    required this.emoji,
    required this.gridRows,
    required this.gridCols,
    required this.entries,
  });

  List<CrosswordEntry> get across =>
      entries.where((e) => e.direction == 'across').toList()..sort((a, b) => a.number.compareTo(b.number));

  List<CrosswordEntry> get down =>
      entries.where((e) => e.direction == 'down').toList()..sort((a, b) => a.number.compareTo(b.number));

  Map<String, String> activeCells({bool rtlAcross = false}) {
    final map = <String, String>{};
    for (final e in entries) {
      for (int i = 0; i < e.length; i++) {
        final r = e.direction == 'down' ? e.row + i : e.row;
        final c = e.direction == 'across'
            ? (rtlAcross ? e.col - i : e.col + i)
            : e.col;
        map['$r,$c'] = e.answer[i];
      }
    }
    return map;
  }

  Map<String, int> get cellNumbers {
    final map = <String, int>{};
    for (final e in entries) {
      final key = '${e.row},${e.col}';
      if (!map.containsKey(key) || e.number < map[key]!) {
        map[key] = e.number;
      }
    }
    return map;
  }
}

/// Raw clue data (answer + clue text only, no position)
class RawClue {
  final String answer;
  final String clue;

  const RawClue({required this.answer, required this.clue});
}

/// Raw puzzle data — just clues, no grid positions.
/// The generator will compute positions at runtime.
class RawPuzzle {
  final String id;
  final String name;
  final String emoji;
  final List<RawClue> clues;

  const RawPuzzle({required this.id, required this.name, required this.emoji, required this.clues});
}

class ClassicCrosswordData {
  static List<RawPuzzle> getRawPuzzles(String language) {
    return language == 'ar' ? _rawPuzzlesAr : _rawPuzzlesEn;
  }

  static const List<RawPuzzle> _rawPuzzlesEn = [
    RawPuzzle(id: 'animals_1', name: 'Animals', emoji: '🦁', clues: [
      RawClue(answer: 'TIGER', clue: 'Striped big cat'),
      RawClue(answer: 'OWL', clue: 'Night bird'),
      RawClue(answer: 'LION', clue: 'King of the jungle'),
      RawClue(answer: 'EAGLE', clue: 'Large bird of prey'),
      RawClue(answer: 'SHARK', clue: 'Ocean predator'),
      RawClue(answer: 'WHALE', clue: 'Largest mammal'),
      RawClue(answer: 'BEAR', clue: 'Hibernates in winter'),
      RawClue(answer: 'SNAKE', clue: 'Legless reptile'),
      RawClue(answer: 'HORSE', clue: 'Animal for riding'),
    ]),
    RawPuzzle(id: 'food_1', name: 'Food & Drinks', emoji: '🍕', clues: [
      RawClue(answer: 'PIZZA', clue: 'Italian flat bread with toppings'),
      RawClue(answer: 'RICE', clue: 'Asian staple grain'),
      RawClue(answer: 'MILK', clue: 'White drink from cows'),
      RawClue(answer: 'BREAD', clue: 'Baked from flour'),
      RawClue(answer: 'CAKE', clue: 'Sweet birthday treat'),
      RawClue(answer: 'HONEY', clue: 'Sweet golden liquid from bees'),
      RawClue(answer: 'PASTA', clue: 'Italian noodle dish'),
      RawClue(answer: 'STEAK', clue: 'Grilled beef'),
    ]),
    RawPuzzle(id: 'countries_1', name: 'Countries', emoji: '🌍', clues: [
      RawClue(answer: 'EGYPT', clue: 'Land of the pyramids'),
      RawClue(answer: 'JAPAN', clue: 'Land of the rising sun'),
      RawClue(answer: 'FRANCE', clue: 'Eiffel Tower country'),
      RawClue(answer: 'CHINA', clue: 'Great Wall country'),
      RawClue(answer: 'BRAZIL', clue: 'Largest South American country'),
      RawClue(answer: 'INDIA', clue: 'Taj Mahal country'),
      RawClue(answer: 'ITALY', clue: 'Boot-shaped country'),
      RawClue(answer: 'SPAIN', clue: 'Flamenco country'),
    ]),
    RawPuzzle(id: 'science_1', name: 'Science', emoji: '🔬', clues: [
      RawClue(answer: 'ATOM', clue: 'Smallest unit of matter'),
      RawClue(answer: 'MOON', clue: "Earth's natural satellite"),
      RawClue(answer: 'STAR', clue: 'The sun is one'),
      RawClue(answer: 'FORCE', clue: 'Push or pull'),
      RawClue(answer: 'LIGHT', clue: 'Fastest thing in the universe'),
      RawClue(answer: 'CELL', clue: 'Basic unit of life'),
      RawClue(answer: 'HEAT', clue: 'Form of energy'),
      RawClue(answer: 'ORBIT', clue: 'Path around a planet'),
    ]),
    RawPuzzle(id: 'sports_1', name: 'Sports', emoji: '⚽', clues: [
      RawClue(answer: 'GOAL', clue: 'Score in football'),
      RawClue(answer: 'GOLF', clue: 'Sport with clubs and holes'),
      RawClue(answer: 'SWIM', clue: 'Move in water'),
      RawClue(answer: 'TENNIS', clue: 'Racket sport'),
      RawClue(answer: 'BOXING', clue: 'Fighting with gloves'),
      RawClue(answer: 'DIVING', clue: 'Jumping into pool from height'),
      RawClue(answer: 'JUDO', clue: 'Japanese martial art'),
      RawClue(answer: 'YOGA', clue: 'Stretching and breathing'),
    ]),
    RawPuzzle(id: 'school_1', name: 'School', emoji: '📚', clues: [
      RawClue(answer: 'BOOK', clue: 'You read this'),
      RawClue(answer: 'DESK', clue: 'You sit at this'),
      RawClue(answer: 'MATH', clue: 'Numbers subject'),
      RawClue(answer: 'EXAM', clue: 'End of year test'),
      RawClue(answer: 'CHALK', clue: 'Write on blackboard with this'),
      RawClue(answer: 'RULER', clue: 'Measures length'),
      RawClue(answer: 'CLASS', clue: 'Room where you learn'),
      RawClue(answer: 'PEN', clue: 'Writing tool with ink'),
    ]),
    RawPuzzle(id: 'weather_1', name: 'Weather', emoji: '🌤️', clues: [
      RawClue(answer: 'CLOUD', clue: 'White fluffy thing in sky'),
      RawClue(answer: 'STORM', clue: 'Heavy rain and wind'),
      RawClue(answer: 'SNOW', clue: 'Frozen white flakes'),
      RawClue(answer: 'RAIN', clue: 'Water from clouds'),
      RawClue(answer: 'SUNNY', clue: 'Bright warm day'),
      RawClue(answer: 'WIND', clue: 'Moving air'),
      RawClue(answer: 'COLD', clue: 'Low temperature'),
      RawClue(answer: 'WARM', clue: 'Not hot, not cold'),
    ]),
  ];

  static const List<RawPuzzle> _rawPuzzlesAr = [
    RawPuzzle(id: 'animals_ar', name: 'حيوانات', emoji: '🦁', clues: [
      RawClue(answer: 'اسد', clue: 'ملك الغابة'),
      RawClue(answer: 'نمر', clue: 'قط كبير مخطط'),
      RawClue(answer: 'حصان', clue: 'حيوان للركوب'),
      RawClue(answer: 'قرش', clue: 'مفترس المحيط'),
      RawClue(answer: 'حوت', clue: 'أكبر حيوان ثديي'),
      RawClue(answer: 'نسر', clue: 'طائر جارح كبير'),
      RawClue(answer: 'دب', clue: 'يدخل في سبات شتوي'),
      RawClue(answer: 'ذئب', clue: 'يعوي في الليل'),
    ]),
    RawPuzzle(id: 'food_ar', name: 'طعام', emoji: '🍕', clues: [
      RawClue(answer: 'خبز', clue: 'مخبوز من الدقيق'),
      RawClue(answer: 'عسل', clue: 'سائل ذهبي حلو من النحل'),
      RawClue(answer: 'ارز', clue: 'حبوب أساسية'),
      RawClue(answer: 'سمك', clue: 'يعيش في الماء'),
      RawClue(answer: 'بيض', clue: 'الدجاج يبيض هذا'),
      RawClue(answer: 'فول', clue: 'شائع في الفطور المصري'),
      RawClue(answer: 'حليب', clue: 'مشروب أبيض من البقر'),
      RawClue(answer: 'كعك', clue: 'حلوى عيد الميلاد'),
    ]),
    RawPuzzle(id: 'countries_ar', name: 'دول', emoji: '🌍', clues: [
      RawClue(answer: 'مصر', clue: 'أرض الأهرامات'),
      RawClue(answer: 'فرنسا', clue: 'بلد برج إيفل'),
      RawClue(answer: 'الهند', clue: 'بلد تاج محل'),
      RawClue(answer: 'الصين', clue: 'بلد سور الصين العظيم'),
      RawClue(answer: 'العراق', clue: 'بلاد ما بين النهرين'),
      RawClue(answer: 'تركيا', clue: 'بلد بين قارتين'),
      RawClue(answer: 'كندا', clue: 'ثاني أكبر دولة في العالم'),
      RawClue(answer: 'روسيا', clue: 'أكبر دولة مساحة'),
    ]),
    RawPuzzle(id: 'science_ar', name: 'علوم', emoji: '🔬', clues: [
      RawClue(answer: 'قمر', clue: 'القمر الطبيعي للأرض'),
      RawClue(answer: 'نور', clue: 'أسرع شيء في الكون'),
      RawClue(answer: 'ذرة', clue: 'أصغر وحدة في المادة'),
      RawClue(answer: 'قوة', clue: 'دفع أو سحب'),
      RawClue(answer: 'خلية', clue: 'الوحدة الأساسية للحياة'),
      RawClue(answer: 'حرارة', clue: 'شكل من الطاقة'),
      RawClue(answer: 'مدار', clue: 'مسار حول كوكب'),
      RawClue(answer: 'موجة', clue: 'الصوت ينتقل كهذا'),
    ]),
  ];
}
