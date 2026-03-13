import 'dart:math';
import '../models/puzzle_model.dart';

class LocalPuzzles {
  static List<Puzzle> getPuzzles(String type, String difficulty, String language) {
    switch (type) {
      case 'word':
        return _wordPuzzles(difficulty, language);
      case 'quiz':
        return _quizPuzzles(difficulty, language);
      case 'count':
        return _countPuzzles(difficulty, language);
      default:
        return [];
    }
  }

  // ═══════════════════════════════════════════════
  // WORD PUZZLES - 60 per language
  // ═══════════════════════════════════════════════
  static List<Puzzle> _wordPuzzles(String difficulty, String language) {
    final List<Map<String, String>> words;
    if (language == 'ar') {
      words = _arWordData;
    } else {
      words = _enWordData;
    }

    // Filter by difficulty: easy=3-4 letters, medium=4-5, hard=5-6, expert=6+
    final filtered = words.where((w) {
      final len = w['answer']!.length;
      switch (difficulty) {
        case 'easy': return len <= 4;
        case 'medium': return len >= 4 && len <= 5;
        case 'hard': return len >= 5 && len <= 6;
        case 'expert': return len >= 6;
        default: return true;
      }
    }).toList();

    // If not enough puzzles for difficulty, use all
    final source = filtered.isNotEmpty ? filtered : words;

    return List.generate(source.length, (i) => Puzzle(
      id: i + 1,
      type: 'word',
      question: source[i]['question']!,
      answer: source[i]['answer']!,
      options: [],
      difficulty: difficulty,
      language: language,
    ));
  }

  static final List<Map<String, String>> _enWordData = [
    // 3-letter words (easy)
    {'question': 'tca', 'answer': 'cat'},
    {'question': 'god', 'answer': 'dog'},
    {'question': 'nus', 'answer': 'sun'},
    {'question': 'tah', 'answer': 'hat'},
    {'question': 'gub', 'answer': 'bug'},
    {'question': 'puc', 'answer': 'cup'},
    {'question': 'der', 'answer': 'red'},
    {'question': 'gip', 'answer': 'pig'},
    {'question': 'xob', 'answer': 'box'},
    {'question': 'nep', 'answer': 'pen'},
    {'question': 'goj', 'answer': 'jog'},
    {'question': 'naf', 'answer': 'fan'},
    {'question': 'pam', 'answer': 'map'},
    {'question': 'raj', 'answer': 'jar'},
    {'question': 'gab', 'answer': 'bag'},
    // 4-letter words (easy/medium)
    {'question': 'koob', 'answer': 'book'},
    {'question': 'nomo', 'answer': 'moon'},
    {'question': 'rsta', 'answer': 'star'},
    {'question': 'hsif', 'answer': 'fish'},
    {'question': 'drib', 'answer': 'bird'},
    {'question': 'ekac', 'answer': 'cake'},
    {'question': 'niar', 'answer': 'rain'},
    {'question': 'olve', 'answer': 'love'},
    {'question': 'emag', 'answer': 'game'},
    {'question': 'emit', 'answer': 'time'},
    {'question': 'doof', 'answer': 'food'},
    {'question': 'gnki', 'answer': 'king'},
    {'question': 'eerf', 'answer': 'free'},
    {'question': 'llaf', 'answer': 'fall'},
    {'question': 'diap', 'answer': 'paid'},
    {'question': 'dlog', 'answer': 'gold'},
    {'question': 'llew', 'answer': 'well'},
    {'question': 'maet', 'answer': 'team'},
    {'question': 'llab', 'answer': 'ball'},
    {'question': 'erul', 'answer': 'rule'},
    // 5-letter words (medium/hard)
    {'question': 'ratew', 'answer': 'water'},
    {'question': 'sehou', 'answer': 'house'},
    {'question': 'ppale', 'answer': 'apple'},
    {'question': 'olveg', 'answer': 'glove'},
    {'question': 'erte', 'answer': 'tree'},
    {'question': 'ecaep', 'answer': 'peace'},
    {'question': 'maerd', 'answer': 'dream'},
    {'question': 'htrae', 'answer': 'earth'},
    {'question': 'cisum', 'answer': 'music'},
    {'question': 'elivs', 'answer': 'lives'},
    {'question': 'nigth', 'answer': 'night'},
    {'question': 'litgh', 'answer': 'light'},
    {'question': 'nigbe', 'answer': 'begin'},
    {'question': 'roflw', 'answer': 'floor'},
    {'question': 'vried', 'answer': 'river'},
    // 6+ letter words (hard/expert)
    {'question': 'ednarg', 'answer': 'garden'},
    {'question': 'rehtom', 'answer': 'mother'},
    {'question': 'rehtaf', 'answer': 'father'},
    {'question': 'loohcs', 'answer': 'school'},
    {'question': 'retnec', 'answer': 'center'},
    {'question': 'gnidaer', 'answer': 'reading'},
    {'question': 'gninnur', 'answer': 'running'},
    {'question': 'erutuf', 'answer': 'future'},
    {'question': 'dnaslsi', 'answer': 'islands'},
    {'question': 'gnihcaet', 'answer': 'teaching'},
    {'question': 'yrotcaf', 'answer': 'factory'},
    {'question': 'rekrow', 'answer': 'worker'},
    {'question': 'dlrow', 'answer': 'world'},
    {'question': 'naeco', 'answer': 'ocean'},
    {'question': 'rewolf', 'answer': 'flower'},
    {'question': 'yromem', 'answer': 'memory'},
    {'question': 'noitca', 'answer': 'action'},
    {'question': 'modnar', 'answer': 'random'},
    {'question': 'tekram', 'answer': 'market'},
    {'question': 'retpahc', 'answer': 'chapter'},
  ];

  static final List<Map<String, String>> _arWordData = [
    // 3-letter words (easy)
    {'question': 'بتر', 'answer': 'ترب'},
    {'question': 'ملع', 'answer': 'علم'},
    {'question': 'ملق', 'answer': 'قلم'},
    {'question': 'رمق', 'answer': 'قمر'},
    {'question': 'سمش', 'answer': 'شمس'},
    {'question': 'ردب', 'answer': 'برد'},
    {'question': 'حرب', 'answer': 'بحر'},
    {'question': 'ءام', 'answer': 'ماء'},
    {'question': 'رون', 'answer': 'نور'},
    {'question': 'بلك', 'answer': 'كلب'},
    {'question': 'لفط', 'answer': 'طفل'},
    {'question': 'درو', 'answer': 'ورد'},
    {'question': 'كمس', 'answer': 'سمك'},
    {'question': 'بعل', 'answer': 'لعب'},
    {'question': 'ملح', 'answer': 'حلم'},
    // 4-letter words
    {'question': 'بتاك', 'answer': 'كتاب'},
    {'question': 'باب', 'answer': 'باب'},
    {'question': 'لزنم', 'answer': 'منزل'},
    {'question': 'رطم', 'answer': 'مطر'},
    {'question': 'ريط', 'answer': 'طير'},
    {'question': 'دلب', 'answer': 'بلد'},
    {'question': 'نيع', 'answer': 'عين'},
    {'question': 'بهذ', 'answer': 'ذهب'},
    {'question': 'ريخ', 'answer': 'خير'},
    {'question': 'رحس', 'answer': 'سحر'},
    {'question': 'بلق', 'answer': 'قلب'},
    {'question': 'لمع', 'answer': 'عمل'},
    {'question': 'ليل', 'answer': 'ليل'},
    {'question': 'ديع', 'answer': 'عيد'},
    {'question': 'رهن', 'answer': 'نهر'},
    // 5-letter words (medium/hard)
    {'question': 'ةسردم', 'answer': 'مدرسة'},
    {'question': 'ةرجش', 'answer': 'شجرة'},
    {'question': 'ةريزج', 'answer': 'جزيرة'},
    {'question': 'ةنيدم', 'answer': 'مدينة'},
    {'question': 'ةبتكم', 'answer': 'مكتبة'},
    {'question': 'ةقيدح', 'answer': 'حديقة'},
    {'question': 'ةلئاع', 'answer': 'عائلة'},
    {'question': 'ةرايس', 'answer': 'سيارة'},
    {'question': 'ةريحب', 'answer': 'بحيرة'},
    {'question': 'ةرئاط', 'answer': 'طائرة'},
    {'question': 'ةسينك', 'answer': 'كنيسة'},
    {'question': 'ةبيقح', 'answer': 'حقيبة'},
    {'question': 'ةلحر', 'answer': 'رحلة'},
    {'question': 'ةعاس', 'answer': 'ساعة'},
    {'question': 'ةروص', 'answer': 'صورة'},
    // 6+ letter words (expert)
    {'question': 'ةعماج', 'answer': 'جامعة'},
    {'question': 'ةموكح', 'answer': 'حكومة'},
    {'question': 'ةيروهمج', 'answer': 'جمهورية'},
    {'question': 'ةيملع', 'answer': 'علمية'},
    {'question': 'ةيبرع', 'answer': 'عربية'},
    {'question': 'رتويبمك', 'answer': 'كمبيوتر'},
    {'question': 'ايجولونكت', 'answer': 'تكنولوجيا'},
    {'question': 'ةفاقث', 'answer': 'ثقافة'},
    {'question': 'ةيرح', 'answer': 'حرية'},
    {'question': 'ةداعس', 'answer': 'سعادة'},
    {'question': 'ةيدبأ', 'answer': 'أبدية'},
    {'question': 'ةلاسر', 'answer': 'رسالة'},
    {'question': 'ةفرعم', 'answer': 'معرفة'},
    {'question': 'ةمكح', 'answer': 'حكمة'},
    {'question': 'ةعيبط', 'answer': 'طبيعة'},
  ];

  // ═══════════════════════════════════════════════
  // QUIZ PUZZLES - 60 per language
  // ═══════════════════════════════════════════════
  static List<Puzzle> _quizPuzzles(String difficulty, String language) {
    final allQuizzes = language == 'ar' ? _arQuizData : _enQuizData;

    // Split by difficulty ranges
    final int start, end;
    switch (difficulty) {
      case 'easy':
        start = 0; end = 15;
        break;
      case 'medium':
        start = 15; end = 30;
        break;
      case 'hard':
        start = 30; end = 45;
        break;
      case 'expert':
        start = 45; end = allQuizzes.length;
        break;
      default:
        start = 0; end = allQuizzes.length;
    }

    final subset = allQuizzes.sublist(start, end.clamp(0, allQuizzes.length));
    return List.generate(subset.length, (i) => Puzzle(
      id: 100 + start + i + 1,
      type: 'quiz',
      question: subset[i]['q']!,
      answer: subset[i]['a']!,
      options: (subset[i]['o']! as String).split('|'),
      difficulty: difficulty,
      language: language,
    ));
  }

  static final List<Map<String, String>> _enQuizData = [
    // EASY (0-14)
    {'q': 'What is the largest planet?', 'a': 'Jupiter', 'o': 'Mars|Jupiter|Saturn|Earth'},
    {'q': 'How many days in a leap year?', 'a': '366', 'o': '365|366|364|367'},
    {'q': 'What is the capital of France?', 'a': 'Paris', 'o': 'London|Paris|Berlin|Madrid'},
    {'q': 'How many colors in a rainbow?', 'a': '7', 'o': '5|6|7|8'},
    {'q': 'What color is the clear sky?', 'a': 'Blue', 'o': 'Red|Blue|Green|Yellow'},
    {'q': 'How many sides does a triangle have?', 'a': '3', 'o': '3|4|5|6'},
    {'q': 'What do bees make?', 'a': 'Honey', 'o': 'Milk|Honey|Sugar|Wax'},
    {'q': 'How many legs does a spider have?', 'a': '8', 'o': '6|8|10|12'},
    {'q': 'What is baby cat called?', 'a': 'Kitten', 'o': 'Puppy|Kitten|Cub|Foal'},
    {'q': 'What planet do we live on?', 'a': 'Earth', 'o': 'Mars|Earth|Venus|Moon'},
    {'q': 'How many months in a year?', 'a': '12', 'o': '10|11|12|13'},
    {'q': 'Which season is the coldest?', 'a': 'Winter', 'o': 'Spring|Summer|Fall|Winter'},
    {'q': 'What shape is a ball?', 'a': 'Sphere', 'o': 'Cube|Sphere|Cone|Cylinder'},
    {'q': 'What is frozen water called?', 'a': 'Ice', 'o': 'Snow|Ice|Steam|Frost'},
    {'q': 'How many fingers on one hand?', 'a': '5', 'o': '3|4|5|6'},
    // MEDIUM (15-29)
    {'q': 'What is the longest river?', 'a': 'Nile', 'o': 'Amazon|Nile|Mississippi|Yangtze'},
    {'q': 'What is the largest continent?', 'a': 'Asia', 'o': 'Africa|Asia|Europe|America'},
    {'q': 'What is the fastest land animal?', 'a': 'Cheetah', 'o': 'Lion|Cheetah|Horse|Eagle'},
    {'q': 'How many letters in the English alphabet?', 'a': '26', 'o': '24|25|26|28'},
    {'q': 'What is the smallest ocean?', 'a': 'Arctic', 'o': 'Indian|Atlantic|Arctic|Pacific'},
    {'q': 'What is the chemical formula for water?', 'a': 'H2O', 'o': 'CO2|H2O|O2|NaCl'},
    {'q': 'How many teeth does an adult have?', 'a': '32', 'o': '28|30|32|34'},
    {'q': 'What is the capital of Japan?', 'a': 'Tokyo', 'o': 'Seoul|Tokyo|Beijing|Bangkok'},
    {'q': 'How many continents are there?', 'a': '7', 'o': '5|6|7|8'},
    {'q': 'What gas do we breathe?', 'a': 'Oxygen', 'o': 'Nitrogen|Oxygen|Hydrogen|Helium'},
    {'q': 'How many sides does a hexagon have?', 'a': '6', 'o': '4|5|6|8'},
    {'q': 'Which planet is known as the Red Planet?', 'a': 'Mars', 'o': 'Mars|Venus|Jupiter|Mercury'},
    {'q': 'What is the largest mammal?', 'a': 'Blue Whale', 'o': 'Elephant|Blue Whale|Giraffe|Shark'},
    {'q': 'What is the hardest natural substance?', 'a': 'Diamond', 'o': 'Gold|Diamond|Iron|Quartz'},
    {'q': 'How many days in February (non-leap)?', 'a': '28', 'o': '27|28|29|30'},
    // HARD (30-44)
    {'q': 'In what year did humans land on the Moon?', 'a': '1969', 'o': '1965|1969|1971|1975'},
    {'q': 'What is the smallest country?', 'a': 'Vatican City', 'o': 'Monaco|Vatican City|Malta|San Marino'},
    {'q': 'What is the speed of light (km/s)?', 'a': '300000', 'o': '150000|300000|450000|600000'},
    {'q': 'Who painted the Mona Lisa?', 'a': 'Da Vinci', 'o': 'Picasso|Da Vinci|Michelangelo|Rembrandt'},
    {'q': 'What is the largest desert?', 'a': 'Sahara', 'o': 'Gobi|Sahara|Arabian|Kalahari'},
    {'q': 'Which element has the symbol Au?', 'a': 'Gold', 'o': 'Silver|Gold|Aluminum|Argon'},
    {'q': 'How many bones in the human body?', 'a': '206', 'o': '186|196|206|216'},
    {'q': 'What is the capital of Australia?', 'a': 'Canberra', 'o': 'Sydney|Canberra|Melbourne|Perth'},
    {'q': 'Which blood type is universal donor?', 'a': 'O-', 'o': 'A+|B+|O-|AB+'},
    {'q': 'What is the deepest ocean trench?', 'a': 'Mariana', 'o': 'Mariana|Tonga|Java|Puerto Rico'},
    {'q': 'How many planets in our solar system?', 'a': '8', 'o': '7|8|9|10'},
    {'q': 'What causes tides?', 'a': 'Moon gravity', 'o': 'Wind|Moon gravity|Sun heat|Earth spin'},
    {'q': 'Which planet has the most moons?', 'a': 'Saturn', 'o': 'Jupiter|Saturn|Uranus|Neptune'},
    {'q': 'What is the powerhouse of the cell?', 'a': 'Mitochondria', 'o': 'Nucleus|Mitochondria|Ribosome|Golgi'},
    {'q': 'Who discovered penicillin?', 'a': 'Fleming', 'o': 'Pasteur|Fleming|Darwin|Newton'},
    // EXPERT (45-59)
    {'q': 'What is the half-life of Carbon-14?', 'a': '5730 years', 'o': '2500 years|5730 years|10000 years|1200 years'},
    {'q': 'What is Avogadro\'s number (approx)?', 'a': '6.02 x 10^23', 'o': '3.14 x 10^23|6.02 x 10^23|9.8 x 10^23|1.6 x 10^23'},
    {'q': 'Which is the longest bone in the body?', 'a': 'Femur', 'o': 'Tibia|Femur|Humerus|Fibula'},
    {'q': 'What element has atomic number 79?', 'a': 'Gold', 'o': 'Silver|Gold|Platinum|Mercury'},
    {'q': 'What is the Fibonacci sequence next: 1,1,2,3,5,?', 'a': '8', 'o': '6|7|8|9'},
    {'q': 'What is the currency of Japan?', 'a': 'Yen', 'o': 'Won|Yen|Yuan|Rupee'},
    {'q': 'Who wrote "Romeo and Juliet"?', 'a': 'Shakespeare', 'o': 'Dickens|Shakespeare|Hemingway|Twain'},
    {'q': 'What is absolute zero in Celsius?', 'a': '-273.15', 'o': '-100|-273.15|0|-459.67'},
    {'q': 'What is the chemical symbol for Potassium?', 'a': 'K', 'o': 'P|K|Po|Pt'},
    {'q': 'How many chromosomes do humans have?', 'a': '46', 'o': '23|44|46|48'},
    {'q': 'What year was the Internet invented?', 'a': '1969', 'o': '1969|1975|1983|1990'},
    {'q': 'What is the square root of 144?', 'a': '12', 'o': '10|11|12|14'},
    {'q': 'Which gas makes up most of Earth\'s atmosphere?', 'a': 'Nitrogen', 'o': 'Oxygen|Nitrogen|CO2|Argon'},
    {'q': 'What is the SI unit of force?', 'a': 'Newton', 'o': 'Joule|Newton|Watt|Pascal'},
    {'q': 'What is the boiling point of water in Kelvin?', 'a': '373', 'o': '273|373|473|100'},
  ];

  static final List<Map<String, String>> _arQuizData = [
    // EASY (0-14)
    {'q': 'ما هو أكبر كوكب في المجموعة الشمسية؟', 'a': 'المشتري', 'o': 'المريخ|المشتري|زحل|الأرض'},
    {'q': 'كم عدد أيام السنة الكبيسة؟', 'a': '366', 'o': '365|366|364|367'},
    {'q': 'ما هي عاصمة مصر؟', 'a': 'القاهرة', 'o': 'الإسكندرية|القاهرة|الجيزة|أسوان'},
    {'q': 'كم عدد ألوان قوس قزح؟', 'a': '7', 'o': '5|6|7|8'},
    {'q': 'ما هو لون السماء الصافية؟', 'a': 'أزرق', 'o': 'أحمر|أزرق|أخضر|أصفر'},
    {'q': 'كم عدد أضلاع المثلث؟', 'a': '3', 'o': '3|4|5|6'},
    {'q': 'ماذا يصنع النحل؟', 'a': 'عسل', 'o': 'حليب|عسل|سكر|شمع'},
    {'q': 'كم عدد أرجل العنكبوت؟', 'a': '8', 'o': '6|8|10|12'},
    {'q': 'ما هو صغير القطة؟', 'a': 'هريرة', 'o': 'جرو|هريرة|شبل|مهر'},
    {'q': 'على أي كوكب نعيش؟', 'a': 'الأرض', 'o': 'المريخ|الأرض|الزهرة|القمر'},
    {'q': 'كم عدد أشهر السنة؟', 'a': '12', 'o': '10|11|12|13'},
    {'q': 'ما هو أبرد فصل؟', 'a': 'الشتاء', 'o': 'الربيع|الصيف|الخريف|الشتاء'},
    {'q': 'ما هو شكل الكرة؟', 'a': 'كروي', 'o': 'مكعب|كروي|مخروط|أسطوانة'},
    {'q': 'ماذا يسمى الماء المتجمد؟', 'a': 'ثلج', 'o': 'ثلج|جليد|بخار|صقيع'},
    {'q': 'كم إصبع في اليد الواحدة؟', 'a': '5', 'o': '3|4|5|6'},
    // MEDIUM (15-29)
    {'q': 'ما هو أطول نهر في العالم؟', 'a': 'النيل', 'o': 'الأمازون|النيل|المسيسيبي|دجلة'},
    {'q': 'ما هي أكبر قارة في العالم؟', 'a': 'آسيا', 'o': 'أفريقيا|آسيا|أوروبا|أمريكا'},
    {'q': 'ما هو الحيوان الأسرع في العالم؟', 'a': 'الفهد', 'o': 'الأسد|الفهد|الحصان|النسر'},
    {'q': 'كم عدد حروف اللغة العربية؟', 'a': '28', 'o': '26|27|28|30'},
    {'q': 'ما هو أصغر محيط في العالم؟', 'a': 'المتجمد الشمالي', 'o': 'الهندي|الأطلسي|المتجمد الشمالي|الهادئ'},
    {'q': 'ما هو العنصر الكيميائي للماء؟', 'a': 'H2O', 'o': 'CO2|H2O|O2|NaCl'},
    {'q': 'كم عدد أسنان الإنسان البالغ؟', 'a': '32', 'o': '28|30|32|34'},
    {'q': 'ما هي عاصمة اليابان؟', 'a': 'طوكيو', 'o': 'سيول|طوكيو|بكين|بانكوك'},
    {'q': 'كم عدد قارات العالم؟', 'a': '7', 'o': '5|6|7|8'},
    {'q': 'ما الغاز الذي تتنفسه الكائنات الحية؟', 'a': 'الأكسجين', 'o': 'النيتروجين|الأكسجين|الهيدروجين|الهيليوم'},
    {'q': 'كم عدد أضلاع السداسي؟', 'a': '6', 'o': '4|5|6|8'},
    {'q': 'أي كوكب يعرف بالكوكب الأحمر؟', 'a': 'المريخ', 'o': 'المريخ|الزهرة|المشتري|عطارد'},
    {'q': 'ما هو أكبر حيوان ثديي؟', 'a': 'الحوت الأزرق', 'o': 'الفيل|الحوت الأزرق|الزرافة|القرش'},
    {'q': 'ما هو أصلب مادة طبيعية؟', 'a': 'الألماس', 'o': 'الذهب|الألماس|الحديد|الكوارتز'},
    {'q': 'كم يوم في شهر فبراير العادي؟', 'a': '28', 'o': '27|28|29|30'},
    // HARD (30-44)
    {'q': 'في أي سنة هبط الإنسان على القمر؟', 'a': '1969', 'o': '1965|1969|1971|1975'},
    {'q': 'ما هي أصغر دولة في العالم؟', 'a': 'الفاتيكان', 'o': 'موناكو|الفاتيكان|مالطا|سان مارينو'},
    {'q': 'ما سرعة الضوء تقريبا (كم/ث)؟', 'a': '300000', 'o': '150000|300000|450000|600000'},
    {'q': 'من رسم الموناليزا؟', 'a': 'دافنشي', 'o': 'بيكاسو|دافنشي|مايكل أنجلو|رمبرانت'},
    {'q': 'ما هي أكبر صحراء في العالم؟', 'a': 'الصحراء الكبرى', 'o': 'جوبي|الصحراء الكبرى|العربية|كالاهاري'},
    {'q': 'ما هو رمز الذهب الكيميائي؟', 'a': 'Au', 'o': 'Ag|Au|Al|Ar'},
    {'q': 'كم عدد عظام جسم الإنسان؟', 'a': '206', 'o': '186|196|206|216'},
    {'q': 'ما هي عاصمة أستراليا؟', 'a': 'كانبيرا', 'o': 'سيدني|كانبيرا|ملبورن|بيرث'},
    {'q': 'ما فصيلة الدم المتبرع العام؟', 'a': 'O-', 'o': 'A+|B+|O-|AB+'},
    {'q': 'ما هو أعمق خندق في المحيط؟', 'a': 'ماريانا', 'o': 'ماريانا|تونغا|جاوة|بورتوريكو'},
    {'q': 'كم عدد كواكب المجموعة الشمسية؟', 'a': '8', 'o': '7|8|9|10'},
    {'q': 'ما سبب المد والجزر؟', 'a': 'جاذبية القمر', 'o': 'الرياح|جاذبية القمر|حرارة الشمس|دوران الأرض'},
    {'q': 'أي كوكب لديه أكثر أقمار؟', 'a': 'زحل', 'o': 'المشتري|زحل|أورانوس|نبتون'},
    {'q': 'ما مركز الطاقة في الخلية؟', 'a': 'الميتوكوندريا', 'o': 'النواة|الميتوكوندريا|الريبوسوم|جولجي'},
    {'q': 'من اكتشف البنسلين؟', 'a': 'فلمنج', 'o': 'باستور|فلمنج|داروين|نيوتن'},
    // EXPERT (45-59)
    {'q': 'ما نصف عمر الكربون-14؟', 'a': '5730 سنة', 'o': '2500 سنة|5730 سنة|10000 سنة|1200 سنة'},
    {'q': 'ما هو عدد أفوجادرو تقريبا؟', 'a': '6.02 x 10^23', 'o': '3.14 x 10^23|6.02 x 10^23|9.8 x 10^23|1.6 x 10^23'},
    {'q': 'ما هو أطول عظم في الجسم؟', 'a': 'عظم الفخذ', 'o': 'الساق|عظم الفخذ|العضد|الشظية'},
    {'q': 'ما العنصر ذو العدد الذري 79؟', 'a': 'الذهب', 'o': 'الفضة|الذهب|البلاتين|الزئبق'},
    {'q': 'متتالية فيبوناتشي: 1,1,2,3,5,?', 'a': '8', 'o': '6|7|8|9'},
    {'q': 'ما هي عملة اليابان؟', 'a': 'ين', 'o': 'وون|ين|يوان|روبية'},
    {'q': 'من كتب "روميو وجولييت"؟', 'a': 'شكسبير', 'o': 'ديكنز|شكسبير|همنغواي|تواين'},
    {'q': 'ما هو الصفر المطلق بالسلسيوس؟', 'a': '-273.15', 'o': '-100|-273.15|0|-459.67'},
    {'q': 'ما رمز البوتاسيوم الكيميائي؟', 'a': 'K', 'o': 'P|K|Po|Pt'},
    {'q': 'كم عدد كروموسومات الإنسان؟', 'a': '46', 'o': '23|44|46|48'},
    {'q': 'في أي سنة اخترع الإنترنت؟', 'a': '1969', 'o': '1969|1975|1983|1990'},
    {'q': 'ما هو الجذر التربيعي لـ 144؟', 'a': '12', 'o': '10|11|12|14'},
    {'q': 'ما الغاز الأكثر في الغلاف الجوي؟', 'a': 'النيتروجين', 'o': 'الأكسجين|النيتروجين|ثاني أكسيد الكربون|الأرجون'},
    {'q': 'ما وحدة قياس القوة؟', 'a': 'نيوتن', 'o': 'جول|نيوتن|واط|باسكال'},
    {'q': 'ما درجة غليان الماء بالكلفن؟', 'a': '373', 'o': '273|373|473|100'},
  ];

  // ═══════════════════════════════════════════════
  // COUNT PUZZLES - Generated dynamically, 60 per difficulty
  // ═══════════════════════════════════════════════
  static List<Puzzle> _countPuzzles(String difficulty, String language) {
    final random = Random(difficulty.hashCode); // Seeded for consistency
    final emojis = ['🔺', '🔵', '⭐', '💎', '🟩', '🟦', '❤️', '🟡', '🟠', '🟣'];

    int puzzleCount;
    int maxTotal;
    switch (difficulty) {
      case 'easy':
        puzzleCount = 60; maxTotal = 6;
        break;
      case 'medium':
        puzzleCount = 60; maxTotal = 10;
        break;
      case 'hard':
        puzzleCount = 60; maxTotal = 15;
        break;
      case 'expert':
        puzzleCount = 60; maxTotal = 20;
        break;
      default:
        puzzleCount = 60; maxTotal = 8;
    }

    return List.generate(puzzleCount, (i) {
      final targetEmoji = emojis[random.nextInt(emojis.length)];
      String otherEmoji;
      do {
        otherEmoji = emojis[random.nextInt(emojis.length)];
      } while (otherEmoji == targetEmoji);

      final targetCount = 1 + random.nextInt((maxTotal * 0.6).ceil());
      final otherCount = 1 + random.nextInt((maxTotal * 0.4).ceil());

      // Build question string
      final allEmojis = <String>[];
      for (int j = 0; j < targetCount; j++) allEmojis.add(targetEmoji);
      for (int j = 0; j < otherCount; j++) allEmojis.add(otherEmoji);
      allEmojis.shuffle(Random(i + difficulty.hashCode));

      final question = allEmojis.join('');
      final answer = '$targetCount';

      // Generate options (always include correct answer)
      final opts = <String>{answer};
      while (opts.length < 4) {
        final opt = 1 + random.nextInt(maxTotal);
        opts.add('$opt');
      }
      final optList = opts.toList()..shuffle(Random(i));

      return Puzzle(
        id: 200 + i + 1,
        type: 'count',
        question: '$question\n${language == 'ar' ? 'عد $targetEmoji' : 'Count $targetEmoji'}',
        answer: answer,
        options: optList,
        difficulty: difficulty,
        language: language,
      );
    });
  }

  // Word Categories - local letter data
  static Map<String, dynamic>? getRandomLetter(String language) {
    final letters = language == 'ar'
        ? ['أ', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ر', 'س', 'ش', 'ص', 'ع', 'ف', 'ق', 'ك', 'ل', 'م', 'ن', 'هـ', 'و', 'ي']
        : ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'R', 'S', 'T', 'W'];

    letters.shuffle();
    return {
      'letter': letters.first,
      'categories': ['name', 'job', 'object', 'food', 'animal', 'country'],
    };
  }
}
