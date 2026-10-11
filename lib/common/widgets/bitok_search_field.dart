import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import 'bitok_text_field.dart';

/// 검색창 (Figma: Input / Search, 543:2874의 Search_off/on_grey, Search_off/on_white)
///
/// [variant]가 grey면 grey3 배경, white면 흰 배경에 grey1 테두리입니다.
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

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final BitokTextFieldVariant variant;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
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
