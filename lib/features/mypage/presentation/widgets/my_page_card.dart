import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/design_system/bitok_icons.dart';

class MyPageCard extends StatelessWidget {
  const MyPageCard({
    super.key,
    required this.color,
    required this.radius,
    required this.height,
    required this.child,
    this.onTap,
  });

  final Color color;
  final double radius;
  final double height;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(child: child),
              Positioned(
                right: 18,
                top: 0,
                bottom: 0,
                child: Center(
                  child: SvgPicture.asset(
                    BitokIcons.leftArrow24,
                    width: 24,
                    height: 24,
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
