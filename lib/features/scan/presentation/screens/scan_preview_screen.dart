import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/saving_state_mixin.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../models/scan_error_message.dart';

/// REST-03 · 촬영하거나 고른 메뉴판 사진을 확인하는 화면입니다.
///
/// 다시 고르려면 뒤로 가고, 사진이 괜찮으면 [onNext]로 다음 단계(OCR 결과 확인)로 넘어갑니다.
///
/// [onNext]가 끝날 때까지(메뉴 인식 10~25초) 버튼을 막고 진행 중임을 보여줍니다.
/// 실패하면 에러 코드에 맞는 안내를 스낵바로 띄우고 화면에 그대로 남습니다.
class ScanPreviewScreen extends StatefulWidget {
  const ScanPreviewScreen({
    super.key,
    required this.imagePath,
    this.onBack,
    this.onNext,
  });

  /// 미리 볼 이미지 파일 경로입니다.
  final String imagePath;

  final VoidCallback? onBack;
  final Future<void> Function()? onNext;

  @override
  State<ScanPreviewScreen> createState() => _ScanPreviewScreenState();
}

class _ScanPreviewScreenState extends State<ScanPreviewScreen> {
  static const double _horizontalPadding = 24;
  static const double _imageMaxHeight = 430;

  bool _recognizing = false;

  Future<void> _next() async {
    if (_recognizing) return;
    setState(() => _recognizing = true);
    try {
      await widget.onNext!();
    } catch (e) {
      if (mounted) {
        showMessageSnackBar(
          context,
          scanErrorMessage(AppLocalizations.of(context), e),
        );
      }
    } finally {
      if (mounted) setState(() => _recognizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onBack = widget.onBack;
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _MenuImagePreview(imagePath: widget.imagePath),
                        if (_recognizing) const _RecognizingOverlay(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BitokButton(
                label: _recognizing
                    ? AppLocalizations.of(context).scanRecognizing
                    : 'Next',
                onPressed: widget.onNext == null || _recognizing ? null : _next,
              ),
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

/// 메뉴를 인식하는 동안 사진 위에 띄우는 진행 표시입니다.
class _RecognizingOverlay extends StatelessWidget {
  const _RecognizingOverlay();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: ColoredBox(
        color: BitokColors.text.withValues(alpha: 0.45),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: BitokColors.white),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).scanRecognizingHint,
              textAlign: TextAlign.center,
              style: BitokTextStyles.body2.copyWith(color: BitokColors.white),
            ),
          ],
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
