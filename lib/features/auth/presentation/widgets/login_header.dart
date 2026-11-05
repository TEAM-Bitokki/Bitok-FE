import 'package:flutter/material.dart';

import '../../../../core/design_system/bitok_images.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';

// presentation/widgets: 화면(screens)을 구성하는 개별 UI 섹션을 분리해서 화면 파일이
// 비대해지지 않도록 합니다. login_screen.dart는 이 위젯들을 조립하기만 합니다.
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  // 로고 이미지는 원형 아이콘 오른쪽에 'bitok' 글자가 붙어 있어 이미지 중심이
  // 아이콘 중심보다 14.5px 오른쪽에 있습니다. 아이콘이 화면 가운데 오도록 보정합니다.
  static const double _logoCenterOffset = 14.5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Transform.translate(
          offset: const Offset(_logoCenterOffset, 0),
          child: Image.asset(
            BitokImages.bitokLogoWithText,
            width: 175,
            height: 146,
          ),
        ),
        const SizedBox(height: 25),
        Text(
          l10n.appTagline,
          textAlign: TextAlign.center,
          style: BitokTextStyles.body1.copyWith(color: Colors.black),
        ),
      ],
    );
  }
}
