import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_menu_card.dart';
import '../../../../common/widgets/bitok_status_chip.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';

class PersonalizedMenu {
  const PersonalizedMenu({
    required this.dishId,
    required this.koreanName,
    required this.englishName,
    required this.status,
  });

  final int dishId;
  final String koreanName;
  final String englishName;
  final BitokMenuStatus status;
}

class PersonalizedMenuListScreen extends StatelessWidget {
  const PersonalizedMenuListScreen({
    super.key,
    required this.menus,
    this.onBack,
    this.onMenuTap,
  });

  final List<PersonalizedMenu> menus;
  final VoidCallback? onBack;

  /// 'View details' 또는 카드를 누르면 호출됩니다. (메뉴 상세로 이동)
  final ValueChanged<PersonalizedMenu>? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Personalized Menu List',
        onBack: onBack ?? () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            Text(
              'Menu for you',
              style: BitokTextStyles.title.copyWith(color: BitokColors.text),
            ),
            const SizedBox(height: 3),
            Text(
              'Matched to your dietary profile',
              style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
            ),
            const SizedBox(height: 25),
            for (final menu in menus) ...[
              BitokMenuDetailCard(
                koreanName: menu.koreanName,
                englishName: menu.englishName,
                status: menu.status,
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
