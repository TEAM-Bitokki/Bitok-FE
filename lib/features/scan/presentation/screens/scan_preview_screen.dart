import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';

/// REST-03 · 촬영하거나 고른 메뉴판 사진을 확인하는 화면입니다.
///
/// 다시 고르려면 뒤로 가고, 사진이 괜찮으면 [onNext]로 다음 단계(OCR 결과 확인)로 넘어갑니다.
class ScanPreviewScreen extends StatelessWidget {
  const ScanPreviewScreen({
    super.key,
    required this.imagePath,
    this.onBack,
    this.onNext,
  });

  /// 미리 볼 이미지 파일 경로입니다.
  final String imagePath;

  final VoidCallback? onBack;
  final VoidCallback? onNext;

  static const double _horizontalPadding = 24;
  static const double _imageMaxHeight = 430;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Scan',
        onBack: onBack ?? () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 34),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            _horizontalPadding,
            12,
            _horizontalPadding,
            10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Check your photo',
                style: BitokTextStyles.title.copyWith(color: BitokColors.text),
              ),
              const SizedBox(height: 3),
              Text(
                'Make sure every menu item is readable',
                style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
              ),
              const SizedBox(height: 25),
              // 화면이 작으면 이미지 높이를 줄여 하단 버튼이 가려지지 않게 합니다.
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: _imageMaxHeight,
                    child: _MenuImagePreview(imagePath: imagePath),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BitokButton(label: 'Next', onPressed: onNext),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuImagePreview extends StatelessWidget {
  const _MenuImagePreview({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: ColoredBox(
        color: BitokColors.grey1,
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          // 파일을 읽지 못하면 회색 배경만 보여줍니다.
          errorBuilder: (_, _, _) => const SizedBox.expand(),
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'REST-03 Image Preview', size: Size(390, 844))
Widget scanPreviewScreenPreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  // 미리보기에서는 실제 파일이 없으므로 회색 배경으로 표시됩니다.
  home: ScanPreviewScreen(imagePath: ''),
);
