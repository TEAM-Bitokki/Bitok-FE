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
import '../models/scan_error_message.dart';
import '../providers/scan_flow_provider.dart';
import '../providers/scan_flow_state.dart';

/// REST-05 · 분석할 메뉴를 고르는 화면입니다.
///
/// 여러 개를 고를 수 있고, 하나 이상 골라야 Next 버튼이 활성화됩니다.
///
/// [onNext]가 끝날 때까지(메뉴 분석) 버튼과 선택을 막고 진행 중임을 보여줍니다.
/// 실패하면 에러 코드에 맞는 안내를 스낵바로 띄우고 화면에 그대로 남습니다.
class ScanSelectScreen extends ConsumerStatefulWidget {
  const ScanSelectScreen({super.key, this.onBack, this.onNext});

  final VoidCallback? onBack;
  final Future<void> Function()? onNext;

  @override
  ConsumerState<ScanSelectScreen> createState() => _ScanSelectScreenState();
}

class _ScanSelectScreenState extends ConsumerState<ScanSelectScreen> {
  static const double _horizontalPadding = 24;

  bool _analyzing = false;

  Future<void> _next() async {
    if (_analyzing) return;
    setState(() => _analyzing = true);
    try {
      await widget.onNext!();
    } catch (e) {
      if (mounted) {
        showMessageSnackBar(
          context,
          scanErrorMessage(AppLocalizations.of(context), e),
        );
      }
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(scanFlowProvider);
    final notifier = ref.read(scanFlowProvider.notifier);
    final onBack = widget.onBack;

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
                      // 분석 중에 선택을 바꾸면 보낸 요청과 화면이 달라지므로 막습니다.
                      onTap: _analyzing
                          ? null
                          : () => notifier.toggleSelection(item.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_analyzing) ...[
                Text(
                  AppLocalizations.of(context).scanRecognizingHint,
                  textAlign: TextAlign.center,
                  style: BitokTextStyles.body2.copyWith(
                    color: BitokColors.grey0,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              BitokButton(
                label: _analyzing
                    ? AppLocalizations.of(context).scanAnalyzing
                    : 'Next',
                onPressed:
                    flow.selectedIds.isEmpty ||
                        widget.onNext == null ||
                        _analyzing
                    ? null
                    : _next,
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
