import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_menu_card.dart';
import '../../../../common/widgets/bitok_status_chip.dart';
import '../../../../core/design_system/bitok_colors.dart';

//API 미적용 작성
class SavedMenu {
  const SavedMenu({
    required this.menuId,
    required this.koreanName,
    required this.englishName,
    required this.subtitle,
    required this.status,
  });

  /// 메뉴 상세('/menu/:id')로 이동할 때 쓰는 id입니다.
  final String menuId;
  final String koreanName;
  final String englishName;

  final String subtitle;
  final BitokMenuStatus status;
}

class SavedMenusScreen extends StatelessWidget {
  const SavedMenusScreen({
    super.key,
    required this.menus,
    this.onBack,
    this.onMenuTap,
  });

  final List<SavedMenu> menus;
  final VoidCallback? onBack;
  final ValueChanged<SavedMenu>? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Saved Menues',
        onBack: onBack ?? () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          itemCount: menus.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final menu = menus[index];
            return BitokRecentMenuCard(
              koreanName: menu.koreanName,
              englishName: menu.englishName,
              subtitle: menu.subtitle,
              status: menu.status,
              onTap: () => onMenuTap?.call(menu),
            );
          },
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Saved Menus', size: Size(390, 844))
Widget savedMenusPreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: SavedMenusScreen(
    menus: [
      SavedMenu(
        menuId: 'bibimbap',
        koreanName: '비빔밥',
        englishName: 'Bibimbap',
        subtitle: 'Myeongdong Kyoja · Today',
        status: BitokMenuStatus.safe,
      ),
      SavedMenu(
        menuId: 'kimchi-jjigae',
        koreanName: '김치찌개',
        englishName: 'Kimchi Jjigae',
        subtitle: 'Myeongdong Kyoja · Today',
        status: BitokMenuStatus.avoid,
      ),
      SavedMenu(
        menuId: 'bulgogi',
        koreanName: '불고기',
        englishName: 'Bulgogi',
        subtitle: 'Myeongdong Kyoja · Today',
        status: BitokMenuStatus.notSure,
      ),
    ],
  ),
);
