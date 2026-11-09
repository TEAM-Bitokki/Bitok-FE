/// 직원에게 확인할 재료입니다. 예: 새우(shrimp)
class StaffCheckIngredient {
  const StaffCheckIngredient({
    required this.koreanName,
    required this.englishName,
  });

  final String koreanName;
  final String englishName;
}

/// REST-06 · 메뉴에 특정 재료가 들어가는지 직원에게 묻는 질문 한 개입니다.
class StaffQuestion {
  const StaffQuestion({
    required this.itemId,
    required this.menuKoreanName,
    required this.menuEnglishName,
    required this.ingredient,
  });

  /// 질문 대상 메뉴의 id입니다.
  final String itemId;
  final String menuKoreanName;
  final String menuEnglishName;
  final StaffCheckIngredient ingredient;

  /// 답변을 저장할 때 쓰는 값입니다. 메뉴와 재료가 같으면 같은 질문으로 봅니다.
  String get id => '$itemId:${ingredient.englishName}';

  /// 직원에게 보여줄 한국어 질문입니다. 예: '이 김치찌개에 새우가 들어가나요?'
  String get koreanText =>
      '이 $menuKoreanName에 ${ingredient.koreanName}'
      '${_subjectParticle(ingredient.koreanName)} 들어가나요?';

  /// 사용자에게 보여줄 영어 번역입니다. 예: 'Does this kimchi jjigae contain shrimp?'
  String get englishText =>
      'Does this ${menuEnglishName.toLowerCase()} contain ${ingredient.englishName}?';

  /// 받침이 있으면 '이', 없으면 '가'를 붙입니다.
  static String _subjectParticle(String word) {
    if (word.isEmpty) return '가';
    final code = word.codeUnitAt(word.length - 1);
    const hangulStart = 0xAC00;
    const hangulEnd = 0xD7A3;
    if (code < hangulStart || code > hangulEnd) return '가';
    return (code - hangulStart) % 28 == 0 ? '가' : '이';
  }
}

/// 직원의 답변입니다.
enum StaffAnswer {
  /// 들어가요
  contains,

  /// 모르겠어요
  notSure,

  /// 안 들어가요
  notContains,
}
