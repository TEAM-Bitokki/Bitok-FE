import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/saving_state_mixin.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../models/scan_error_message.dart';
import '../../data/models/scan_menu_item.dart';
import '../../data/models/staff_question.dart';
import '../providers/scan_flow_provider.dart';
import '../providers/scan_flow_state.dart';

/// REST-06 · 직원에게 질문을 보여주고 답변을 기록하는 화면입니다.
///
/// 질문을 한 개씩 보여주며(1/3, 2/3 ...), 답변 버튼을 누르면 다음 질문으로 넘어갑니다.
/// 마지막 질문에 답하면 [onComplete]가 호출됩니다.
/// 뒤로가기는 이전 질문으로 돌아가고, 첫 질문에서는 [onBack]을 호출합니다.
class ScanAskStaffScreen extends ConsumerStatefulWidget {
  const ScanAskStaffScreen({super.key, this.onBack, this.onComplete});

  final VoidCallback? onBack;
  final VoidCallback? onComplete;

  @override
  ConsumerState<ScanAskStaffScreen> createState() => _ScanAskStaffScreenState();
}

class _ScanAskStaffScreenState extends ConsumerState<ScanAskStaffScreen> {
  static const double _horizontalPadding = 24;

  int _index = 0;

  /// 답변을 서버에 보내는 중이면 true입니다. 버튼과 뒤로가기를 막아 질문이 어긋나지 않게 합니다.
  bool _submitting = false;

  void _goBack() {
    if (_submitting) return;
    if (_index > 0) {
      setState(() => _index--);
    } else {
      (widget.onBack ?? () => Navigator.maybePop(context))();
    }
  }

  /// 답변이 서버에 기록된 뒤에 다음 질문으로 넘어갑니다.
  /// 실패하면 안내 스낵바를 띄우고 같은 질문에 머뭅니다.
  Future<void> _answer(List<StaffQuestion> questions, StaffAnswer answer) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(scanFlowProvider.notifier)
          .answer(questions[_index].id, answer);
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        showMessageSnackBar(
          context,
          scanErrorMessage(AppLocalizations.of(context), e),
        );
      }
      return;
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    if (_index < questions.length - 1) {
      setState(() => _index++);
    } else {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(
      scanFlowProvider.select((state) => state.questions),
    );
    if (questions.isEmpty) {
      return const Scaffold(backgroundColor: BitokColors.white);
    }
    final index = _index.clamp(0, questions.length - 1);
    final question = questions[index];

    return PopScope(
      // 두 번째 질문부터는 시스템 뒤로가기도 이전 질문으로 돌아가게 합니다.
      canPop: index == 0 && !_submitting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: BitokColors.white,
        appBar: BitokHeader.sub(title: 'Ask Staff', onBack: _goBack),
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
                  'Show this to staff',
                  style: BitokTextStyles.title.copyWith(
                    color: BitokColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${index + 1}/${questions.length}',
                  style: BitokTextStyles.body2.copyWith(
                    color: BitokColors.grey0,
                  ),
                ),
                const SizedBox(height: 25),
                // 화면이 작으면 질문 영역을 스크롤해 답변 버튼이 가려지지 않게 합니다.
                Expanded(
                  child: SingleChildScrollView(
                    child: _QuestionCard(question: question),
                  ),
                ),
                const SizedBox(height: 16),
                BitokButton(
                  label: '들어가요',
                  variant: BitokButtonVariant.red,
                  onPressed: _submitting
                      ? null
                      : () => _answer(questions, StaffAnswer.contains),
                ),
                const SizedBox(height: 8),
                BitokButton(
                  label: '모르겠어요',
                  variant: BitokButtonVariant.yellow,
                  onPressed: _submitting
                      ? null
                      : () => _answer(questions, StaffAnswer.notSure),
                ),
                const SizedBox(height: 8),
                BitokButton(
                  label: '안 들어가요',
                  variant: BitokButtonVariant.green,
                  onPressed: _submitting
                      ? null
                      : () => _answer(questions, StaffAnswer.notContains),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final StaffQuestion question;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 250),
          padding: const EdgeInsets.all(18),
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
            color: BitokColors.grey3,
            borderRadius: BorderRadius.circular(20),
          ),
          // 시안은 위쪽 여백이 20이라 줄 높이 차이만큼 2를 더 내립니다.
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              question.koreanText,
              style: BitokTextStyles.titleKOR.copyWith(color: BitokColors.text),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          question.englishText,
          style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
        ),
      ],
    );
  }
}

@Preview(group: 'Screens', name: 'REST-06 Ask Staff', size: Size(390, 844))
Widget scanAskStaffScreenPreview() => ProviderScope(
  overrides: [scanFlowProvider.overrideWith(_PreviewScanFlowNotifier.new)],
  child: const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScanAskStaffScreen(),
  ),
);

class _PreviewScanFlowNotifier extends ScanFlowNotifier {
  @override
  ScanFlowState build() => const ScanFlowState(
    items: [
      ScanMenuItem(id: 'i1', koreanName: '김치찌개', englishName: 'Kimchi Jjigae'),
    ],
    selectedIds: {'i1'},
    questions: [
      StaffQuestion(
        id: 880,
        dishId: 12,
        ingredientId: 301,
        koreanText: '이 김치찌개에 새우가 들어가나요?',
        englishText: 'Does this kimchi jjigae contain shrimp?',
      ),
      StaffQuestion(
        id: 881,
        dishId: 12,
        ingredientId: 302,
        koreanText: '이 김치찌개에 멸치가 들어가나요?',
        englishText: 'Does this kimchi jjigae contain anchovy?',
      ),
    ],
  );
}
