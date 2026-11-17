import 'package:flutter/material.dart';

import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../models/map_restaurant.dart';


class RestaurantRow extends StatelessWidget {
  const RestaurantRow({super.key, required this.restaurant, this.onTap});

  final MapRestaurant restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BitokColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: BitokColors.grey1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 76,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(17, 13, 17, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BitokTextStyles.body1.copyWith(color: BitokColors.text),
                ),
                const SizedBox(height: 6),
                Text(
                  restaurant.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BitokTextStyles.body3.copyWith(color: BitokColors.grey0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
