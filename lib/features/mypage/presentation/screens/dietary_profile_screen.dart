import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_profile_card.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// 내 식단 프로필(알레르기·식단) 요약과 각 항목의 수정 진입점입니다.
///
/// [isLoading]이면 로딩 표시를, [onRetry]를 넘기면 불러오기 실패 안내와 다시 시도 버튼을 보여줍니다.
class DietaryProfileScreen extends StatelessWidget {
  const DietaryProfileScreen({
    super.key,
    required this.allergySummary,
    required this.dietSummary,
    this.onBack,
    this.onEditAllergies,
    this.onEditDiet,
    this.isLoading = false,
    this.onRetry,
  });

  final String allergySummary;

  final String dietSummary;

  final VoidCallback? onBack;
  final VoidCallback? onEditAllergies;
  final VoidCallback? onEditDiet;

  final bool isLoading;

  /// null이 아니면 불러오기에 실패한 상태입니다.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Dietary Profile',
        onBack: onBack ?? () => Navigator.maybePop(context),
      ),
      body: SafeArea(top: false, child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final onRetry = this.onRetry;
    if (onRetry != null) {
      return _LoadFailed(onRetry: onRetry);
    }
    return ListView(
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
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.errorLoadFailed,
            style: BitokTextStyles.body1.copyWith(color: BitokColors.text),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ],
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Dietary Profile', size: Size(390, 844))
Widget dietaryProfilePreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: DietaryProfileScreen(
    allergySummary: 'Shrimp · Anchovy · Walnut',
    dietSummary: 'No particular diet',
  ),
);
