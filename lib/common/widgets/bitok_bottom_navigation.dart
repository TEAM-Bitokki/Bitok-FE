import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// Home과 Explore 탭을 전환하는 하단 네비게이션 바입니다.
///
/// 탭을 바꾸면 선택된 탭 뒤의 알약 모양 인디케이터가 좌우로 슬라이드됩니다.
class BitokBottomNavigation extends StatelessWidget {
  const BitokBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// 선택된 탭의 인덱스입니다. 0은 Home, 1은 Explore입니다.
  final int currentIndex;

  /// 탭을 누르면 해당 탭의 인덱스와 함께 호출됩니다.
  final ValueChanged<int> onTap;

  static const double width = 220;

  static const double height = 55;

  static const double _horizontalPadding = 12;
  static const double _pillWidth = 84;
  static const double _pillHeight = 45;
  static const Duration _animationDuration = Duration(milliseconds: 250);
  static const Curve _animationCurve = Curves.easeInOut;

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Home',
      defaultIcon: BitokIcons.homeDefault24,
      selectedIcon: BitokIcons.homeSelected24,
    ),
    _NavItem(
      label: 'Explore',
      defaultIcon: BitokIcons.exploreDefault24,
      selectedIcon: BitokIcons.exploreSelected24,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      decoration: BoxDecoration(
        color: BitokColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, -1),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedAlign(
            duration: _animationDuration,
            curve: _animationCurve,
            alignment: currentIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: _pillWidth,
              height: _pillHeight,
              decoration: BoxDecoration(
                color: BitokColors.blue3,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _items.length; i++)
                _NavButton(
                  item: _items[i],
                  isSelected: i == currentIndex,
                  width: _pillWidth,
                  height: _pillHeight,
                  duration: _animationDuration,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.defaultIcon,
    required this.selectedIcon,
  });

  final String label;
  final String defaultIcon;
  final String selectedIcon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.width,
    required this.height,
    required this.duration,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final double width;
  final double height;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: duration,
                child: SvgPicture.asset(
                  isSelected ? item.selectedIcon : item.defaultIcon,
                  key: ValueKey(isSelected),
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: duration,
                style: BitokTextStyles.navText.copyWith(
                  color: isSelected ? BitokColors.primary : BitokColors.grey0,
                ),
                child: Text(item.label, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'Common', name: 'Bottom Navigation', size: Size(300, 120))
Widget bottomNavigationPreview() => const _BottomNavigationPreview();

class _BottomNavigationPreview extends StatefulWidget {
  const _BottomNavigationPreview();

  @override
  State<_BottomNavigationPreview> createState() =>
      _BottomNavigationPreviewState();
}

class _BottomNavigationPreviewState extends State<_BottomNavigationPreview> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BitokColors.grey3,
      child: Center(
        child: BitokBottomNavigation(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
