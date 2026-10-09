import 'package:flutter/material.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_text_styles.dart';

enum BitokStatus {
  avoid,
  notSure,
}

class BitokStatusCard extends StatelessWidget {
  const BitokStatusCard({
    super.key,
    required this.status,
    required this.ingredient,
    this.label,
  });

  final BitokStatus status;

  final String ingredient;

  final String? label;

  @override
  Widget build(BuildContext context) {
    final isAvoid = status == BitokStatus.avoid;
    final background = isAvoid ? BitokColors.red2 : BitokColors.yellow2;
    final labelColor = isAvoid ? BitokColors.red0 : BitokColors.yellow0;
    final defaultLabel = isAvoid ? 'Avoid' : 'Not Sure';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label ?? defaultLabel,
            style: BitokTextStyles.body1.copyWith(color: labelColor),
          ),
          const SizedBox(height: 6),
          Text(
            ingredient,
            style: BitokTextStyles.body2.copyWith(color: BitokColors.text),
          ),
        ],
      ),
    );
  }
}