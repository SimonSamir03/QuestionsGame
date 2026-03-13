/// Crossword / Word Search puzzle data organized by themed categories
class CrosswordCategory {
  final String id;
  final String nameEn;
  final String nameAr;
  final String emoji;
  final List<String> wordsEn;
  final List<String> wordsAr;

  const CrosswordCategory({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.emoji,
    required this.wordsEn,
    required this.wordsAr,
  });

  List<String> getWords(String language) => language == 'ar' ? wordsAr : wordsEn;
}

class CrosswordData {
  static const List<CrosswordCategory> categories = [
    CrosswordCategory(
      id: 'countries',
      nameEn: 'Countries',
      nameAr: 'دول',
      emoji: '🌍',
      wordsEn: ['EGYPT', 'FRANCE', 'JAPAN', 'BRAZIL', 'INDIA', 'CHINA', 'SPAIN', 'ITALY', 'CANADA', 'MEXICO', 'KOREA', 'TURKEY', 'RUSSIA', 'GERMANY', 'GREECE'],
      wordsAr: ['مصر', 'فرنسا', 'اليابان', 'البرازيل', 'الهند', 'الصين', 'اسبانيا', 'ايطاليا', 'كندا', 'المكسيك', 'كوريا', 'تركيا', 'روسيا', 'المانيا', 'اليونان'],
    ),
    CrosswordCategory(
      id: 'colors',
      nameEn: 'Colors',
      nameAr: 'ألوان',
      emoji: '🎨',
      wordsEn: ['RED', 'BLUE', 'GREEN', 'YELLOW', 'ORANGE', 'PURPLE', 'PINK', 'BLACK', 'WHITE', 'BROWN', 'GRAY', 'GOLD', 'SILVER', 'VIOLET', 'CORAL'],
      wordsAr: ['احمر', 'ازرق', 'اخضر', 'اصفر', 'برتقالي', 'بنفسجي', 'وردي', 'اسود', 'ابيض', 'بني', 'رمادي', 'ذهبي', 'فضي', 'نيلي', 'قرمزي'],
    ),
    CrosswordCategory(
      id: 'fruits',
      nameEn: 'Fruits',
      nameAr: 'فواكه',
      emoji: '🍎',
      wordsEn: ['APPLE', 'BANANA', 'ORANGE', 'GRAPE', 'MANGO', 'PEACH', 'LEMON', 'CHERRY', 'MELON', 'BERRY', 'PLUM', 'KIWI', 'PEAR', 'FIG', 'DATE'],
      wordsAr: ['تفاح', 'موز', 'برتقال', 'عنب', 'مانجو', 'خوخ', 'ليمون', 'كرز', 'بطيخ', 'توت', 'برقوق', 'كيوي', 'كمثرى', 'تين', 'بلح'],
    ),
    CrosswordCategory(
      id: 'animals',
      nameEn: 'Animals',
      nameAr: 'حيوانات',
      emoji: '🦁',
      wordsEn: ['LION', 'TIGER', 'EAGLE', 'HORSE', 'SHARK', 'WHALE', 'SNAKE', 'BEAR', 'WOLF', 'DEER', 'DUCK', 'FROG', 'FISH', 'CROW', 'GOAT'],
      wordsAr: ['اسد', 'نمر', 'نسر', 'حصان', 'قرش', 'حوت', 'افعى', 'دب', 'ذئب', 'غزال', 'بطة', 'ضفدع', 'سمكة', 'غراب', 'ماعز'],
    ),
    CrosswordCategory(
      id: 'food',
      nameEn: 'Food',
      nameAr: 'طعام',
      emoji: '🍕',
      wordsEn: ['PIZZA', 'BREAD', 'RICE', 'PASTA', 'SALAD', 'SOUP', 'CAKE', 'STEAK', 'EGGS', 'FISH', 'CORN', 'BEANS', 'NUTS', 'MILK', 'HONEY'],
      wordsAr: ['بيتزا', 'خبز', 'ارز', 'مكرونة', 'سلطة', 'شوربة', 'كعك', 'لحم', 'بيض', 'سمك', 'ذرة', 'فول', 'مكسرات', 'حليب', 'عسل'],
    ),
    CrosswordCategory(
      id: 'sports',
      nameEn: 'Sports',
      nameAr: 'رياضة',
      emoji: '⚽',
      wordsEn: ['SOCCER', 'TENNIS', 'BOXING', 'RUGBY', 'GOLF', 'SWIM', 'RUN', 'BIKE', 'SURF', 'SKI', 'DIVE', 'YOGA', 'JUDO', 'POLO', 'DART'],
      wordsAr: ['كرة', 'تنس', 'ملاكمة', 'سباحة', 'جولف', 'جري', 'ركوب', 'تزلج', 'غوص', 'يوغا', 'جودو', 'بولو', 'سهام', 'مصارعة', 'كاراتيه'],
    ),
    CrosswordCategory(
      id: 'body',
      nameEn: 'Body Parts',
      nameAr: 'أعضاء الجسم',
      emoji: '🫀',
      wordsEn: ['HEART', 'BRAIN', 'HAND', 'FOOT', 'EYES', 'NOSE', 'MOUTH', 'EARS', 'KNEE', 'NECK', 'BACK', 'ARM', 'LEG', 'HAIR', 'SKIN'],
      wordsAr: ['قلب', 'دماغ', 'يد', 'قدم', 'عين', 'انف', 'فم', 'اذن', 'ركبة', 'رقبة', 'ظهر', 'ذراع', 'ساق', 'شعر', 'جلد'],
    ),
    CrosswordCategory(
      id: 'space',
      nameEn: 'Space',
      nameAr: 'فضاء',
      emoji: '🚀',
      wordsEn: ['STAR', 'MOON', 'MARS', 'VENUS', 'EARTH', 'ORBIT', 'COMET', 'PLUTO', 'ALIEN', 'SOLAR', 'SPACE', 'LIGHT', 'RING', 'DUST', 'VOID'],
      wordsAr: ['نجم', 'قمر', 'مريخ', 'زهرة', 'ارض', 'مدار', 'مذنب', 'بلوتو', 'فضاء', 'شمس', 'كوكب', 'نور', 'حلقة', 'غبار', 'فراغ'],
    ),
    CrosswordCategory(
      id: 'school',
      nameEn: 'School',
      nameAr: 'مدرسة',
      emoji: '📚',
      wordsEn: ['BOOK', 'DESK', 'MATH', 'TEST', 'READ', 'WRITE', 'CLASS', 'RULER', 'CHALK', 'GRADE', 'LEARN', 'TEACH', 'STUDY', 'PEN', 'NOTE'],
      wordsAr: ['كتاب', 'مكتب', 'رياضة', 'اختبار', 'قراءة', 'كتابة', 'فصل', 'مسطرة', 'طبشور', 'درجة', 'تعلم', 'علم', 'دراسة', 'قلم', 'دفتر'],
    ),
    CrosswordCategory(
      id: 'weather',
      nameEn: 'Weather',
      nameAr: 'طقس',
      emoji: '🌤️',
      wordsEn: ['RAIN', 'SNOW', 'WIND', 'STORM', 'CLOUD', 'SUNNY', 'COLD', 'WARM', 'HAIL', 'FOG', 'ICE', 'HEAT', 'COOL', 'DRY', 'WET'],
      wordsAr: ['مطر', 'ثلج', 'رياح', 'عاصفة', 'سحاب', 'مشمس', 'بارد', 'دافئ', 'برد', 'ضباب', 'جليد', 'حرارة', 'منعش', 'جاف', 'رطب'],
    ),
    CrosswordCategory(
      id: 'family',
      nameEn: 'Family',
      nameAr: 'عائلة',
      emoji: '👨‍👩‍👧‍👦',
      wordsEn: ['MOTHER', 'FATHER', 'SISTER', 'BABY', 'AUNT', 'UNCLE', 'SON', 'WIFE', 'CHILD', 'TWIN', 'GIRL', 'BOY', 'DAD', 'MOM', 'KIN'],
      wordsAr: ['ام', 'اب', 'اخت', 'طفل', 'عمة', 'عم', 'ابن', 'زوجة', 'ولد', 'توأم', 'بنت', 'صبي', 'جد', 'جدة', 'خال'],
    ),
    CrosswordCategory(
      id: 'jobs',
      nameEn: 'Jobs',
      nameAr: 'وظائف',
      emoji: '👨‍💼',
      wordsEn: ['DOCTOR', 'NURSE', 'PILOT', 'CHEF', 'JUDGE', 'CLERK', 'DRIVER', 'ACTOR', 'GUARD', 'MINER', 'BAKER', 'COACH', 'AGENT', 'MAYOR', 'TUTOR'],
      wordsAr: ['طبيب', 'ممرض', 'طيار', 'طباخ', 'قاضي', 'كاتب', 'سائق', 'ممثل', 'حارس', 'عامل', 'خباز', 'مدرب', 'وكيل', 'عمدة', 'معلم'],
    ),
  ];
}
