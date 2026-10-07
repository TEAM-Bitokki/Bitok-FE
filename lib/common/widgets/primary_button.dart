import 'package:flutter/material.dart';

import '../../core/design_system/bitok_colors.dart';

// common/widgets: 특정 feature에 속하지 않고 여러 화면에서 재사용하는 공용 위젯입니다.
// 예: 온보딩(ONB-05 프로필 확인), 결과 화면(RESULT-05) 등에서 같은 스타일의 버튼이
// 필요할 때마다 새로 만들지 않고 이 위젯을 재사용합니다.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: BitokColors.primary),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
