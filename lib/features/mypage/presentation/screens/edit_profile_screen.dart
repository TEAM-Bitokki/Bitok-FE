import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_text_field.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';

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

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _controller;
  bool _saving = false;

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

  bool get _canSave => !_saving && _controller.text.trim().isNotEmpty;

  Future<void> _save() async {
    final onSave = widget.onSave;
    if (onSave == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await onSave(_controller.text.trim());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).errorTryAgain)),
          );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: EditProfileScreen(initialNickname: 'Biiiiii'),
);
