import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_text_styles.dart';
import '../../core/utils/code_point_limit.dart';

/// 입력창의 배경 스타일입니다.
enum BitokTextFieldVariant {
  /// 회색 배경, 테두리 없음.
  grey,

  /// 흰 배경, 회색 테두리.
  white,
}

/// 한 줄 텍스트 입력창입니다.
///
/// 입력 전에는 회색 안내 문구가, 입력 후에는 입력한 텍스트가 표시됩니다.
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
    this.maxCodePoints,
  });

  /// 입력 텍스트를 읽거나 바꿀 때 사용하는 컨트롤러입니다.
  final TextEditingController? controller;

  /// 포커스를 직접 제어할 때 사용하는 포커스 노드입니다.
  final FocusNode? focusNode;

  /// 입력 전 표시할 안내 문구입니다.
  final String? hintText;

  /// 텍스트 앞에 표시할 20×20 위젯입니다. 예: 아이콘
  final Widget? leading;

  /// 배경 스타일입니다. 기본값은 [BitokTextFieldVariant.grey]입니다.
  final BitokTextFieldVariant variant;

  /// 표시할 키보드 종류입니다.
  final TextInputType? keyboardType;

  /// 키보드 완료 버튼의 종류입니다.
  final TextInputAction? textInputAction;

  /// 입력 텍스트가 바뀔 때마다 호출됩니다.
  final ValueChanged<String>? onChanged;

  /// 키보드 완료 버튼을 누르면 입력 텍스트와 함께 호출됩니다.
  final ValueChanged<String>? onSubmitted;

  /// false면 입력할 수 없습니다. 기본값은 true입니다.
  final bool enabled;

  /// true면 화면에 나타날 때 자동으로 포커스를 받습니다. 기본값은 false입니다.
  final bool autofocus;

  /// 입력할 수 있는 최대 길이입니다. null이면 제한 없음. (글자 수 표시는 없음)
  ///
  /// 화면의 글자 수가 아니라 서버처럼 유니코드 코드 포인트 수로 셉니다.
  /// 예: 👍🏽는 화면에선 한 글자지만 2로 셉니다. 넘는 입력은 글자 단위로 잘라 받지 않습니다.
  final int? maxCodePoints;

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
              inputFormatters: [
                if (maxCodePoints case final max?)
                  CodePointLimitingTextInputFormatter(max),
              ],
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
