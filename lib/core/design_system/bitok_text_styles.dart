import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'bitok_colors.dart';

class BitokTextStyles {
  const BitokTextStyles._();

  static const TextStyle title = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 24,
    height: 32 / 24,
    letterSpacing: -0.24,
  );

  static const TextStyle header = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 20,
    height: 28 / 20,
    letterSpacing: -0.0,
  );

  static const TextStyle subTitle = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 24,
    height: 28 / 24,
    letterSpacing: -0.0,
  );

  static const TextStyle navText = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 9,
    height: 10.8 / 9,
    letterSpacing: -0.0,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 18,
    height: 24 / 18,
    letterSpacing: -0.0,
  );

  static const TextStyle buttonText2 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: -0.0,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: -0.0,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: -0.0,
  );

  static const TextStyle body3 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 18 / 13,
    letterSpacing: -0.0,
  );

  static const TextStyle inputText = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 20 / 15,
    letterSpacing: -0.0,
  );

  static const TextStyle titleKOR = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w500,
    fontSize: 24,
    height: 32 / 24,
    letterSpacing: -0.0,
  );

  static const TextStyle buttonKOR = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w500,
    fontSize: 18,
    height: 24 / 18,
    letterSpacing: -0.0,
  );

  static const TextStyle body1KOR = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: -0.0,
  );
}

@Preview(
  group: 'Design System',
  name: 'Typography Guide',
  size: Size(1200, 1000),
)
Widget typographyGuidePreview() => const _GuidePage(
  title: 'Typography',
  description: 'EN · Roboto / KR · Pretendard\n비톡의 텍스트 스타일 가이드입니다.',
  panelTitle: '타이포그래피',
  child: _TypographyGuide(),
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

typedef _TextToken = (String name, TextStyle style);

class _TypographyGuide extends StatelessWidget {
  const _TypographyGuide();

  static const String _sampleEN = 'Make every bite OK.';
  static const String _sampleKR = '모든 한 입을 안심할 수 있게';

  static const List<_TextToken> _englishTokens = [
    ('Title', BitokTextStyles.title),
    ('Header', BitokTextStyles.header),
    ('SubTitle', BitokTextStyles.subTitle),
    ('Nav', BitokTextStyles.navText),
    ('Button', BitokTextStyles.buttonText),
    ('Button2', BitokTextStyles.buttonText2),
    ('Body1', BitokTextStyles.body1),
    ('Body2', BitokTextStyles.body2),
    ('Body3', BitokTextStyles.body3),
    ('Input', BitokTextStyles.inputText),
  ];

  static const List<_TextToken> _koreanTokens = [
    ('Title', BitokTextStyles.titleKOR),
    ('Button', BitokTextStyles.buttonKOR),
    ('Body1', BitokTextStyles.body1KOR),
  ];

  @override
  Widget build(BuildContext context) {
    final sectionStyle = BitokTextStyles.title.copyWith(
      fontSize: 22,
      letterSpacing: 0,
      color: BitokColors.text,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Expanded(
              child: _FontFamilyCard(family: 'Roboto', description: 'English'),
            ),
            SizedBox(width: 24),
            Expanded(
              child: _FontFamilyCard(
                family: 'Pretendard',
                description: 'Korean',
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Text('English · Roboto', style: sectionStyle),
        const SizedBox(height: 24),
        for (final (name, style) in _englishTokens)
          _TypographyRow(name: name, style: style, sample: _sampleEN),
        const SizedBox(height: 32),
        Text(
          'Korean · Pretendard',
          style: sectionStyle.copyWith(fontFamily: 'Pretendard'),
        ),
        const SizedBox(height: 24),
        for (final (name, style) in _koreanTokens)
          _TypographyRow(name: name, style: style, sample: _sampleKR),
      ],
    );
  }
}

class _FontFamilyCard extends StatelessWidget {
  const _FontFamilyCard({required this.family, required this.description});

  final String family;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BitokColors.grey3,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            family,
            style: TextStyle(
              fontFamily: family,
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: BitokColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: BitokTextStyles.body3.copyWith(
              fontSize: 12,
              color: BitokColors.grey0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypographyRow extends StatelessWidget {
  const _TypographyRow({
    required this.name,
    required this.style,
    required this.sample,
  });

  final String name;
  final TextStyle style;
  final String sample;

  static final Map<FontWeight, String> _weightNames = {
    FontWeight.w400: 'Regular',
    FontWeight.w500: 'Medium',
    FontWeight.w600: 'SemiBold',
    FontWeight.w700: 'Bold',
  };

  static String _trim(double value) =>
      (value + 0.0).toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

  String get _spec {
    final fontSize = style.fontSize ?? 14;
    final weight = _weightNames[style.fontWeight] ?? '${style.fontWeight}';
    final lineHeight = style.height == null
        ? 'normal'
        : '${_trim(style.height! * fontSize)}px';
    final tracking = '${_trim((style.letterSpacing ?? 0) / fontSize * 100)}%';
    return '${style.fontFamily} $weight · ${_trim(fontSize)}px / $lineHeight / $tracking';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 330,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: BitokTextStyles.body1.copyWith(
                    fontSize: 15,
                    color: BitokColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _spec,
                  style: BitokTextStyles.body3.copyWith(
                    fontSize: 11,
                    color: BitokColors.grey0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(sample, style: style.copyWith(color: BitokColors.text)),
          ),
        ],
      ),
    );
  }
}
