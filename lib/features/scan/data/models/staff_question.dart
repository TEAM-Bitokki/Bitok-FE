/// 직원에게 확인할 재료입니다. 예: 새우(shrimp)
class StaffCheckIngredient {
  const StaffCheckIngredient({
    required this.koreanName,
    required this.englishName,
  });

  final String koreanName;
  final String englishName;
}

/// REST-06 · 메뉴 한 개에 대해 직원에게 묻는 질문입니다.
///
/// REST-05에서 고른 메뉴마다 질문이 한 개씩 만들어지며,
/// 확인할 재료가 여러 개면 한 질문에 묶어서 묻습니다.
class StaffQuestion {
  const StaffQuestion({
    required this.itemId,
    required this.menuKoreanName,
    required this.menuEnglishName,
    required this.ingredients,
  });

  /// 질문 대상 메뉴의 id입니다. 메뉴당 질문이 한 개라 질문 id로도 씁니다.
  final String itemId;
  final String menuKoreanName;
  final String menuEnglishName;

  /// 확인할 재료 목록입니다. 비어 있지 않아야 합니다.
  final List<StaffCheckIngredient> ingredients;

  /// 답변을 저장할 때 쓰는 값입니다.
  String get id => itemId;

  /// 직원에게 보여줄 한국어 질문입니다.
  /// 예: '이 김치찌개에 새우나 멸치가 들어가나요?'
  String get koreanText {
    final names = ingredients.map((ingredient) => ingredient.koreanName);
    final buffer = StringBuffer();
    for (final (index, name) in names.indexed) {
      buffer.write(name);
      // 마지막 재료 뒤에는 '이/가', 그 앞의 재료 뒤에는 '이나/나'를 붙입니다.
      buffer.write(
        index == names.length - 1
            ? (_hasFinalConsonant(name) ? '이' : '가')
            : (_hasFinalConsonant(name) ? '이나 ' : '나 '),
      );
    }
    return '이 $menuKoreanName에 $buffer 들어가나요?';
  }

  /// 사용자에게 보여줄 영어 번역입니다.
  /// 예: 'Does this kimchi jjigae contain shrimp or anchovy?'
  String get englishText {
    final names = ingredients.map((ingredient) => ingredient.englishName);
    final joined = names.length == 1
        ? names.single
        : '${names.take(names.length - 1).join(', ')} or ${names.last}';
    return 'Does this ${menuEnglishName.toLowerCase()} contain $joined?';
  }

  /// 마지막 글자에 받침이 있는지 확인합니다. 한글이 아니면 받침이 없는 것으로 봅니다.
  static bool _hasFinalConsonant(String word) {
    if (word.isEmpty) return false;
    final code = word.codeUnitAt(word.length - 1);
    const hangulStart = 0xAC00;
    const hangulEnd = 0xD7A3;
    if (code < hangulStart || code > hangulEnd) return false;
    return (code - hangulStart) % 28 != 0;
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
