import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_text_field.dart';
import '../../../../common/widgets/saving_state_mixin.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/models/nickname_request.dart';

/// 닉네임 수정 화면입니다.
///
/// [onSave]가 끝날 때까지 Save 버튼을 비활성화하고, 실패하면 다시 시도하라고 안내합니다.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.initialNickname,
    this.onBack,
    this.onSave,
  });

  final String initialNickname;
  final VoidCallback? onBack;
  final Future<void> Function(String nickname)? onSave;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SavingStateMixin {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSave => !saving && _controller.text.trim().isNotEmpty;

  Future<void> _save() async {
    final onSave = widget.onSave;
    if (onSave == null) return;
    final nickname = _controller.text.trim();
    // 서버까지 보내지 않고 바로 안내합니다. (서버도 같은 기준으로 422를 돌려줍니다)
    if (NicknameRequest.isTooLong(nickname)) {
      showMessageSnackBar(
        context,
        AppLocalizations.of(context).nicknameTooLong(NicknameRequest.maxLength),
      );
      return;
    }
    await runSaving(() => onSave(nickname));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Edit Profile',
        onBack: widget.onBack ?? () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(bottom: 34),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nickname',
                style: BitokTextStyles.body1.copyWith(color: BitokColors.text),
              ),
              const SizedBox(height: 5),
              BitokTextField(controller: _controller),
              const Spacer(),
              BitokButton(label: 'Save', onPressed: _canSave ? _save : null),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Edit Profile', size: Size(390, 844))
Widget editProfilePreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: EditProfileScreen(initialNickname: 'Biiiiii'),
);
