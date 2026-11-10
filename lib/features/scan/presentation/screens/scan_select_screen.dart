import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_ocr_menu.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../data/models/scan_menu_item.dart';
import '../providers/scan_flow_provider.dart';
import '../providers/scan_flow_state.dart';

/// REST-05 · 분석할 메뉴를 고르는 화면입니다.
///
/// 여러 개를 고를 수 있고, 하나 이상 골라야 Next 버튼이 활성화됩니다.
class ScanSelectScreen extends ConsumerWidget {
  const ScanSelectScreen({super.key, this.onBack, this.onNext});

  final VoidCallback? onBack;
  final VoidCallback? onNext;

  static const double _horizontalPadding = 24;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(scanFlowProvider);
    final notifier = ref.read(scanFlowProvider.notifier);

    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Analysis',
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
                'Menu Analysis',
                style: BitokTextStyles.title.copyWith(color: BitokColors.text),
              ),
              const SizedBox(height: 3),
              Text(
                flow.recognizedLabel,
                style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: flow.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = flow.items[index];
                    return BitokOcrMenuItem.selectable(
                      key: ValueKey(item.id),
                      koreanName: item.koreanName,
                      englishName: item.englishName,
                      selected: flow.selectedIds.contains(item.id),
                      onTap: () => notifier.toggleSelection(item.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              BitokButton(
                label: 'Next',
                onPressed: flow.selectedIds.isEmpty ? null : onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'REST-05 Select', size: Size(390, 844))
Widget scanSelectScreenPreview() => ProviderScope(
  overrides: [scanFlowProvider.overrideWith(_PreviewScanFlowNotifier.new)],
  child: const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScanSelectScreen(),
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
