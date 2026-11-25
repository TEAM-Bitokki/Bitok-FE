import '../../../../common/widgets/bitok_status_chip.dart';

BitokMenuStatus menuStatusOfVerdict(String verdict) => switch (verdict) {
  'avoid' => BitokMenuStatus.avoid,
  'safe' => BitokMenuStatus.safe,
  _ => BitokMenuStatus.notSure,
};