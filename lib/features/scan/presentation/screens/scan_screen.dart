import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../data/models/scan_restaurant.dart';
import '../widgets/scan_restaurant_card.dart';
import '../widgets/scan_source_button.dart';

/// REST-02 · 메뉴판을 카메라로 찍거나 갤러리에서 고르는 화면입니다.
///
/// 이미지를 고르면 [onImageSelected]가 호출되고, 선택을 취소하면 아무 일도 일어나지 않습니다.
class ScanScreen extends ConsumerWidget {
  const ScanScreen({
    super.key,
    required this.restaurant,
    this.onBack,
    this.onImageSelected,
  });

  final ScanRestaurant restaurant;
  final VoidCallback? onBack;
  final ValueChanged<XFile>? onImageSelected;

  static const double _horizontalPadding = 24;

  Future<void> _pick(
    BuildContext context,
    Future<XFile?> Function() pick,
  ) async {
    try {
      final image = await pick();
      if (image != null) onImageSelected?.call(image);
    } on PlatformException {
      // 권한 거부 등으로 카메라/갤러리를 열 수 없는 경우입니다.
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please allow camera and photo access in Settings.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picker = ref.watch(imagePickerServiceProvider);

    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Scan',
        onBack: onBack ?? () => Navigator.maybePop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          _horizontalPadding,
          12,
          _horizontalPadding,
          34,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan the menu',
              style: BitokTextStyles.title.copyWith(color: BitokColors.text),
            ),
            const SizedBox(height: 3),
            Text(
              'Fit the full menu inside the frame',
              style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
            ),
            const SizedBox(height: 25),
            ScanRestaurantCard(restaurant: restaurant),
            const SizedBox(height: 50),
            ScanSourceButton.camera(
              onTap: () => _pick(context, picker.pickFromCamera),
            ),
            const SizedBox(height: 12),
            ScanSourceButton.gallery(
              onTap: () => _pick(context, picker.pickFromGallery),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'REST-02 Scan', size: Size(390, 844))
Widget scanScreenPreview() => const ProviderScope(
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScanScreen(
      restaurant: ScanRestaurant(
        name: 'Myeongdong Kyoja',
        category: 'Korean Restaurant',
        address: '29 Myeongdong 10-gil, Jung-gu',
      ),
    ),
  ),
);
