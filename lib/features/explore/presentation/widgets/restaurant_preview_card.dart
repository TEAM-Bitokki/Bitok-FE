import 'package:flutter/material.dart';

import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../models/map_restaurant.dart';


class RestaurantPreviewCard extends StatelessWidget {
  const RestaurantPreviewCard({
    super.key,
    required this.restaurant,
    required this.footer,
    this.trailing,
    this.footerGap = 35,
    this.bottomPadding = 10,
  });

  final MapRestaurant restaurant;
  final Widget? trailing;
  final Widget footer;
  final double footerGap;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: BitokColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 34),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 25, 24, bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      restaurant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BitokTextStyles.body1.copyWith(
                        color: BitokColors.text,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
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
              SizedBox(height: footerGap),
              footer,
            ],
          ),
        ),
      ),
    );
  }
}
