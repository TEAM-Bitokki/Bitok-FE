import 'package:flutter/material.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../core/design_system/bitok_colors.dart';

// TODO: HOME-01 디자인(헤더, Check a menu 카드, Recent Checks 목록)을 구현합니다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onProfileTap});

  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 임시 진입점: HOME-01 구현 시 로고를 포함한 실제 헤더로 교체합니다.
            BitokHeader.home(
              logo: const SizedBox.shrink(),
              onProfile: onProfileTap,
            ),
            const Expanded(child: Center(child: Text('Home'))),
          ],
        ),
      ),
    );
  }
}
