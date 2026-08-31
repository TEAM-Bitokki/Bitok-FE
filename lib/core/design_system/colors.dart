import 'package:flutter/material.dart';

// core/design_system: 색상·타이포그래피 등 앱 전체가 공유하는 디자인 토큰을 모아둡니다.
// 예: features/*의 화면 코드는 Color(0x...)를 직접 쓰지 않고 AppColors.primary를 참조해
// 브랜드 컬러(BitOK Blue)를 어디서나 동일하게 유지합니다.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF3DADFF); // BitOK Blue
}
