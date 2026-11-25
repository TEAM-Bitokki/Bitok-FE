import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_setting_menu.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../widgets/my_page_dietary_card.dart';
import '../widgets/my_page_profile_card.dart';

//API 미적용 작성
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({
    super.key,
    required this.nickname,
    required this.dietarySummary,
    this.onBack,
    this.onProfileTap,
    this.onDietaryTap,
    this.onSavedRestaurantsTap,
    this.onSavedMenusTap,
    this.onDeleteAccountTap,
  });

  final String nickname;
  final String dietarySummary;

  final VoidCallback? onBack;
  final VoidCallback? onProfileTap;
  final VoidCallback? onDietaryTap;
  final VoidCallback? onSavedRestaurantsTap;
  final VoidCallback? onSavedMenusTap;
  final VoidCallback? onDeleteAccountTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.grey3,
      appBar: BitokHeader.sub(
        title: 'My',
        onBack: onBack ?? () => Navigator.maybePop(context),
        backgroundColor: BitokColors.grey3,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            MyPageProfileCard(nickname: nickname, onTap: onProfileTap),
            const SizedBox(height: 15),
            MyPageDietaryCard(summary: dietarySummary, onTap: onDietaryTap),
            const SizedBox(height: 25),
            const _SectionTitle('My Activity'),
            const SizedBox(height: 8),
            BitokSettingMenu(
              label: 'Saved Restaurants',
              onTap: onSavedRestaurantsTap,
            ),
            const SizedBox(height: 10),
            BitokSettingMenu(label: 'Saved Menues', onTap: onSavedMenusTap),
            const SizedBox(height: 25),
            const _SectionTitle('Settings'),
            const SizedBox(height: 8),
            BitokSettingMenu(
              label: 'Delete Account',
              labelColor: BitokColors.red1,
              onTap: onDeleteAccountTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BitokTextStyles.body1.copyWith(color: BitokColors.text),
    );
  }
}

@Preview(group: 'Screens', name: 'My Page', size: Size(390, 844))
Widget myPagePreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: MyPageScreen(
    nickname: 'Biiiiii',
    dietarySummary: '4 food allergies · Vegetarian',
  ),
);
