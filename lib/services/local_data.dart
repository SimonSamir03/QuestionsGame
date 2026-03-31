import '../models/question_model.dart';

class LocalData {
  static List<Question> getQuestions(int gameId, String difficulty, String language) {
    switch (gameId) {
      case 1:
        return _wordQuestions(difficulty, language);
      case 2:
        return _quizQuestions(difficulty, language);
      default:
        return [];
    }
  }

  // ═══════════════════════════════════════════════
  // WORD REARRANGE
  // ═══════════════════════════════════════════════
  static List<Question> _wordQuestions(String difficulty, String language) {
    final data = language == 'ar' ? _arWordData : _enWordData;

    final filtered = data.where((w) {
      final len = (w['answer'] as String).length;
      switch (difficulty) {
        case 'easy': return len <= 4;
        case 'medium': return len >= 4 && len <= 5;
        case 'hard': return len >= 5 && len <= 6;
        case 'expert': return len >= 6;
        default: return true;
      }
    }).toList();

    final source = filtered.isNotEmpty ? filtered : data;

    return List.generate(source.length, (i) => Question.fromJson({
      'id': 0,
      'game_id': 1,
      'question': source[i]['question'],
      'answer': source[i]['answer'],
      'difficulty': difficulty,
      'language': language,
      'is_active': true,
    }));
  }

  // ═══════════════════════════════════════════════
  // QUIZ
  // ═══════════════════════════════════════════════
  static List<Question> _quizQuestions(String difficulty, String language) {
    final allQuizzes = language == 'ar' ? _arQuizData : _enQuizData;

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
    return List.generate(subset.length, (i) {
      final q = subset[i];
      final options = (q['o'] as String).split('|');
      final answer = q['a'] as String;
      return Question.fromJson({
        'id': 0,
        'game_id': 2,
        'question': q['q'],
        'answer': answer,
        'difficulty': difficulty,
        'language': language,
        'is_active': true,
        'answers': List.generate(options.length, (j) => {
          'id': j,
          'question_id': 0,
          'answer_text': options[j],
          'is_correct': options[j].toLowerCase() == answer.toLowerCase(),
          'sort_order': j,
        }),
      });
    });
  }

  // ═══════════════════════════════════════════════
  // WORD CATEGORIES - local letter data
  // ═══════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════
  // DATA
  // ═══════════════════════════════════════════════

  static final List<Map<String, String>> _enWordData = [
    {'question': 'A small furry pet that meows', 'answer': 'cat'},
    {'question': 'A loyal pet that barks', 'answer': 'dog'},
    {'question': 'The star that lights our day', 'answer': 'sun'},
    {'question': 'You wear it on your head', 'answer': 'hat'},
    {'question': 'A tiny crawling insect', 'answer': 'bug'},
    {'question': 'You drink from it', 'answer': 'cup'},
    {'question': 'The color of roses', 'answer': 'red'},
    {'question': 'A farm animal that oinks', 'answer': 'pig'},
    {'question': 'A container with four sides', 'answer': 'box'},
    {'question': 'You write with it', 'answer': 'pen'},
    {'question': 'Running at a slow pace', 'answer': 'jog'},
    {'question': 'Blows cool air on a hot day', 'answer': 'fan'},
    {'question': 'Shows roads and cities', 'answer': 'map'},
    {'question': 'A glass container for food', 'answer': 'jar'},
    {'question': 'You carry things in it', 'answer': 'bag'},
    {'question': 'You read stories from it', 'answer': 'book'},
    {'question': 'It lights up the night sky', 'answer': 'moon'},
    {'question': 'A shining light in space', 'answer': 'star'},
    {'question': 'It swims in water', 'answer': 'fish'},
    {'question': 'A flying animal with feathers', 'answer': 'bird'},
    {'question': 'A sweet baked dessert', 'answer': 'cake'},
    {'question': 'Water falling from clouds', 'answer': 'rain'},
    {'question': 'A deep feeling of affection', 'answer': 'love'},
    {'question': 'Something you play for fun', 'answer': 'game'},
    {'question': 'Measured by a clock', 'answer': 'time'},
    {'question': 'What you eat when hungry', 'answer': 'food'},
    {'question': 'A ruler who wears a crown', 'answer': 'king'},
    {'question': 'Not costing anything', 'answer': 'free'},
    {'question': 'The season when leaves drop', 'answer': 'fall'},
    {'question': 'Given money for work done', 'answer': 'paid'},
    {'question': 'A precious yellow metal', 'answer': 'gold'},
    {'question': 'A deep hole for water', 'answer': 'well'},
    {'question': 'A group working together', 'answer': 'team'},
    {'question': 'A round toy you throw or kick', 'answer': 'ball'},
    {'question': 'A law that must be followed', 'answer': 'rule'},
    {'question': 'A clear liquid you drink', 'answer': 'water'},
    {'question': 'A building where people live', 'answer': 'house'},
    {'question': 'A round red or green fruit', 'answer': 'apple'},
    {'question': 'Covers your hand in winter', 'answer': 'glove'},
    {'question': 'A tall plant with branches', 'answer': 'tree'},
    {'question': 'Calm and no fighting', 'answer': 'peace'},
    {'question': 'What you see when you sleep', 'answer': 'dream'},
    {'question': 'The planet we live on', 'answer': 'earth'},
    {'question': 'Melodies and songs', 'answer': 'music'},
    {'question': 'To exist and breathe', 'answer': 'lives'},
    {'question': 'The dark time after sunset', 'answer': 'night'},
    {'question': 'It helps you see in the dark', 'answer': 'light'},
    {'question': 'To start something new', 'answer': 'begin'},
    {'question': 'You walk on it inside a room', 'answer': 'floor'},
    {'question': 'Flowing water through the land', 'answer': 'river'},
    {'question': 'A place with flowers and plants', 'answer': 'garden'},
    {'question': 'The woman who gave you life', 'answer': 'mother'},
    {'question': 'The man who raised you', 'answer': 'father'},
    {'question': 'A place where children learn', 'answer': 'school'},
    {'question': 'The middle point of something', 'answer': 'center'},
    {'question': 'Looking at words in a book', 'answer': 'reading'},
    {'question': 'Moving fast on your feet', 'answer': 'running'},
    {'question': 'The time that has not come yet', 'answer': 'future'},
    {'question': 'Land surrounded by water', 'answer': 'islands'},
    {'question': 'Helping others learn new things', 'answer': 'teaching'},
    {'question': 'A place where goods are made', 'answer': 'factory'},
    {'question': 'A person who does a job', 'answer': 'worker'},
    {'question': 'All countries and oceans together', 'answer': 'world'},
    {'question': 'A vast body of salt water', 'answer': 'ocean'},
    {'question': 'A colorful part of a plant', 'answer': 'flower'},
    {'question': 'The ability to remember things', 'answer': 'memory'},
    {'question': 'Doing something, not just talking', 'answer': 'action'},
    {'question': 'Without any pattern or order', 'answer': 'random'},
    {'question': 'A place where you buy things', 'answer': 'market'},
    {'question': 'A section of a book', 'answer': 'chapter'},
  ];

  static final List<Map<String, String>> _arWordData = [
    {'question': 'مادة تغطي الأرض', 'answer': 'ترب'},
    {'question': 'المعرفة والتعلم', 'answer': 'علم'},
    {'question': 'أداة للكتابة', 'answer': 'قلم'},
    {'question': 'يضيء السماء ليلاً', 'answer': 'قمر'},
    {'question': 'نجم يضيء النهار', 'answer': 'شمس'},
    {'question': 'عكس الحر', 'answer': 'برد'},
    {'question': 'مساحة كبيرة من الماء المالح', 'answer': 'بحر'},
    {'question': 'سائل شفاف نشربه', 'answer': 'ماء'},
    {'question': 'ضوء يهدي في الظلام', 'answer': 'نور'},
    {'question': 'حيوان أليف ينبح', 'answer': 'كلب'},
    {'question': 'إنسان صغير في السن', 'answer': 'طفل'},
    {'question': 'زهرة جميلة ذات رائحة', 'answer': 'ورد'},
    {'question': 'حيوان يعيش في الماء', 'answer': 'سمك'},
    {'question': 'نشاط ممتع للأطفال', 'answer': 'لعب'},
    {'question': 'ما تراه وأنت نائم', 'answer': 'حلم'},
    {'question': 'فيه صفحات للقراءة', 'answer': 'كتاب'},
    {'question': 'مدخل البيت', 'answer': 'باب'},
    {'question': 'مكان تعيش فيه', 'answer': 'منزل'},
    {'question': 'ماء ينزل من السماء', 'answer': 'مطر'},
    {'question': 'حيوان يطير بأجنحة', 'answer': 'طير'},
    {'question': 'وطن أو دولة', 'answer': 'بلد'},
    {'question': 'عضو تبصر به', 'answer': 'عين'},
    {'question': 'معدن أصفر ثمين', 'answer': 'ذهب'},
    {'question': 'عكس الشر', 'answer': 'خير'},
    {'question': 'فن القوى الخفية', 'answer': 'سحر'},
    {'question': 'عضو يضخ الدم', 'answer': 'قلب'},
    {'question': 'ما تفعله لتكسب رزقك', 'answer': 'عمل'},
    {'question': 'وقت الظلام بعد الغروب', 'answer': 'ليل'},
    {'question': 'يوم فرح واحتفال', 'answer': 'عيد'},
    {'question': 'مجرى ماء طبيعي', 'answer': 'نهر'},
    {'question': 'مكان يتعلم فيه الأطفال', 'answer': 'مدرسة'},
    {'question': 'نبات كبير بأوراق خضراء', 'answer': 'شجرة'},
    {'question': 'أرض يحيطها الماء', 'answer': 'جزيرة'},
    {'question': 'مكان يعيش فيه كثير من الناس', 'answer': 'مدينة'},
    {'question': 'مكان فيه كتب للقراءة', 'answer': 'مكتبة'},
    {'question': 'مكان فيه أزهار ونباتات', 'answer': 'حديقة'},
    {'question': 'أب وأم وأولاد', 'answer': 'عائلة'},
    {'question': 'مركبة تسير على الطريق', 'answer': 'سيارة'},
    {'question': 'مسطح مائي أصغر من البحر', 'answer': 'بحيرة'},
    {'question': 'تطير في السماء وتنقل المسافرين', 'answer': 'طائرة'},
    {'question': 'مكان عبادة مسيحي', 'answer': 'كنيسة'},
    {'question': 'تحمل فيها أغراضك', 'answer': 'حقيبة'},
    {'question': 'سفر إلى مكان جديد', 'answer': 'رحلة'},
    {'question': 'تخبرك بالوقت', 'answer': 'ساعة'},
    {'question': 'لقطة بالكاميرا', 'answer': 'صورة'},
    {'question': 'مكان للتعليم العالي', 'answer': 'جامعة'},
    {'question': 'تدير شؤون البلاد', 'answer': 'حكومة'},
    {'question': 'نظام حكم يختاره الشعب', 'answer': 'جمهورية'},
    {'question': 'متعلقة بالعلم والمعرفة', 'answer': 'علمية'},
    {'question': 'لغة القرآن الكريم', 'answer': 'عربية'},
    {'question': 'جهاز إلكتروني للعمل والألعاب', 'answer': 'كمبيوتر'},
    {'question': 'علم التقنيات الحديثة', 'answer': 'تكنولوجيا'},
    {'question': 'عادات وتقاليد الشعوب', 'answer': 'ثقافة'},
    {'question': 'عكس العبودية', 'answer': 'حرية'},
    {'question': 'شعور بالفرح والرضا', 'answer': 'سعادة'},
    {'question': 'ما لا نهاية له', 'answer': 'أبدية'},
    {'question': 'خطاب مكتوب ترسله', 'answer': 'رسالة'},
    {'question': 'إدراك وفهم الأشياء', 'answer': 'معرفة'},
    {'question': 'قول مأثور فيه عبرة', 'answer': 'حكمة'},
    {'question': 'الأشجار والجبال والأنهار', 'answer': 'طبيعة'},
  ];

  static final List<Map<String, String>> _enQuizData = [
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
}
