import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_checkbox_row.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_modal.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';

//API 미적용 작성
class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key, this.onBack, this.onDelete});

  final VoidCallback? onBack;
  final ValueChanged<bool>? onDelete;

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  bool _agreed = false;
  bool _deleteSavedMenus = false;

  Future<void> _confirmDelete() async {
    final confirmed = await BitokConfirmDialog.showDeleteAccount(context);
    if (confirmed == true) widget.onDelete?.call(_deleteSavedMenus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Account Deletion',
        onBack: widget.onBack ?? () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Before you delete your account',
                style: BitokTextStyles.subTitle.copyWith(
                  fontSize: 20,
                  color: BitokColors.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'The information below will be permanently deleted and cannot be recovered.',
                style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
              ),
              const SizedBox(height: 25),
              const _DeletedInfoBox(),
              const Spacer(),
              BitokCheckboxRow(
                label: 'Required · I agree to delete my account.',
                description: 'All account information will be permanently deleted.',
                checked: _agreed,
                onChanged: (v) => setState(() => _agreed = v),
              ),
              const SizedBox(height: 15),
              BitokCheckboxRow(
                label: 'Optional · Delete my saved menus too.',
                description: 'Other users will no longer be able to view them.',
                checked: _deleteSavedMenus,
                onChanged: (v) => setState(() => _deleteSavedMenus = v),
              ),
              const SizedBox(height: 30),
              // 시안에는 비활성 상태만 있어서 delete 스타일 하나를 그대로 씁니다.
              BitokButton(
                label: 'Delete Account',
                variant: BitokButtonVariant.delete,
                onPressed: _agreed ? _confirmDelete : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeletedInfoBox extends StatelessWidget {
  const _DeletedInfoBox();

  @override
  Widget build(BuildContext context) {
    const items = ['Activity history', 'Profile and account information'];

    return Container(
      width: double.infinity,
      height: 132,
      padding: const EdgeInsets.fromLTRB(17, 29, 17, 0),
      decoration: BoxDecoration(
        color: BitokColors.red3,
        border: Border.all(color: BitokColors.grey1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information that will be deleted',
            style: BitokTextStyles.body1.copyWith(color: BitokColors.red1),
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Row(
                children: [
                  Text(
                    '•',
                    style: BitokTextStyles.body3.copyWith(
                      color: BitokColors.text,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item,
                    style: BitokTextStyles.body3.copyWith(
                      color: BitokColors.text,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Account Deletion', size: Size(390, 844))
Widget accountDeletionPreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: AccountDeletionScreen(),
);
