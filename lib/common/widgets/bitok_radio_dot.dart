import 'package:flutter/material.dart';

import '../../core/design_system/bitok_colors.dart';

class BitokRadioDot extends StatelessWidget {
  const BitokRadioDot({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? BitokColors.grey0 : BitokColors.grey1,
        ),
      ),
      child: selected
          ? Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: BitokColors.grey0,
        ),
      )
          : null,
    );
  }
}