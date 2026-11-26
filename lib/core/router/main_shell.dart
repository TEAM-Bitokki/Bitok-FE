import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets/bitok_bottom_navigation.dart';
import '../../common/widgets/double_back_to_exit.dart';

/// 바텀 네비게이션이 있는 탭 화면(Home, Explore)을 감싸는 셸입니다.
///
/// 네비게이션 바는 화면 콘텐츠 위에 떠 있으며, 하단 안전 영역으로부터 10만큼 떨어져 있습니다.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const double _bottomNavigationGap = 10;

  /// 네비게이션 바가 안전 영역 위로 차지하는 높이입니다. 탭 화면의 스크롤 하단 여백에 사용합니다.
  static const double contentBottomInset =
      BitokBottomNavigation.height + _bottomNavigationGap;

  /// '한 번 더 누르면 종료' 안내와 네비게이션 바 사이 간격입니다. 이 값을 바꾸면 안내 위치가 바뀝니다.
  static const double exitToastGap = 8;

  @override
  Widget build(BuildContext context) {
    // 탭 화면은 돌아갈 화면이 없어서 뒤로 가기를 누르면 앱이 종료됩니다.
    // 실수로 나가지 않도록 한 번 더 눌러야 종료되게 하고, 안내는 네비게이션 바 바로 위에 띄웁니다.
    // (contentBottomInset = 안전 영역 위 간격 10 + 네비게이션 바 높이. 안전 영역은 Scaffold가 더합니다)
    return DoubleBackToExit(
      bottomOffset: contentBottomInset,
      gap: exitToastGap,
      child: _buildShell(),
    );
  }

  Widget _buildShell() {
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
