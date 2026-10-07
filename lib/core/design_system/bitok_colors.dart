import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'bitok_text_styles.dart';

class BitokColors {
  const BitokColors._();

  /// Primary
  static const Color primary = Color(0xFF3DADFF);

  /// Blue
  static const Color blue1 = Color(0xFF78C6FF);
  static const Color blue2 = Color(0xFFEAF5FF);
  static const Color blue3 = Color(0x99E3F1FF);

  /// Neutral
  static const Color text = Color(0xFF151922);
  static const Color grey0 = Color(0xFF6B7585);
  static const Color grey1 = Color(0xFFE0E5ED);
  static const Color grey2 = Color(0xFFEFF1F6);
  static const Color grey3 = Color(0xFFF6F7FA);

  /// Red
  static const Color red0 = Color(0xFF76382B);
  static const Color red1 = Color(0xFFFF7556);
  static const Color red2 = Color(0xFFFFD4CC);
  static const Color red3 = Color(0xFFFCF2F2);

  /// Green
  static const Color green1 = Color(0xFF66D575);
  static const Color green2 = Color(0xFFD1F5D6);

  /// Yellow
  static const Color yellow0 = Color(0xFF8C5C05);
  static const Color yellow1 = Color(0xFFFFC943);
  static const Color yellow2 = Color(0xFFFFEDB8);

  /// Static
  static const Color white = Color(0xFFFFFFFF);
}

@Preview(group: 'Design System', name: 'Color Guide', size: Size(1200, 1000))
Widget colorGuidePreview() => const _GuidePage(
  title: 'Color',
  description: '비톡의 일관된 시각 경험을 위한\n컬러 시스템입니다.',
  panelTitle: '컬러 정의',
  child: _ColorGuide(),
);

const Color _canvasColor = Color(0xFFE9E9E9);

const TextStyle _koreanLabel = TextStyle(
  fontFamily: 'Pretendard',
  fontWeight: FontWeight.w500,
  color: BitokColors.text,
);

class _GuidePage extends StatelessWidget {
  const _GuidePage({
    required this.title,
    required this.description,
    required this.panelTitle,
    required this.child,
  });

  final String title;
  final String description;
  final String panelTitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final introCard = Container(
      width: 300,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: BitokColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: BitokTextStyles.title.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: BitokColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: _koreanLabel.copyWith(
              fontSize: 12,
              height: 1.5,
              color: BitokColors.grey0,
            ),
          ),
        ],
      ),
    );

    final panel = Container(
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 40),
      decoration: BoxDecoration(
        color: BitokColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            panelTitle,
            style: _koreanLabel.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(height: 1, thickness: 1.5, color: BitokColors.text),
          const SizedBox(height: 40),
          child,
        ],
      ),
    );

    return ColoredBox(
      color: _canvasColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(48),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [introCard, const SizedBox(height: 32), panel],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                introCard,
                const SizedBox(width: 96),
                Expanded(child: panel),
              ],
            );
          },
        ),
      ),
    );
  }
}

typedef _ColorToken = (String name, Color color);

class _ColorGuide extends StatelessWidget {
  const _ColorGuide();

  static const List<(String, List<_ColorToken>)> _groups = [
    (
      'Primary & Blue',
      [
        ('Primary', BitokColors.primary),
        ('Blue1', BitokColors.blue1),
        ('Blue2', BitokColors.blue2),
        ('Blue3', BitokColors.blue3),
      ],
    ),
    (
      'Neutral',
      [
        ('Text', BitokColors.text),
        ('Grey0', BitokColors.grey0),
        ('Grey1', BitokColors.grey1),
        ('Grey2', BitokColors.grey2),
        ('Grey3', BitokColors.grey3),
      ],
    ),
    (
      'Red',
      [
        ('Red0', BitokColors.red0),
        ('Red1', BitokColors.red1),
        ('Red2', BitokColors.red2),
        ('Red3', BitokColors.red3),
      ],
    ),
    (
      'Green & Yellow',
      [
        ('Green1', BitokColors.green1),
        ('Green2', BitokColors.green2),
        ('Yellow0', BitokColors.yellow0),
        ('Yellow1', BitokColors.yellow1),
        ('Yellow2', BitokColors.yellow2),
      ],
    ),
    ('Static', [('White', BitokColors.white)]),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (groupName, tokens) in _groups) ...[
          Text(
            groupName,
            style: BitokTextStyles.body1.copyWith(
              fontSize: 17,
              color: BitokColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (name, color) in tokens)
                Expanded(
                  child: _ColorSwatch(name: name, color: color),
                ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.name, required this.color});

  final String name;
  final Color color;

  String get _hexLabel {
    final argb = color.toARGB32();
    final hex = (argb & 0xFFFFFF)
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();
    final alpha = (argb >> 24) & 0xFF;
    if (alpha == 0xFF) return '#$hex';
    return '#$hex · ${(alpha / 255 * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final isWhite = color == BitokColors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 72,
          decoration: BoxDecoration(
            color: color,
            border: isWhite ? Border.all(color: BitokColors.grey1) : null,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: BitokTextStyles.body2.copyWith(
            fontWeight: FontWeight.w500,
            color: BitokColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _hexLabel,
          style: BitokTextStyles.body3.copyWith(
            fontSize: 11,
            color: BitokColors.grey0,
          ),
        ),
      ],
    );
  }
}
