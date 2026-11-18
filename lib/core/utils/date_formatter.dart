// core/utils: 여러 feature가 공통으로 쓰는 순수 함수·확장(extension)을 모아둡니다.
// 예: 서버에서 받은 DateTime을 화면에 표시할 형태로 바꿀 때 아래 확장을 사용합니다.
//   RESULT-01 분석 결과 화면에서 `analyzedAt.toYmd()` 형태로 호출.
import 'package:intl/intl.dart';

extension DateFormatter on DateTime {
  String toYmd() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// 오늘이면 'Today', 어제면 'Yesterday', 그 외에는 'Sep 18' 형태입니다.
  /// (홈 Recent Checks, 마이페이지 Saved Menus의 부제)
  String toRelativeDayLabel({DateTime? now}) {
    final days = (now ?? DateTime.now())._utcDate.difference(_utcDate).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return DateFormat('MMM d', 'en_US').format(this);
  }

  /// 예: 'Sep 18, 2026 · 11:30' (REST-08 저장 완료 화면)
  String toDateTimeLabel() =>
      '${DateFormat('MMM d, y', 'en_US').format(this)} · '
      '${DateFormat('HH:mm', 'en_US').format(this)}';

  /// 달력 날짜만 UTC로 옮겨, DST 전환일에도 날짜 차이가 정확히 하루 단위가 되게 합니다.
  DateTime get _utcDate => DateTime.utc(year, month, day);
}
