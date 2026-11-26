import '../../../../common/widgets/bitok_status_chip.dart';

/// 서버 판정값(avoid, safe, not_sure)을 화면 상태로 바꿉니다. 없거나 모르는 값은 Not Sure입니다.
BitokMenuStatus menuStatusOfVerdict(String? verdict) => switch (verdict) {
  'avoid' => BitokMenuStatus.avoid,
  'safe' => BitokMenuStatus.safe,
  _ => BitokMenuStatus.notSure,
};