import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_icons.dart';
import '../../../../core/design_system/bitok_text_styles.dart';

/// 홈 화면 상단의 메뉴 확인 진입 카드입니다.
class HomeCheckMenuCard extends StatelessWidget {
  const HomeCheckMenuCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
          decoration: BoxDecoration(
            color: BitokColors.blue2,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          BitokIcons.meal30,
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Check a menu',
                            style: BitokTextStyles.subTitle.copyWith(
                              color: BitokColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Find a restaurant, then scan its menu.',
                      style: BitokTextStyles.body2.copyWith(
                        color: BitokColors.grey0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SvgPicture.asset(BitokIcons.leftArrow24, width: 24, height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
