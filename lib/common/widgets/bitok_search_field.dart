import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import 'bitok_text_field.dart';

/// 앞에 검색 아이콘이 있는 검색 입력창입니다.
///
/// 키보드 완료 버튼이 검색 버튼으로 표시됩니다.
class BitokSearchField extends StatelessWidget {
  const BitokSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.variant = BitokTextFieldVariant.grey,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  /// 검색어를 읽거나 바꿀 때 사용하는 컨트롤러입니다.
  final TextEditingController? controller;

  /// 포커스를 직접 제어할 때 사용하는 포커스 노드입니다.
  final FocusNode? focusNode;

  /// 입력 전 표시할 안내 문구입니다. 예: 'Search restaurants'
  final String? hintText;

  /// 배경 스타일입니다. 기본값은 [BitokTextFieldVariant.grey]입니다.
  final BitokTextFieldVariant variant;

  /// 검색어가 바뀔 때마다 호출됩니다.
  final ValueChanged<String>? onChanged;

  /// 키보드의 검색 버튼을 누르면 검색어와 함께 호출됩니다.
  final ValueChanged<String>? onSubmitted;

  /// true면 화면에 나타날 때 자동으로 포커스를 받습니다. 기본값은 false입니다.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return BitokTextField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      variant: variant,
      leading: SvgPicture.asset(BitokIcons.search20, width: 20, height: 20),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
    );
  }
}

@Preview(group: 'Common', name: 'Search', size: Size(400, 330))
Widget searchFieldPreview() => ColoredBox(
  color: BitokColors.white,
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const BitokSearchField(hintText: 'Search allergies'),
        const SizedBox(height: 22),
        BitokSearchField(
          hintText: 'Search allergies',
          controller: TextEditingController(text: '새우'),
        ),
        const SizedBox(height: 22),
        const BitokSearchField(
          hintText: 'Search restaurants',
          variant: BitokTextFieldVariant.white,
        ),
        const SizedBox(height: 22),
        BitokSearchField(
          hintText: 'Search restaurants',
          variant: BitokTextFieldVariant.white,
          controller: TextEditingController(text: 'Myeongdong Kyoja'),
        ),
      ],
    ),
  ),
);
