// core/utils: 여러 feature가 공통으로 쓰는 순수 함수·확장(extension)을 모아둡니다.
// 예: 서버에서 받은 DateTime을 화면에 표시할 형태로 바꿀 때 아래 확장을 사용합니다.
//   RESULT-01 분석 결과 화면에서 `analyzedAt.toYmd()` 형태로 호출.
extension DateFormatter on DateTime {
  String toYmd() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
