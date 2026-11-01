import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_profile_card.dart';
import '../../../../core/design_system/bitok_colors.dart';

//API 미적용 작성
class DietaryProfileScreen extends StatelessWidget {
  const DietaryProfileScreen({
    super.key,
    required this.allergySummary,
    required this.dietSummary,
    this.onBack,
    this.onEditAllergies,
    this.onEditDiet,
  });

  final String allergySummary;

  final String dietSummary;

  final VoidCallback? onBack;
  final VoidCallback? onEditAllergies;
  final VoidCallback? onEditDiet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Dietary Profile',
        onBack: onBack ?? () => Navigator.maybePop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          BitokProfileCard(
            title: 'Food Allergies',
            description: allergySummary,
            onEdit: onEditAllergies,
          ),
          const SizedBox(height: 12),
          BitokProfileCard(
            title: 'Dietary Preference',
            description: dietSummary,
            onEdit: onEditDiet,
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Dietary Profile', size: Size(390, 844))
Widget dietaryProfilePreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: DietaryProfileScreen(
    allergySummary: 'Shrimp · Anchovy · Walnut',
    dietSummary: 'No particular diet',
  ),
);
