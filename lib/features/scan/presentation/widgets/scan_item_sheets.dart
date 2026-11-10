import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_bottom_sheet.dart';
import '../../../../common/widgets/bitok_modal.dart';
import '../../../../common/widgets/bitok_text_field.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';

/// REST-04 · 메뉴 이름을 고치거나 메뉴를 지우는 바텀시트입니다.
///
/// 이름이 바뀌었을 때만 Save 버튼이 활성화됩니다.
/// Delete item을 누르면 확인 모달을 띄우고, 삭제하면 시트를 닫습니다.
class ScanEditItemSheet extends StatefulWidget {
  const ScanEditItemSheet({
    super.key,
    required this.initialName,
    this.onSave,
    this.onDelete,
  });

  final String initialName;
  final ValueChanged<String>? onSave;
  final VoidCallback? onDelete;

  static Future<void> show(
    BuildContext context, {
    required String initialName,
    ValueChanged<String>? onSave,
    VoidCallback? onDelete,
  }) {
    return BitokBottomSheet.show<void>(
      context,
      builder: (_) => ScanEditItemSheet(
        initialName: initialName,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<ScanEditItemSheet> createState() => _ScanEditItemSheetState();
}

class _ScanEditItemSheetState extends State<ScanEditItemSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _name => _controller.text.trim();

  bool get _canSave => _name.isNotEmpty && _name != widget.initialName;

  void _save() {
    widget.onSave?.call(_name);
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await BitokConfirmDialog.showDeleteItem(
      context,
      itemName: widget.initialName,
    );
    if (confirmed != true || !mounted) return;
    widget.onDelete?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BitokBottomSheet(
      title: 'Edit item',
      actionLabel: 'Save',
      onAction: _canSave ? _save : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MenuNameField(controller: _controller),
          const SizedBox(height: 25),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _delete,
            child: Text(
              'Delete item',
              style: BitokTextStyles.buttonText2.copyWith(
                color: BitokColors.red1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// REST-04 · 인식되지 않은 메뉴를 직접 추가하는 바텀시트입니다.
///
/// 이름을 입력해야 Add 버튼이 활성화됩니다.
class ScanAddItemSheet extends StatefulWidget {
  const ScanAddItemSheet({super.key, this.onAdd});

  final ValueChanged<String>? onAdd;

  static Future<void> show(
    BuildContext context, {
    ValueChanged<String>? onAdd,
  }) {
    return BitokBottomSheet.show<void>(
      context,
      builder: (_) => ScanAddItemSheet(onAdd: onAdd),
    );
  }

  @override
  State<ScanAddItemSheet> createState() => _ScanAddItemSheetState();
}

class _ScanAddItemSheetState extends State<ScanAddItemSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _name => _controller.text.trim();

  void _add() {
    widget.onAdd?.call(_name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BitokBottomSheet(
      title: 'Add item',
      actionLabel: 'Add',
      onAction: _name.isNotEmpty ? _add : null,
      child: _MenuNameField(controller: _controller),
    );
  }
}

class _MenuNameField extends StatelessWidget {
  const _MenuNameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu name',
          style: BitokTextStyles.body3.copyWith(color: BitokColors.grey0),
        ),
        const SizedBox(height: 4),
        BitokTextField(
          controller: controller,
          hintText: 'Enter menu name',
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

@Preview(
  group: 'Components',
  name: 'REST-04 Edit item sheet',
  size: Size(390, 620),
)
Widget scanEditItemSheetPreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    backgroundColor: BitokColors.grey1,
    body: Align(
      alignment: Alignment.bottomCenter,
      child: ScanEditItemSheet(initialName: 'Kimchi Jjigae'),
    ),
  ),
);

@Preview(
  group: 'Components',
  name: 'REST-04 Add item sheet',
  size: Size(390, 620),
)
Widget scanAddItemSheetPreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    backgroundColor: BitokColors.grey1,
    body: Align(alignment: Alignment.bottomCenter, child: ScanAddItemSheet()),
  ),
);
