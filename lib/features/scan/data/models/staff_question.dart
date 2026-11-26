import 'analyze_response.dart';

/// REST-06 · 직원에게 묻는 질문 한 개입니다.
///
/// 서버(POST /api/scans/{scan_id}/analyze)가 확인이 필요한 재료마다 하나씩 만들어 줍니다.
/// 한 메뉴에 질문이 여러 개일 수 있고, 질문이 없는 메뉴도 있습니다.
class StaffQuestion {
  const StaffQuestion({
    required this.id,
    required this.dishId,
    required this.ingredientId,
    required this.koreanText,
    required this.englishText,
  });

  factory StaffQuestion.fromResponse(StaffQuestionResponse response) =>
      StaffQuestion(
        id: response.questionId,
        dishId: response.dishId,
        ingredientId: response.ingredientId,
        koreanText: response.questionKo,
        englishText: response.questionEn,
      );

  /// 서버의 question_id입니다. 답변을 저장하고 서버에 보낼 때 씁니다.
  final int id;

  /// 질문 대상 메뉴입니다.
  final int dishId;
  final int ingredientId;

  /// 직원에게 보여줄 한국어 질문입니다. 예: '이 김치찌개에 새우가 들어가나요?'
  final String koreanText;

  /// 사용자에게 보여줄 영어 번역입니다. 예: 'Does this kimchi jjigae contain shrimp?'
  final String englishText;
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
