import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';
import 'bitok_button.dart';
import 'bitok_text_field.dart';

/// 화면 하단에서 올라오는 시트입니다.
///
/// 상단에 제목과 닫기(X) 버튼, 가운데에 [child], 하단에 [actionLabel] 버튼이 놓입니다.
/// [onAction]이 null이면 하단 버튼이 비활성(회색) 상태로 표시됩니다.
///
/// 직접 띄울 때는 [BitokBottomSheet.show]를 사용합니다.
/// ```dart
/// final name = await BitokBottomSheet.show<String>(
///   context,
///   builder: (context) => BitokBottomSheet(
///     title: 'Add item',
///     actionLabel: 'Add',
///     onAction: () => Navigator.of(context).pop('Bibimbap'),
///     child: ...,
///   ),
/// );
/// ```
class BitokBottomSheet extends StatelessWidget {
  const BitokBottomSheet({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.child,
    this.onAction,
    this.onClose,
  });

  /// 시트 상단 제목입니다.
  final String title;

  /// 하단 버튼 문구입니다.
  final String actionLabel;

  /// 제목과 하단 버튼 사이에 표시할 내용입니다.
  final Widget child;

  /// 하단 버튼을 눌렀을 때 호출됩니다. null이면 버튼이 비활성화됩니다.
  final VoidCallback? onAction;

  /// 닫기(X) 버튼을 눌렀을 때 호출됩니다. null이면 시트를 닫습니다.
  final VoidCallback? onClose;

  /// 시안 기준 시트 높이입니다. 화면이 작거나 키보드가 올라오면 그만큼 줄어듭니다.
  static const double maxHeight = 620;

  /// 시트 뒤를 덮는 배경색(검정 28%)입니다.
  static const Color barrierColor = Color(0x47000000);

  static const double _horizontalPadding = 24;
  static const double _topPadding = 35;
  static const double _titleToContentGap = 25;
  static const double _actionBottomGap = 10;
  static const double _homeIndicatorHeight = 34;
  static const double _topMargin = 24;
  static const BorderRadius _borderRadius = BorderRadius.vertical(
    top: Radius.circular(24),
  );

  /// [builder]가 만든 시트를 띄웁니다. 시트를 닫을 때 pop한 값을 반환합니다.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      isScrollControlled: true,
      // 상태바 아래까지만 시트가 올라오도록 합니다.
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight - keyboardHeight - _topMargin
            : maxHeight;

        return Padding(
          // 키보드가 올라오면 시트를 키보드 위로 올립니다.
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: _buildSheet(
            context,
            height: math.min(maxHeight, availableHeight),
            keyboardHeight: keyboardHeight,
          ),
        );
      },
    );
  }

  Widget _buildSheet(
    BuildContext context, {
    required double height,
    required double keyboardHeight,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: BitokColors.white,
        borderRadius: _borderRadius,
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(
          bottom: keyboardHeight > 0 ? 0 : _homeIndicatorHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            _horizontalPadding,
            _topPadding,
            _horizontalPadding,
            _actionBottomGap,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TitleRow(
                title: title,
                onClose: onClose ?? () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: _titleToContentGap),
              Expanded(child: SingleChildScrollView(child: child)),
              BitokButton(label: actionLabel, onPressed: onAction),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          // 시안(Roboto Medium 22 / line-height normal)에 맞는 DS 토큰이 없어서
          // subTitle의 크기와 줄 높이만 덮어씁니다.
          child: Text(
            title,
            style: BitokTextStyles.subTitle.copyWith(
              fontSize: 22,
              height: 26 / 22,
              color: BitokColors.text,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onClose,
          child: SvgPicture.asset(BitokIcons.exitBig24, width: 24, height: 24),
        ),
      ],
    );
  }
}

@Preview(group: 'Components', name: 'Bottom Sheet', size: Size(390, 620))
Widget bottomSheetPreview() => MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    backgroundColor: BitokColors.grey1,
    body: Align(
      alignment: Alignment.bottomCenter,
      child: BitokBottomSheet(
        title: 'Edit item',
        actionLabel: 'Save',
        onAction: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu name',
              style: BitokTextStyles.body3.copyWith(color: BitokColors.grey0),
            ),
            const SizedBox(height: 4),
            BitokTextField(
              controller: TextEditingController(text: 'Kimchi Jjigae'),
            ),
          ],
        ),
      ),
    ),
  ),
);
