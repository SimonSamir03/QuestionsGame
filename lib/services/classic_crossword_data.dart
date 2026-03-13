/// A single placed word in the crossword grid
class CrosswordEntry {
  final int number;
  final String direction; // 'across' or 'down'
  final int row;
  final int col;
  final String answer;
  final String clueEn;
  final String clueAr;

  const CrosswordEntry({
    required this.number,
    required this.direction,
    required this.row,
    required this.col,
    required this.answer,
    required this.clueEn,
    required this.clueAr,
  });

  int get length => answer.length;
}

/// A complete crossword puzzle
class ClassicCrosswordPuzzle {
  final String id;
  final String nameEn;
  final String nameAr;
  final String emoji;
  final int gridRows;
  final int gridCols;
  final List<CrosswordEntry> entries;

  const ClassicCrosswordPuzzle({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.emoji,
    required this.gridRows,
    required this.gridCols,
    required this.entries,
  });

  List<CrosswordEntry> get across =>
      entries.where((e) => e.direction == 'across').toList()..sort((a, b) => a.number.compareTo(b.number));

  List<CrosswordEntry> get down =>
      entries.where((e) => e.direction == 'down').toList()..sort((a, b) => a.number.compareTo(b.number));

  /// Get all active cells as (row, col) with the letter
  Map<String, String> get activeCells {
    final map = <String, String>{};
    for (final e in entries) {
      for (int i = 0; i < e.length; i++) {
        final r = e.direction == 'down' ? e.row + i : e.row;
        final c = e.direction == 'across' ? e.col + i : e.col;
        map['$r,$c'] = e.answer[i];
      }
    }
    return map;
  }

  /// Get cell numbers (row,col) -> number
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

class ClassicCrosswordData {
  static const List<ClassicCrosswordPuzzle> puzzles = [
    // ───── Puzzle 1: Animals ─────
    ClassicCrosswordPuzzle(
      id: 'animals_1',
      nameEn: 'Animals',
      nameAr: 'حيوانات',
      emoji: '🦁',
      gridRows: 10,
      gridCols: 10,
      entries: [
        CrosswordEntry(number: 1, direction: 'down', row: 0, col: 2, answer: 'TIGER', clueEn: 'Striped big cat', clueAr: 'قط كبير مخطط'),
        CrosswordEntry(number: 2, direction: 'across', row: 0, col: 7, answer: 'OWL', clueEn: 'Night bird', clueAr: 'طائر الليل'),
        CrosswordEntry(number: 3, direction: 'across', row: 1, col: 0, answer: 'LION', clueEn: 'King of the jungle', clueAr: 'ملك الغابة'),
        CrosswordEntry(number: 4, direction: 'across', row: 3, col: 0, answer: 'EAGLE', clueEn: 'Large bird of prey', clueAr: 'طائر جارح كبير'),
        CrosswordEntry(number: 5, direction: 'down', row: 3, col: 5, answer: 'SHARK', clueEn: 'Ocean predator', clueAr: 'مفترس المحيط'),
        CrosswordEntry(number: 6, direction: 'across', row: 5, col: 3, answer: 'WHALE', clueEn: 'Largest mammal', clueAr: 'أكبر حيوان ثديي'),
        CrosswordEntry(number: 7, direction: 'down', row: 5, col: 0, answer: 'BEAR', clueEn: 'Hibernates in winter', clueAr: 'يدخل في سبات شتوي'),
        CrosswordEntry(number: 8, direction: 'across', row: 7, col: 1, answer: 'SNAKE', clueEn: 'Legless reptile', clueAr: 'زاحف بدون أرجل'),
        CrosswordEntry(number: 9, direction: 'across', row: 6, col: 2, answer: 'HORSE', clueEn: 'Animal for riding', clueAr: 'حيوان للركوب'),
        CrosswordEntry(number: 10, direction: 'down', row: 7, col: 1, answer: 'SUN', clueEn: 'Star in the sky (wrong category!)', clueAr: 'نجم في السماء'),
      ],
    ),

    // ───── Puzzle 2: Food ─────
    ClassicCrosswordPuzzle(
      id: 'food_1',
      nameEn: 'Food & Drinks',
      nameAr: 'طعام ومشروبات',
      emoji: '🍕',
      gridRows: 10,
      gridCols: 10,
      entries: [
        CrosswordEntry(number: 1, direction: 'down', row: 0, col: 3, answer: 'PIZZA', clueEn: 'Italian flat bread with toppings', clueAr: 'خبز إيطالي مسطح بإضافات'),
        CrosswordEntry(number: 2, direction: 'across', row: 0, col: 6, answer: 'RICE', clueEn: 'Asian staple grain', clueAr: 'حبوب أساسية آسيوية'),
        CrosswordEntry(number: 3, direction: 'across', row: 1, col: 0, answer: 'MILK', clueEn: 'White drink from cows', clueAr: 'مشروب أبيض من البقر'),
        CrosswordEntry(number: 4, direction: 'across', row: 3, col: 1, answer: 'BREAD', clueEn: 'Baked from flour', clueAr: 'مخبوز من الدقيق'),
        CrosswordEntry(number: 5, direction: 'down', row: 2, col: 7, answer: 'CAKE', clueEn: 'Sweet birthday treat', clueAr: 'حلوى عيد الميلاد'),
        CrosswordEntry(number: 6, direction: 'down', row: 3, col: 1, answer: 'BEANS', clueEn: 'Popular in Egyptian breakfast', clueAr: 'شائع في الفطور المصري'),
        CrosswordEntry(number: 7, direction: 'across', row: 5, col: 0, answer: 'HONEY', clueEn: 'Sweet golden liquid from bees', clueAr: 'سائل ذهبي حلو من النحل'),
        CrosswordEntry(number: 8, direction: 'across', row: 4, col: 3, answer: 'PASTA', clueEn: 'Italian noodle dish', clueAr: 'طبق مكرونة إيطالي'),
        CrosswordEntry(number: 9, direction: 'down', row: 5, col: 4, answer: 'EGG', clueEn: 'Chickens lay this', clueAr: 'الدجاج يبيض هذا'),
        CrosswordEntry(number: 10, direction: 'across', row: 7, col: 0, answer: 'STEAK', clueEn: 'Grilled beef', clueAr: 'لحم بقري مشوي'),
      ],
    ),

    // ───── Puzzle 3: Countries ─────
    ClassicCrosswordPuzzle(
      id: 'countries_1',
      nameEn: 'Countries',
      nameAr: 'دول العالم',
      emoji: '🌍',
      gridRows: 11,
      gridCols: 11,
      entries: [
        CrosswordEntry(number: 1, direction: 'down', row: 0, col: 3, answer: 'EGYPT', clueEn: 'Land of the pyramids', clueAr: 'أرض الأهرامات'),
        CrosswordEntry(number: 2, direction: 'across', row: 0, col: 7, answer: 'IRAQ', clueEn: 'Mesopotamia country', clueAr: 'بلاد ما بين النهرين'),
        CrosswordEntry(number: 3, direction: 'across', row: 2, col: 0, answer: 'JAPAN', clueEn: 'Land of the rising sun', clueAr: 'أرض الشمس المشرقة'),
        CrosswordEntry(number: 4, direction: 'down', row: 2, col: 0, answer: 'JORDAN', clueEn: 'Petra is here', clueAr: 'البتراء هنا'),
        CrosswordEntry(number: 5, direction: 'across', row: 4, col: 2, answer: 'FRANCE', clueEn: 'Eiffel Tower country', clueAr: 'بلد برج إيفل'),
        CrosswordEntry(number: 6, direction: 'down', row: 3, col: 6, answer: 'CHINA', clueEn: 'Great Wall country', clueAr: 'بلد سور الصين العظيم'),
        CrosswordEntry(number: 7, direction: 'across', row: 6, col: 0, answer: 'BRAZIL', clueEn: 'Largest South American country', clueAr: 'أكبر دولة في أمريكا الجنوبية'),
        CrosswordEntry(number: 8, direction: 'across', row: 8, col: 1, answer: 'INDIA', clueEn: 'Taj Mahal country', clueAr: 'بلد تاج محل'),
        CrosswordEntry(number: 9, direction: 'down', row: 6, col: 4, answer: 'ITALY', clueEn: 'Boot-shaped country', clueAr: 'بلد على شكل حذاء'),
        CrosswordEntry(number: 10, direction: 'down', row: 7, col: 8, answer: 'SPAIN', clueEn: 'Flamenco country', clueAr: 'بلد الفلامنكو'),
      ],
    ),

    // ───── Puzzle 4: Science ─────
    ClassicCrosswordPuzzle(
      id: 'science_1',
      nameEn: 'Science',
      nameAr: 'علوم',
      emoji: '🔬',
      gridRows: 10,
      gridCols: 10,
      entries: [
        CrosswordEntry(number: 1, direction: 'down', row: 0, col: 2, answer: 'ATOM', clueEn: 'Smallest unit of matter', clueAr: 'أصغر وحدة في المادة'),
        CrosswordEntry(number: 2, direction: 'across', row: 0, col: 5, answer: 'MOON', clueEn: 'Earth\'s natural satellite', clueAr: 'القمر الطبيعي للأرض'),
        CrosswordEntry(number: 3, direction: 'across', row: 1, col: 0, answer: 'STAR', clueEn: 'The sun is one', clueAr: 'الشمس واحدة منها'),
        CrosswordEntry(number: 4, direction: 'across', row: 3, col: 1, answer: 'FORCE', clueEn: 'Push or pull (Newton)', clueAr: 'دفع أو سحب (نيوتن)'),
        CrosswordEntry(number: 5, direction: 'down', row: 2, col: 5, answer: 'LIGHT', clueEn: 'Fastest thing in the universe', clueAr: 'أسرع شيء في الكون'),
        CrosswordEntry(number: 6, direction: 'across', row: 5, col: 0, answer: 'CELL', clueEn: 'Basic unit of life', clueAr: 'الوحدة الأساسية للحياة'),
        CrosswordEntry(number: 7, direction: 'down', row: 4, col: 8, answer: 'WAVE', clueEn: 'Sound travels as this', clueAr: 'الصوت ينتقل كهذا'),
        CrosswordEntry(number: 8, direction: 'across', row: 7, col: 2, answer: 'HEAT', clueEn: 'Form of energy, makes things hot', clueAr: 'شكل من الطاقة، يسخن الأشياء'),
        CrosswordEntry(number: 9, direction: 'down', row: 5, col: 3, answer: 'LENS', clueEn: 'Used in microscopes', clueAr: 'تُستخدم في المجاهر'),
        CrosswordEntry(number: 10, direction: 'across', row: 6, col: 4, answer: 'ORBIT', clueEn: 'Path around a planet', clueAr: 'مسار حول كوكب'),
      ],
    ),

    // ───── Puzzle 5: Sports ─────
    ClassicCrosswordPuzzle(
      id: 'sports_1',
      nameEn: 'Sports',
      nameAr: 'رياضة',
      emoji: '⚽',
      gridRows: 10,
      gridCols: 10,
      entries: [
        CrosswordEntry(number: 1, direction: 'across', row: 0, col: 0, answer: 'GOAL', clueEn: 'Score in football', clueAr: 'تسجيل في كرة القدم'),
        CrosswordEntry(number: 2, direction: 'down', row: 0, col: 0, answer: 'GOLF', clueEn: 'Sport with clubs and holes', clueAr: 'رياضة بالعصي والحفر'),
        CrosswordEntry(number: 3, direction: 'across', row: 2, col: 1, answer: 'SWIM', clueEn: 'Move in water', clueAr: 'التحرك في الماء'),
        CrosswordEntry(number: 4, direction: 'down', row: 1, col: 4, answer: 'TENNIS', clueEn: 'Racket sport', clueAr: 'رياضة المضرب'),
        CrosswordEntry(number: 5, direction: 'across', row: 4, col: 2, answer: 'BOXING', clueEn: 'Fighting with gloves', clueAr: 'قتال بالقفازات'),
        CrosswordEntry(number: 6, direction: 'down', row: 3, col: 7, answer: 'RUGBY', clueEn: 'Oval ball sport', clueAr: 'رياضة الكرة البيضاوية'),
        CrosswordEntry(number: 7, direction: 'across', row: 6, col: 0, answer: 'DIVING', clueEn: 'Jumping into pool from height', clueAr: 'القفز في المسبح من ارتفاع'),
        CrosswordEntry(number: 8, direction: 'across', row: 8, col: 1, answer: 'JUDO', clueEn: 'Japanese martial art', clueAr: 'فن قتالي ياباني'),
        CrosswordEntry(number: 9, direction: 'down', row: 6, col: 3, answer: 'YOGA', clueEn: 'Stretching and breathing exercise', clueAr: 'تمارين تمدد وتنفس'),
        CrosswordEntry(number: 10, direction: 'down', row: 4, col: 2, answer: 'BALL', clueEn: 'Round thing you throw', clueAr: 'شيء مستدير ترميه'),
      ],
    ),

    // ───── Puzzle 6: School ─────
    ClassicCrosswordPuzzle(
      id: 'school_1',
      nameEn: 'School',
      nameAr: 'مدرسة',
      emoji: '📚',
      gridRows: 10,
      gridCols: 10,
      entries: [
        CrosswordEntry(number: 1, direction: 'down', row: 0, col: 1, answer: 'BOOK', clueEn: 'You read this', clueAr: 'تقرأ هذا'),
        CrosswordEntry(number: 2, direction: 'across', row: 0, col: 4, answer: 'DESK', clueEn: 'You sit at this', clueAr: 'تجلس عند هذا'),
        CrosswordEntry(number: 3, direction: 'across', row: 2, col: 0, answer: 'MATH', clueEn: 'Numbers subject', clueAr: 'مادة الأرقام'),
        CrosswordEntry(number: 4, direction: 'down', row: 1, col: 6, answer: 'EXAM', clueEn: 'End of year test', clueAr: 'اختبار نهاية العام'),
        CrosswordEntry(number: 5, direction: 'across', row: 3, col: 1, answer: 'CHALK', clueEn: 'Write on blackboard with this', clueAr: 'تكتب على السبورة بهذا'),
        CrosswordEntry(number: 6, direction: 'across', row: 5, col: 2, answer: 'RULER', clueEn: 'Measures length', clueAr: 'يقيس الطول'),
        CrosswordEntry(number: 7, direction: 'down', row: 4, col: 8, answer: 'PEN', clueEn: 'Writing tool with ink', clueAr: 'أداة كتابة بالحبر'),
        CrosswordEntry(number: 8, direction: 'across', row: 7, col: 0, answer: 'CLASS', clueEn: 'Room where you learn', clueAr: 'غرفة تتعلم فيها'),
        CrosswordEntry(number: 9, direction: 'down', row: 5, col: 2, answer: 'READ', clueEn: 'Look at words', clueAr: 'تنظر للكلمات'),
        CrosswordEntry(number: 10, direction: 'down', row: 3, col: 1, answer: 'CLEAR', clueEn: 'Easy to understand', clueAr: 'سهل الفهم'),
      ],
    ),

    // ───── Puzzle 7: Body ─────
    ClassicCrosswordPuzzle(
      id: 'body_1',
      nameEn: 'Human Body',
      nameAr: 'جسم الإنسان',
      emoji: '🫀',
      gridRows: 10,
      gridCols: 10,
      entries: [
        CrosswordEntry(number: 1, direction: 'across', row: 0, col: 1, answer: 'HEART', clueEn: 'Pumps blood', clueAr: 'يضخ الدم'),
        CrosswordEntry(number: 2, direction: 'down', row: 0, col: 1, answer: 'HAND', clueEn: 'Has five fingers', clueAr: 'فيها خمس أصابع'),
        CrosswordEntry(number: 3, direction: 'down', row: 0, col: 5, answer: 'TEETH', clueEn: 'You chew with these', clueAr: 'تمضغ بهذه'),
        CrosswordEntry(number: 4, direction: 'across', row: 2, col: 0, answer: 'BRAIN', clueEn: 'Controls the body', clueAr: 'يتحكم في الجسم'),
        CrosswordEntry(number: 5, direction: 'across', row: 4, col: 2, answer: 'LUNGS', clueEn: 'You breathe with these', clueAr: 'تتنفس بهذه'),
        CrosswordEntry(number: 6, direction: 'down', row: 3, col: 8, answer: 'BONE', clueEn: 'Hard white tissue inside body', clueAr: 'نسيج صلب أبيض داخل الجسم'),
        CrosswordEntry(number: 7, direction: 'across', row: 6, col: 0, answer: 'SKIN', clueEn: 'Covers your body', clueAr: 'يغطي جسمك'),
        CrosswordEntry(number: 8, direction: 'across', row: 8, col: 1, answer: 'KNEE', clueEn: 'Joint in the leg', clueAr: 'مفصل في الساق'),
        CrosswordEntry(number: 9, direction: 'down', row: 4, col: 2, answer: 'LIVER', clueEn: 'Detox organ', clueAr: 'عضو إزالة السموم'),
        CrosswordEntry(number: 10, direction: 'down', row: 6, col: 0, answer: 'SPINE', clueEn: 'Backbone', clueAr: 'العمود الفقري'),
      ],
    ),

    // ───── Puzzle 8: Weather ─────
    ClassicCrosswordPuzzle(
      id: 'weather_1',
      nameEn: 'Weather',
      nameAr: 'طقس',
      emoji: '🌤️',
      gridRows: 10,
      gridCols: 10,
      entries: [
        CrosswordEntry(number: 1, direction: 'across', row: 0, col: 0, answer: 'CLOUD', clueEn: 'White fluffy thing in sky', clueAr: 'شيء أبيض رقيق في السماء'),
        CrosswordEntry(number: 2, direction: 'down', row: 0, col: 0, answer: 'COLD', clueEn: 'Low temperature', clueAr: 'درجة حرارة منخفضة'),
        CrosswordEntry(number: 3, direction: 'down', row: 0, col: 4, answer: 'DUST', clueEn: 'Sand in the air', clueAr: 'رمال في الهواء'),
        CrosswordEntry(number: 4, direction: 'across', row: 2, col: 2, answer: 'STORM', clueEn: 'Heavy rain and wind', clueAr: 'مطر غزير ورياح'),
        CrosswordEntry(number: 5, direction: 'across', row: 4, col: 0, answer: 'SNOW', clueEn: 'Frozen white flakes', clueAr: 'رقائق بيضاء متجمدة'),
        CrosswordEntry(number: 6, direction: 'down', row: 3, col: 6, answer: 'RAIN', clueEn: 'Water from clouds', clueAr: 'ماء من السحب'),
        CrosswordEntry(number: 7, direction: 'across', row: 6, col: 1, answer: 'SUNNY', clueEn: 'Bright warm day', clueAr: 'يوم مشرق دافئ'),
        CrosswordEntry(number: 8, direction: 'across', row: 8, col: 0, answer: 'WIND', clueEn: 'Moving air', clueAr: 'هواء متحرك'),
        CrosswordEntry(number: 9, direction: 'down', row: 6, col: 1, answer: 'SUN', clueEn: 'Yellow star', clueAr: 'نجمة صفراء'),
        CrosswordEntry(number: 10, direction: 'down', row: 4, col: 3, answer: 'WARM', clueEn: 'Not hot, not cold', clueAr: 'ليس حار، ليس بارد'),
      ],
    ),
  ];
}
