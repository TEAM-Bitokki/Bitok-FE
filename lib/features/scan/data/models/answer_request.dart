import 'package:json_annotation/json_annotation.dart';

part 'answer_request.g.dart';

/// 서버에 보내는 직원 응답 값입니다.
@JsonEnum(fieldRename: FieldRename.snake)
enum StaffAnswerValue { yes, no, unsure }

/// POST /api/scans/{scan_id}/answers 요청 body.
/// 같은 질문에 다시 보내면 마지막 답으로 바뀝니다.
@JsonSerializable(createFactory: false)
class AnswerRequest {
  const AnswerRequest({required this.questionId, required this.answer});

  final int questionId;
  final StaffAnswerValue answer;

  Map<String, dynamic> toJson() => _$AnswerRequestToJson(this);
}
