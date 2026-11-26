import 'package:flutter/material.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// 화면 하단에 잠깐 떠 있는 안내(토스트)를 띄웁니다. 이미 떠 있는 안내는 바로 닫습니다.
///
/// 위치: 화면 하단 안전 영역 위로 [bottomOffset] + [gap]만큼 떨어진 곳에 안내 아래쪽 끝이 옵니다.
/// - [bottomOffset]: 안내가 가리면 안 되는 하단 요소(버튼, 네비게이션 바)의 높이.
///   안전 영역 위부터 그 요소 윗변까지 잽니다. (안전 영역 높이는 Scaffold가 알아서 더합니다)
/// - [gap]: 그 요소와 안내 사이 간격.
void showBitokToast(
  BuildContext context,
  String message, {
  double bottomOffset = 0,
  double gap = bitokToastGap,
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(24, 0, 24, bottomOffset + gap),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: BitokTextStyles.body2.copyWith(color: BitokColors.white),
        ),
      ),
    );
}

/// 토스트와 그 아래 하단 요소 사이의 기본 간격입니다.
const double bitokToastGap = 8;
