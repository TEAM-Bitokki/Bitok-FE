import 'package:flutter/material.dart';

import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../data/models/scan_restaurant.dart';

/// 스캔 화면 상단에 표시하는 식당 정보 카드입니다.
class ScanRestaurantCard extends StatelessWidget {
  const ScanRestaurantCard({
    super.key,
    required this.restaurant,
    this.borderRadius = 20,
  });

  final ScanRestaurant restaurant;

  /// 모서리 반경입니다. REST-02는 20, REST-08은 18입니다.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
      decoration: BoxDecoration(
        color: BitokColors.blue2,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant.name,
            style: BitokTextStyles.body1.copyWith(color: BitokColors.text),
          ),
          const SizedBox(height: 12),
          Text(
            restaurant.category,
            style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
          ),
          const SizedBox(height: 4),
          Text(
            restaurant.address,
            style: BitokTextStyles.body3.copyWith(color: BitokColors.grey0),
          ),
        ],
      ),
    );
  }
}
