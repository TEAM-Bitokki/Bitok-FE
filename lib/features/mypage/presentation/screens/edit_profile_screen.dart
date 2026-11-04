import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_text_field.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';

//API 미적용 작성
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.initialNickname,
    this.onBack,
    this.onSave,
  });

  final String initialNickname;
  final VoidCallback? onBack;
  final ValueChanged<String>? onSave;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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

  bool get _canSave => _controller.text.trim().isNotEmpty;

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
              BitokButton(
                label: 'Save',
                onPressed: _canSave
                    ? () => widget.onSave?.call(_controller.text.trim())
                    : null,
              ),
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
