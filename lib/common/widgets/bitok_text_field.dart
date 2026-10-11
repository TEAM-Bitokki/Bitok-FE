import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_text_styles.dart';

enum BitokTextFieldVariant {
  /// grey3 배경, 테두리 없음
  grey,

  /// white 배경, grey1 1px 테두리
  white,
}

/// 텍스트 입력 필드 (Figma: Input / Search, 543:2874의 Input_off / Input_on)
///
/// 입력 전에는 grey0 색의 힌트, 입력 후에는 text 색의 텍스트가 표시됩니다.
class BitokTextField extends StatelessWidget {
  const BitokTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.leading,
    this.variant = BitokTextFieldVariant.grey,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;

  /// 텍스트 앞에 표시할 20×20 아이콘 (예: 검색 아이콘)
  final Widget? leading;
  final BitokTextFieldVariant variant;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;

  static const double height = 52;
  static const double _horizontalPadding = 18;
  static const double _leadingGap = 10;
  static final BorderRadius _borderRadius = BorderRadius.circular(14);

  @override
  Widget build(BuildContext context) {
    final isWhite = variant == BitokTextFieldVariant.white;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      decoration: BoxDecoration(
        color: isWhite ? BitokColors.white : BitokColors.grey3,
        borderRadius: _borderRadius,
      ),
      // 테두리가 내부 콘텐츠 위치를 밀지 않도록 foregroundDecoration으로 그립니다.
      foregroundDecoration: isWhite
          ? BoxDecoration(
              border: Border.all(color: BitokColors.grey1),
              borderRadius: _borderRadius,
            )
          : null,
      child: Row(
        children: [
          if (leading != null) ...[
            SizedBox.square(dimension: 20, child: leading),
            const SizedBox(width: _leadingGap),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              autofocus: autofocus,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              cursorColor: BitokColors.primary,
              style: BitokTextStyles.inputText.copyWith(
                color: BitokColors.text,
              ),
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle: BitokTextStyles.inputText.copyWith(
                  color: BitokColors.grey0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'Common', name: 'Input', size: Size(400, 200))
Widget textFieldPreview() => ColoredBox(
  color: BitokColors.white,
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const BitokTextField(hintText: 'e.g. Alex'),
        const SizedBox(height: 22),
        BitokTextField(
          hintText: 'e.g. Alex',
          controller: TextEditingController(text: 'Bitok'),
        ),
      ],
    ),
  ),
);
