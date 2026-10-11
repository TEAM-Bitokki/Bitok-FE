import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_text_styles.dart';

class BitokConfirmDialog extends StatelessWidget {
  const BitokConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Delete',
    this.onCancel,
    this.onConfirm,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  factory BitokConfirmDialog.deleteItem({
    Key? key,
    required String itemName,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
  }) {
    return BitokConfirmDialog(
      key: key,
      title: 'Delete this item?',
      message: '$itemName will be removed from the recognized menu list.',
      onCancel: onCancel,
      onConfirm: onConfirm,
    );
  }

  factory BitokConfirmDialog.deleteAccount({
    Key? key,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
  }) {
    return BitokConfirmDialog(
      key: key,
      title: 'Delete your account?',
      message: 'Your account and associated data will be permanently deleted.',
      onCancel: onCancel,
      onConfirm: onConfirm,
    );
  }

  static Future<bool?> showDeleteItem(
      BuildContext context, {
        required String itemName,
      }) {
    return _show(
      context,
          (c) => BitokConfirmDialog.deleteItem(
        itemName: itemName,
        onCancel: () => Navigator.of(c).pop(false),
        onConfirm: () => Navigator.of(c).pop(true),
      ),
    );
  }

  static Future<bool?> showDeleteAccount(BuildContext context) {
    return _show(
      context,
          (c) => BitokConfirmDialog.deleteAccount(
        onCancel: () => Navigator.of(c).pop(false),
        onConfirm: () => Navigator.of(c).pop(true),
      ),
    );
  }

  static Future<bool?> _show(
      BuildContext context,
      Widget Function(BuildContext) builder,
      ) {
    return showDialog<bool>(
      context: context,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 342),
            child: builder(c),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 25, 18, 25),
      decoration: BoxDecoration(
        color: BitokColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시안(BitOK/EN/SubTitle)은 20px / 28 이고 DS 의 subTitle 은 24px 라서
          // 크기만 20 으로 덮어씁니다.
          Text(
            title,
            style: BitokTextStyles.subTitle.copyWith(
              fontSize: 20,
              color: BitokColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: _DialogButton(
                  label: cancelLabel,
                  background: BitokColors.grey3,
                  foreground: BitokColors.grey0,
                  onTap: onCancel,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _DialogButton(
                  label: confirmLabel,
                  background: BitokColors.red1,
                  foreground: BitokColors.white,
                  onTap: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: BitokTextStyles.buttonText2.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'Components', name: 'Modal', size: Size(390, 500))
Widget modalPreview() => MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    backgroundColor: BitokColors.grey3,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        BitokConfirmDialog.deleteItem(itemName: 'Kimchi Jjigae'),
        const SizedBox(height: 12),
        BitokConfirmDialog.deleteAccount(),
      ],
    ),
  ),
);