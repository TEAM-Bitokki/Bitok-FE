import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/scan_restaurant.dart';
import '../providers/scan_flow_provider.dart';
import '../providers/scan_flow_state.dart';
import '../widgets/scan_restaurant_card.dart';

/// REST-08 · 결과를 My Checks에 저장했음을 알려주는 화면입니다.
///
/// Done을 누르면 [onDone]이 호출됩니다.
class ScanSavedScreen extends ConsumerWidget {
  const ScanSavedScreen({
    super.key,
    required this.restaurant,
    this.onBack,
    this.onDone,
  });

  final ScanRestaurant restaurant;
  final VoidCallback? onBack;
  final VoidCallback? onDone;

  static const double _horizontalPadding = 24;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(scanFlowProvider);
    final savedAt = flow.savedAt;
    final detailStyle = BitokTextStyles.body2.copyWith(
      color: BitokColors.grey0,
    );

    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Save',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saved to My Checks',
                style: BitokTextStyles.title.copyWith(color: BitokColors.text),
              ),
              const SizedBox(height: 3),
              Text('You can review this result anytime', style: detailStyle),
              const SizedBox(height: 25),
              ScanRestaurantCard(restaurant: restaurant, borderRadius: 18),
              const SizedBox(height: 20),
              Text(flow.checkedLabel, style: detailStyle),
              if (savedAt != null)
                Text(savedAt.toDateTimeLabel(), style: detailStyle),
              const Spacer(),
              BitokButton(label: 'Done', onPressed: onDone),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'REST-08 Saved', size: Size(390, 844))
Widget scanSavedScreenPreview() => ProviderScope(
  overrides: [scanFlowProvider.overrideWith(_PreviewScanFlowNotifier.new)],
  child: const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScanSavedScreen(
      restaurant: ScanRestaurant(
        name: 'Myeongdong Kyoja',
        category: 'Korean Restaurant',
        address: '29 Myeongdong 10-gil, Jung-gu',
      ),
    ),
  ),
);

class _PreviewScanFlowNotifier extends ScanFlowNotifier {
  @override
  ScanFlowState build() => ScanFlowState(
    selectedIds: const {'0', '1', '2'},
    savedAt: DateTime(2026, 9, 18, 11, 30),
  );
}
