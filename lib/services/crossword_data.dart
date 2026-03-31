/// Crossword / Word Search puzzle data organized by themed categories
class CrosswordCategory {
  final String id;
  final String name;
  final String emoji;
  final List<String> words;

  const CrosswordCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.words,
  });
}

class CrosswordData {
  static List<CrosswordCategory> getCategories(String language) {
    return language == 'ar' ? _categoriesAr : _categoriesEn;
  }

  static const List<CrosswordCategory> _categoriesEn = [
    CrosswordCategory(id: 'countries', name: 'Countries', emoji: '🌍', words: ['EGYPT', 'FRANCE', 'JAPAN', 'BRAZIL', 'INDIA', 'CHINA', 'SPAIN', 'ITALY', 'CANADA', 'MEXICO', 'KOREA', 'TURKEY', 'RUSSIA', 'GERMANY', 'GREECE']),
    CrosswordCategory(id: 'colors', name: 'Colors', emoji: '🎨', words: ['RED', 'BLUE', 'GREEN', 'YELLOW', 'ORANGE', 'PURPLE', 'PINK', 'BLACK', 'WHITE', 'BROWN', 'GRAY', 'GOLD', 'SILVER', 'VIOLET', 'CORAL']),
    CrosswordCategory(id: 'fruits', name: 'Fruits', emoji: '🍎', words: ['APPLE', 'BANANA', 'ORANGE', 'GRAPE', 'MANGO', 'PEACH', 'LEMON', 'CHERRY', 'MELON', 'BERRY', 'PLUM', 'KIWI', 'PEAR', 'FIG', 'DATE']),
    CrosswordCategory(id: 'animals', name: 'Animals', emoji: '🦁', words: ['LION', 'TIGER', 'EAGLE', 'HORSE', 'SHARK', 'WHALE', 'SNAKE', 'BEAR', 'WOLF', 'DEER', 'DUCK', 'FROG', 'FISH', 'CROW', 'GOAT']),
    CrosswordCategory(id: 'food', name: 'Food', emoji: '🍕', words: ['PIZZA', 'BREAD', 'RICE', 'PASTA', 'SALAD', 'SOUP', 'CAKE', 'STEAK', 'EGGS', 'FISH', 'CORN', 'BEANS', 'NUTS', 'MILK', 'HONEY']),
    CrosswordCategory(id: 'sports', name: 'Sports', emoji: '⚽', words: ['SOCCER', 'TENNIS', 'BOXING', 'RUGBY', 'GOLF', 'SWIM', 'RUN', 'BIKE', 'SURF', 'SKI', 'DIVE', 'YOGA', 'JUDO', 'POLO', 'DART']),
    CrosswordCategory(id: 'body', name: 'Body Parts', emoji: '🫀', words: ['HEART', 'BRAIN', 'HAND', 'FOOT', 'EYES', 'NOSE', 'MOUTH', 'EARS', 'KNEE', 'NECK', 'BACK', 'ARM', 'LEG', 'HAIR', 'SKIN']),
    CrosswordCategory(id: 'space', name: 'Space', emoji: '🚀', words: ['STAR', 'MOON', 'MARS', 'VENUS', 'EARTH', 'ORBIT', 'COMET', 'PLUTO', 'ALIEN', 'SOLAR', 'SPACE', 'LIGHT', 'RING', 'DUST', 'VOID']),
    CrosswordCategory(id: 'school', name: 'School', emoji: '📚', words: ['BOOK', 'DESK', 'MATH', 'TEST', 'READ', 'WRITE', 'CLASS', 'RULER', 'CHALK', 'GRADE', 'LEARN', 'TEACH', 'STUDY', 'PEN', 'NOTE']),
    CrosswordCategory(id: 'weather', name: 'Weather', emoji: '🌤️', words: ['RAIN', 'SNOW', 'WIND', 'STORM', 'CLOUD', 'SUNNY', 'COLD', 'WARM', 'HAIL', 'FOG', 'ICE', 'HEAT', 'COOL', 'DRY', 'WET']),
    CrosswordCategory(id: 'family', name: 'Family', emoji: '👨‍👩‍👧‍👦', words: ['MOTHER', 'FATHER', 'SISTER', 'BABY', 'AUNT', 'UNCLE', 'SON', 'WIFE', 'CHILD', 'TWIN', 'GIRL', 'BOY', 'DAD', 'MOM', 'KIN']),
    CrosswordCategory(id: 'jobs', name: 'Jobs', emoji: '👨‍💼', words: ['DOCTOR', 'NURSE', 'PILOT', 'CHEF', 'JUDGE', 'CLERK', 'DRIVER', 'ACTOR', 'GUARD', 'MINER', 'BAKER', 'COACH', 'AGENT', 'MAYOR', 'TUTOR']),
  ];

  static const List<CrosswordCategory> _categoriesAr = [
    CrosswordCategory(id: 'countries', name: 'دول', emoji: '🌍', words: ['مصر', 'فرنسا', 'اليابان', 'البرازيل', 'الهند', 'الصين', 'اسبانيا', 'ايطاليا', 'كندا', 'المكسيك', 'كوريا', 'تركيا', 'روسيا', 'المانيا', 'اليونان']),
    CrosswordCategory(id: 'colors', name: 'ألوان', emoji: '🎨', words: ['احمر', 'ازرق', 'اخضر', 'اصفر', 'برتقالي', 'بنفسجي', 'وردي', 'اسود', 'ابيض', 'بني', 'رمادي', 'ذهبي', 'فضي', 'نيلي', 'قرمزي']),
    CrosswordCategory(id: 'fruits', name: 'فواكه', emoji: '🍎', words: ['تفاح', 'موز', 'برتقال', 'عنب', 'مانجو', 'خوخ', 'ليمون', 'كرز', 'بطيخ', 'توت', 'برقوق', 'كيوي', 'كمثرى', 'تين', 'بلح']),
    CrosswordCategory(id: 'animals', name: 'حيوانات', emoji: '🦁', words: ['اسد', 'نمر', 'نسر', 'حصان', 'قرش', 'حوت', 'افعى', 'دب', 'ذئب', 'غزال', 'بطة', 'ضفدع', 'سمكة', 'غراب', 'ماعز']),
    CrosswordCategory(id: 'food', name: 'طعام', emoji: '🍕', words: ['بيتزا', 'خبز', 'ارز', 'مكرونة', 'سلطة', 'شوربة', 'كعك', 'لحم', 'بيض', 'سمك', 'ذرة', 'فول', 'مكسرات', 'حليب', 'عسل']),
    CrosswordCategory(id: 'sports', name: 'رياضة', emoji: '⚽', words: ['كرة', 'تنس', 'ملاكمة', 'سباحة', 'جولف', 'جري', 'ركوب', 'تزلج', 'غوص', 'يوغا', 'جودو', 'بولو', 'سهام', 'مصارعة', 'كاراتيه']),
    CrosswordCategory(id: 'body', name: 'أعضاء الجسم', emoji: '🫀', words: ['قلب', 'دماغ', 'يد', 'قدم', 'عين', 'انف', 'فم', 'اذن', 'ركبة', 'رقبة', 'ظهر', 'ذراع', 'ساق', 'شعر', 'جلد']),
    CrosswordCategory(id: 'space', name: 'فضاء', emoji: '🚀', words: ['نجم', 'قمر', 'مريخ', 'زهرة', 'ارض', 'مدار', 'مذنب', 'بلوتو', 'فضاء', 'شمس', 'كوكب', 'نور', 'حلقة', 'غبار', 'فراغ']),
    CrosswordCategory(id: 'school', name: 'مدرسة', emoji: '📚', words: ['كتاب', 'مكتب', 'رياضة', 'اختبار', 'قراءة', 'كتابة', 'فصل', 'مسطرة', 'طبشور', 'درجة', 'تعلم', 'علم', 'دراسة', 'قلم', 'دفتر']),
    CrosswordCategory(id: 'weather', name: 'طقس', emoji: '🌤️', words: ['مطر', 'ثلج', 'رياح', 'عاصفة', 'سحاب', 'مشمس', 'بارد', 'دافئ', 'برد', 'ضباب', 'جليد', 'حرارة', 'منعش', 'جاف', 'رطب']),
    CrosswordCategory(id: 'family', name: 'عائلة', emoji: '👨‍👩‍👧‍👦', words: ['ام', 'اب', 'اخت', 'طفل', 'عمة', 'عم', 'ابن', 'زوجة', 'ولد', 'توأم', 'بنت', 'صبي', 'جد', 'جدة', 'خال']),
    CrosswordCategory(id: 'jobs', name: 'وظائف', emoji: '👨‍💼', words: ['طبيب', 'ممرض', 'طيار', 'طباخ', 'قاضي', 'كاتب', 'سائق', 'ممثل', 'حارس', 'عامل', 'خباز', 'مدرب', 'وكيل', 'عمدة', 'معلم']),
  ];
}
