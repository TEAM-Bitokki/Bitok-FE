import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_text_styles.dart';

enum BitokButtonVariant { primary, red, yellow, green, delete, login }

class BitokButton extends StatelessWidget {
  const BitokButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = BitokButtonVariant.primary,
  });

  /// 버튼 높이입니다. 버튼 위에 다른 요소(예: 안내 토스트)를 띄울 때 씁니다.
  static const double height = 60;

  final String label;
  final VoidCallback? onPressed;
  final BitokButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final s = _styleOf(variant, enabled: onPressed != null);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: s.background,
        borderRadius: BorderRadius.circular(s.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: s.horizontalPadding),
            child: Align(
              alignment: s.alignment,
              child: Text(
                label,
                style: s.textStyle.copyWith(color: s.foreground),
              ),
            ),
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
          alignment: _answerAlignment,
          horizontalPadding: _answerPadding,
        );
      case BitokButtonVariant.yellow:
        return const _ButtonStyle(
          background: BitokColors.yellow1,
          foreground: BitokColors.white,
          radius: 30,
          textStyle: BitokTextStyles.buttonKOR,
          alignment: _answerAlignment,
          horizontalPadding: _answerPadding,
        );
      case BitokButtonVariant.green:
        return const _ButtonStyle(
          background: BitokColors.green1,
          foreground: BitokColors.white,
          radius: 30,
          textStyle: BitokTextStyles.buttonKOR,
          alignment: _answerAlignment,
          horizontalPadding: _answerPadding,
        );
      case BitokButtonVariant.delete:
        return enabled
            ? const _ButtonStyle(
                background: BitokColors.red2,
                foreground: BitokColors.text,
                radius: 10,
                textStyle: BitokTextStyles.buttonText,
              )
            : const _ButtonStyle(
                background: BitokColors.grey2,
                foreground: BitokColors.grey0,
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

// red / yellow / green(직원 답변 버튼)은 시안처럼 글자를 왼쪽에서 30만큼 띄워 배치합니다.
const Alignment _answerAlignment = Alignment.centerLeft;
const double _answerPadding = 30;

class _ButtonStyle {
  const _ButtonStyle({
    required this.background,
    required this.foreground,
    required this.radius,
    required this.textStyle,
    this.alignment = Alignment.center,
    this.horizontalPadding = 0,
  });

  final Color background;
  final Color foreground;
  final double radius;
  final TextStyle textStyle;
  final Alignment alignment;
  final double horizontalPadding;
}

@Preview(group: 'Components', name: 'Button', size: Size(390, 620))
Widget buttonPreview() => MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    backgroundColor: BitokColors.white,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const BitokButton(label: 'Next'),
        const SizedBox(height: 12),
        BitokButton(label: 'Next', onPressed: () {}),
        const SizedBox(height: 12),
        BitokButton(
          label: '들어가요',
          variant: BitokButtonVariant.red,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        BitokButton(
          label: '모르겠어요',
          variant: BitokButtonVariant.yellow,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        BitokButton(
          label: '안 들어가요',
          variant: BitokButtonVariant.green,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        BitokButton(
          label: 'Delete Account',
          variant: BitokButtonVariant.delete,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        BitokButton(
          label: 'Get Started',
          variant: BitokButtonVariant.login,
          onPressed: () {},
        ),
      ],
    ),
  ),
);
