import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_icons.dart';
import '../../../../core/design_system/bitok_text_styles.dart';

/// 메뉴판 이미지를 가져올 방법을 고르는 버튼입니다.
///
/// [ScanSourceButton.camera]는 아이콘이 위에 있는 큰 회색 버튼,
/// [ScanSourceButton.gallery]는 아이콘이 왼쪽에 있는 흰색 테두리 버튼입니다.
class ScanSourceButton extends StatelessWidget {
  const ScanSourceButton.camera({super.key, this.onTap}) : _isCamera = true;

  const ScanSourceButton.gallery({super.key, this.onTap}) : _isCamera = false;

  final VoidCallback? onTap;
  final bool _isCamera;

  static final TextStyle _labelStyle = BitokTextStyles.buttonText.copyWith(
    color: BitokColors.grey0,
  );

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(_isCamera ? 20 : 16);

    return Material(
      color: _isCamera ? BitokColors.grey3 : BitokColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: _isCamera
            ? BorderSide.none
            : const BorderSide(color: BitokColors.grey2, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: _isCamera ? 160 : 80,
          child: _isCamera ? _cameraContent() : _galleryContent(),
        ),
      ),
    );
  }

  Widget _cameraContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(BitokIcons.camera40, width: 40, height: 40),
        const SizedBox(height: 20),
        Text('Take a photo', style: _labelStyle),
      ],
    );
  }

  Widget _galleryContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(BitokIcons.gallery24, width: 24, height: 24),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            'Choose from gallery',
            style: _labelStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
