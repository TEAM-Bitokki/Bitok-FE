import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_menu_card.dart';
import '../../../../common/widgets/saving_state_mixin.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../data/models/analyzed_menu.dart';
import '../providers/scan_flow_provider.dart';
import '../providers/scan_flow_state.dart';

/// REST-07 · 직원 확인 결과(메뉴별 Avoid / Safe / Not Sure)를 보여주는 화면입니다.
///
/// Save to My Checks를 누르면 [onSave], Finish without Saving을 누르면 [onFinish]가 호출됩니다.
/// 저장하는 동안 버튼을 막고, 실패하면 '다시 시도' 스낵바를 띄웁니다.
class ScanResultScreen extends ConsumerStatefulWidget {
  const ScanResultScreen({
    super.key,
    this.onBack,
    this.onSave,
    this.onFinish,
    this.onViewDetails,
  });

  final VoidCallback? onBack;
  final Future<void> Function()? onSave;
  final VoidCallback? onFinish;
  final ValueChanged<AnalyzedMenu>? onViewDetails;

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen>
    with SavingStateMixin {
  static const double _horizontalPadding = 24;

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(scanFlowProvider);
    final menus = flow.menus;
    final onBack = widget.onBack;
    final onSave = widget.onSave;
    final onFinish = widget.onFinish;
    final onViewDetails = widget.onViewDetails;

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
                  itemCount: menus.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    return BitokMenuDetailCard(
                      key: ValueKey(menu.analysisId),
                      koreanName: menu.nameKo,
                      englishName: menu.nameEn,
                      status: flow.statusOf(menu),
                      // 저장하는 동안에는 상세로 가지 않게 막습니다.
                      // (상세를 보는 중에 저장이 끝나면 그 위에 저장 완료 화면이 열립니다)
                      onViewDetailsTap: saving
                          ? null
                          : () => onViewDetails?.call(menu),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              BitokButton(
                label: 'Save to My Checks',
                onPressed: onSave == null || saving
                    ? null
                    : () => runSaving(onSave),
              ),
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
    menus: [
      AnalyzedMenu(
        dishId: 12,
        nameKo: '김치찌개',
        nameEn: 'Kimchi Jjigae',
        analysisId: 551,
        verdict: 'avoid',
      ),
      AnalyzedMenu(
        dishId: 13,
        nameKo: '비빔밥',
        nameEn: 'Bibimbap',
        analysisId: 552,
        verdict: 'safe',
      ),
      AnalyzedMenu(
        dishId: 14,
        nameKo: '불고기',
        nameEn: 'Bulgogi',
        analysisId: 553,
        verdict: 'not_sure',
      ),
    ],
  );
}
