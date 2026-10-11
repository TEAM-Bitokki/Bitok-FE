import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets/bitok_bottom_navigation.dart';

/// 바텀 네비게이션이 있는 탭 화면(Home, Explore)을 감싸는 셸입니다.
///
/// 네비게이션 바는 화면 콘텐츠 위에 떠 있으며, 하단 안전 영역으로부터 10만큼 떨어져 있습니다.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const double _bottomNavigationGap = 10;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: navigationShell),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: _bottomNavigationGap),
              child: Center(
                child: BitokBottomNavigation(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) => navigationShell.goBranch(
                    index,
                    // 현재 탭을 다시 누르면 해당 탭의 첫 화면으로 돌아갑니다.
                    initialLocation: index == navigationShell.currentIndex,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
