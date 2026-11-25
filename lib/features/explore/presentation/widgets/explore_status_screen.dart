import 'package:flutter/material.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ExploreLoadingScreen extends StatelessWidget {
  const ExploreLoadingScreen({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: title,
        onBack: onBack ?? () => Navigator.maybePop(context),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class ExploreErrorScreen extends StatelessWidget {
  const ExploreErrorScreen({
    super.key,
    required this.title,
    this.onBack,
    this.onRetry,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: title,
        onBack: onBack ?? () => Navigator.maybePop(context),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).errorLoadFailed,
              style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}