import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_menu_card.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../data/models/scan_menu_item.dart';
import '../../data/models/staff_question.dart';
import '../providers/scan_flow_provider.dart';
import '../providers/scan_flow_state.dart';

/// REST-07 · 직원 확인 결과(메뉴별 Avoid / Safe / Not Sure)를 보여주는 화면입니다.
///
/// Save to My Checks를 누르면 [onSave], Finish without Saving을 누르면 [onFinish]가 호출됩니다.
class ScanResultScreen extends ConsumerWidget {
  const ScanResultScreen({
    super.key,
    this.onBack,
    this.onSave,
    this.onFinish,
    this.onViewDetails,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSave;
  final VoidCallback? onFinish;
  final ValueChanged<ScanMenuItem>? onViewDetails;

  static const double _horizontalPadding = 24;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(scanFlowProvider);
    final items = flow.selectedItems;

    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Results',
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
                'Staff Check Results',
                style: BitokTextStyles.title.copyWith(color: BitokColors.text),
              ),
              const SizedBox(height: 3),
              Text(
                flow.checkedLabel,
                style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return BitokMenuDetailCard(
                      key: ValueKey(item.id),
                      koreanName: item.koreanName,
                      englishName: item.englishName,
                      status: flow.statusOf(item.id),
                      onViewDetailsTap: () => onViewDetails?.call(item),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              BitokButton(label: 'Save to My Checks', onPressed: onSave),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onFinish,
                  child: Text(
                    'Finish without Saving',
                    style: BitokTextStyles.buttonText2.copyWith(
                      color: BitokColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'REST-07 Results', size: Size(390, 844))
Widget scanResultScreenPreview() => ProviderScope(
  overrides: [scanFlowProvider.overrideWith(_PreviewScanFlowNotifier.new)],
  child: const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScanResultScreen(),
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
    selectedIds: {'0', '1', '2'},
    answers: {
      '0': StaffAnswer.contains,
      '1': StaffAnswer.notContains,
      '2': StaffAnswer.notSure,
    },
  );
}
