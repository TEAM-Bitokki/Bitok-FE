import 'package:flutter/material.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_text_styles.dart';

enum BitokButtonVariant {
  primary,
  red,
  yellow,
  green,
  delete,
  login,
}

class BitokButton extends StatelessWidget {
  const BitokButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = BitokButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final BitokButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final s = _styleOf(variant, enabled: onPressed != null);

    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Material(
        color: s.background,
        borderRadius: BorderRadius.circular(s.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Text(label, style: s.textStyle.copyWith(color: s.foreground)),
          ),
        ),
      ),
    );
  }

  _ButtonStyle _styleOf(BitokButtonVariant v, {required bool enabled}) {
    switch (v) {
      case BitokButtonVariant.primary:
        return enabled
            ? const _ButtonStyle(
          background: BitokColors.primary,
          foreground: BitokColors.white,
          radius: 10,
          textStyle: BitokTextStyles.buttonText,
        )
            : const _ButtonStyle(
          background: BitokColors.grey2,
          foreground: BitokColors.grey0,
          radius: 10,
          textStyle: BitokTextStyles.buttonText,
        );
      case BitokButtonVariant.red:
        return const _ButtonStyle(
          background: BitokColors.red1,
          foreground: BitokColors.white,
          radius: 30,
          textStyle: BitokTextStyles.buttonKOR,
        );
      case BitokButtonVariant.yellow:
        return const _ButtonStyle(
          background: BitokColors.yellow1,
          foreground: BitokColors.white,
          radius: 30,
          textStyle: BitokTextStyles.buttonKOR,
        );
      case BitokButtonVariant.green:
        return const _ButtonStyle(
          background: BitokColors.green1,
          foreground: BitokColors.white,
          radius: 30,
          textStyle: BitokTextStyles.buttonKOR,
        );
      case BitokButtonVariant.delete:
        return _ButtonStyle(
          background: BitokColors.red2,
          foreground: BitokColors.text,
          radius: 10,
          textStyle: BitokTextStyles.buttonText,
        );
      case BitokButtonVariant.login:
        return const _ButtonStyle(
          background: BitokColors.primary,
          foreground: BitokColors.white,
          radius: 30,
          textStyle: BitokTextStyles.buttonText,
        );
    }
  }
}

class _ButtonStyle {
  const _ButtonStyle({
    required this.background,
    required this.foreground,
    required this.radius,
    required this.textStyle,
  });

  final Color background;
  final Color foreground;
  final double radius;
  final TextStyle textStyle;
}