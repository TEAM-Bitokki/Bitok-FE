import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_menu_card.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_icons.dart';
import '../../../../core/design_system/bitok_text_styles.dart';

//API 미적용 작성
class CheckedMenu {
  const CheckedMenu({required this.koreanName, required this.englishName});

  final String koreanName;
  final String englishName;
}

/// 저장(북마크) 상태는 바깥에서 받습니다. ([saved], [onToggleSaved])
class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({
    super.key,
    required this.name,
    required this.info,
    required this.menus,
    this.saved = false,
    this.onBack,
    this.onToggleSaved,
    this.onForYouTap,
    this.onMenuTap,
  });

  final String name;
  final String info;
  final List<CheckedMenu> menus;
  final bool saved;

  final VoidCallback? onBack;
  final VoidCallback? onToggleSaved;
  final VoidCallback? onForYouTap;
  final ValueChanged<CheckedMenu>? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Restaurant Detail',
        onBack: onBack ?? () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: BitokTextStyles.title.copyWith(
                      color: BitokColors.text,
                    ),
                  ),
                ),
                _BookmarkButton(saved: saved, onTap: onToggleSaved),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              info,
              style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Checked Menu',
                    style: BitokTextStyles.subTitle.copyWith(
                      fontSize: 20,
                      color: BitokColors.text,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onForYouTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'For you',
                        style: BitokTextStyles.buttonText2.copyWith(
                          color: BitokColors.primary,
                        ),
                      ),
                      SvgPicture.asset(
                        BitokIcons.leftArrow20,
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            for (final menu in menus) ...[
              BitokMenuDetailCard(
                koreanName: menu.koreanName,
                englishName: menu.englishName,
                onTap: () => onMenuTap?.call(menu),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.saved, this.onTap});

  final bool saved;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SvgPicture.asset(
          saved ? BitokIcons.saveOn24 : BitokIcons.saveOff24,
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Restaurant Detail', size: Size(390, 844))
Widget restaurantDetailPreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: RestaurantDetailScreen(
    name: 'Myeongdong Kyoja',
    info: 'Korean · 350 m',
    menus: [
      CheckedMenu(koreanName: '김치찌개', englishName: 'Kimchi Jjigae'),
      CheckedMenu(koreanName: '비빔밥', englishName: 'Bibimbap'),
      CheckedMenu(koreanName: '불고기', englishName: 'Bulgogi'),
    ],
  ),
);