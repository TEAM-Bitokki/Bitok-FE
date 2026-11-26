import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_status_card.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';

//API 미적용 작성
/// 메뉴에 흔히 들어가는 재료 한 묶음입니다. 예: Fish — Anchovy sauce, Anchovy broth
class CommonIngredient {
  const CommonIngredient({required this.category, required this.items});

  final String category;
  final List<String> items;
}

/// 메뉴 상세 화면에 보여줄 정보입니다.
class MenuDetail {
  const MenuDetail({
    required this.englishName,
    this.avoidIngredients = const [],
    this.notSureIngredients = const [],
    this.commonIngredients = const [],
  });

  final String englishName;

  /// 사용자 프로필 기준으로 피해야 하는 재료입니다. 비어 있으면 Avoid 카드를 숨깁니다.
  final List<String> avoidIngredients;

  /// 확인이 필요한 재료입니다. 비어 있으면 Not Sure 카드를 숨깁니다.
  final List<String> notSureIngredients;

  final List<CommonIngredient> commonIngredients;
}

/// Menu Detail
///
/// 개인화 메뉴 리스트의 'View details'에서 들어옵니다.
class MenuDetailScreen extends StatelessWidget {
  const MenuDetailScreen({super.key, required this.menu, this.onBack});

  /// 화면 제목입니다. 불러오는 중·오류 화면도 같은 제목을 씁니다.
  static const String title = 'Menu Detail';

  final MenuDetail menu;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: title,
        onBack: onBack ?? () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            Text(
              menu.englishName,
              style: BitokTextStyles.title.copyWith(color: BitokColors.text),
            ),
            const SizedBox(height: 15),
            if (menu.avoidIngredients.isNotEmpty) ...[
              BitokStatusCard(
                status: BitokStatus.avoid,
                ingredient: menu.avoidIngredients.join(' · '),
              ),
              const SizedBox(height: 10),
            ],
            if (menu.notSureIngredients.isNotEmpty) ...[
              BitokStatusCard(
                status: BitokStatus.notSure,
                ingredient: menu.notSureIngredients.join(' · '),
              ),
              const SizedBox(height: 10),
            ],
            if (menu.commonIngredients.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Common Ingredients',
                style: BitokTextStyles.subTitle.copyWith(
                  color: BitokColors.text,
                ),
              ),
              const SizedBox(height: 15),
              _CommonIngredientsCard(ingredients: menu.commonIngredients),
              const SizedBox(height: 8),
              Text(
                'Ingredients may vary by restaurant.',
                style: BitokTextStyles.body3.copyWith(color: BitokColors.grey0),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommonIngredientsCard extends StatelessWidget {
  const _CommonIngredientsCard({required this.ingredients});

  final List<CommonIngredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.77,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
        decoration: BoxDecoration(
          color: BitokColors.grey3,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            for (final ingredient in ingredients)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.category,
                    style: BitokTextStyles.body1.copyWith(
                      color: BitokColors.text,
                    ),
                  ),
                  Text(
                    ingredient.items.join(' · '),
                    style: BitokTextStyles.body2.copyWith(
                      color: BitokColors.text,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Menu Detail', size: Size(390, 844))
Widget menuDetailPreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: MenuDetailScreen(
    menu: MenuDetail(
      englishName: 'Kimchi Jjigae',
      avoidIngredients: ['Shrimp'],
      notSureIngredients: ['Shrimp'],
      commonIngredients: [
        CommonIngredient(
          category: 'Crustacean Shellfish',
          items: ['Salted shrimp'],
        ),
        CommonIngredient(
          category: 'Fish',
          items: ['Anchovy sauce', 'Anchovy broth'],
        ),
        CommonIngredient(category: 'Soybeans', items: ['Tofu', 'Soy sauce']),
        CommonIngredient(
          category: 'Wheat',
          items: ['Some soy sauces and seasonings'],
        ),
      ],
    ),
  ),
);
