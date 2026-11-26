import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_ocr_menu.dart';
import '../../../../common/widgets/saving_state_mixin.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/scan_menu_item.dart';
import '../providers/scan_flow_provider.dart';
import '../providers/scan_flow_state.dart';
import '../widgets/scan_item_sheets.dart';

/// REST-04 · 인식한 메뉴 목록을 확인하고 고치는 화면입니다.
///
/// 편집 아이콘으로 이름 수정/삭제, Add item으로 메뉴 추가를 할 수 있습니다.
/// 메뉴가 하나도 없으면 Next 버튼이 비활성화됩니다.
class ScanCheckScreen extends ConsumerWidget {
  const ScanCheckScreen({super.key, this.onBack, this.onNext});

  final VoidCallback? onBack;
  final VoidCallback? onNext;

  static const double _horizontalPadding = 24;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(scanFlowProvider);
    final items = flow.items;
    final notifier = ref.read(scanFlowProvider.notifier);

    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Check',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Check recognized text',
                style: BitokTextStyles.title.copyWith(color: BitokColors.text),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      flow.recognizedLabel,
                      style: BitokTextStyles.body2.copyWith(
                        color: BitokColors.grey0,
                      ),
                    ),
                  ),
                  _AddItemAction(
                    onTap: () {
                      // 분석 요청에는 메뉴 목록을 최대 100개까지 보낼 수 있습니다.
                      if (!notifier.canAddItem) {
                        showMessageSnackBar(
                          context,
                          AppLocalizations.of(
                            context,
                          ).scanMaxItems(ScanFlowNotifier.maxItems),
                        );
                        return;
                      }
                      ScanAddItemSheet.show(context, onAdd: notifier.addItem);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return BitokOcrMenuItem.editable(
                      key: ValueKey(item.id),
                      koreanName: item.koreanName,
                      englishName: item.englishName,
                      onEdit: () => ScanEditItemSheet.show(
                        context,
                        initialName: item.englishName,
                        onSave: (name) => notifier.renameItem(item.id, name),
                        onDelete: () => notifier.removeItem(item.id),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              BitokButton(
                label: 'Next',
                onPressed: items.isEmpty ? null : onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 제목 아래 오른쪽의 "+ Add item" 버튼입니다.
class _AddItemAction extends StatelessWidget {
  const _AddItemAction({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PlusIcon(),
          const SizedBox(width: 4),
          Text(
            'Add item',
            style: BitokTextStyles.buttonText2.copyWith(
              color: BitokColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 시안의 Icon / Plus(12×20 영역에 10×1.5 막대 두 개)를 그대로 그립니다.
class _PlusIcon extends StatelessWidget {
  const _PlusIcon();

  static const double _length = 10;
  static const double _thickness = 1.5;

  @override
  Widget build(BuildContext context) {
    Widget bar({required double width, required double height}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: BitokColors.primary,
          borderRadius: BorderRadius.circular(_thickness / 2),
        ),
      );
    }

    return SizedBox(
      width: 12,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          bar(width: _length, height: _thickness),
          bar(width: _thickness, height: _length),
        ],
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'REST-04 Check', size: Size(390, 844))
Widget scanCheckScreenPreview() => ProviderScope(
  overrides: [scanFlowProvider.overrideWith(_PreviewScanFlowNotifier.new)],
  child: const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScanCheckScreen(),
  ),
);

class _PreviewScanFlowNotifier extends ScanFlowNotifier {
  @override
  ScanFlowState build() => const ScanFlowState(
    items: [
      ScanMenuItem(id: '0', koreanName: '김치찌개', englishName: 'Kimchi Jjigae'),
      ScanMenuItem(id: '1', koreanName: '비빔밥', englishName: 'Bibimbap'),
      ScanMenuItem(id: '2', koreanName: '불고기', englishName: 'Bulgogi'),
    ],
  );
}
