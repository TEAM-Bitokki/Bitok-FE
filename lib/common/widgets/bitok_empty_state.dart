import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_images.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// 목록이 비어 있을 때 보여주는 이미지와 안내 문구입니다. 홈 Recent checks의 빈 상태와 같은 모양입니다.
///
/// 예: Saved Menus의 'No saved menus', Saved Restaurants의 'No saved restaurants'
class BitokEmptyState extends StatelessWidget {
  const BitokEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(BitokImages.noChecks, width: 200, height: 200),
        const SizedBox(height: 17),
        Text(
          message,
          textAlign: TextAlign.center,
          style: BitokTextStyles.body1.copyWith(color: BitokColors.grey0),
        ),
      ],
    );
  }
}

@Preview(group: 'Widgets', name: 'Empty State', size: Size(390, 300))
Widget bitokEmptyStatePreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    backgroundColor: BitokColors.white,
    body: Center(child: BitokEmptyState(message: 'No saved menus')),
  ),
);
