import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';


class BitokHeader extends StatelessWidget implements PreferredSizeWidget {
  const BitokHeader._({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.centerTitle = false,
  });

  factory BitokHeader.sub({
    Key? key,
    required String title,
    VoidCallback? onBack,
  }) {
    return BitokHeader._(
      key: key,
      title: title,
      centerTitle: true,
      leading: _IconTap(
        onTap: onBack,
        child: SvgPicture.asset(BitokIcons.rightArrow24, width: 24, height: 24),
      ),
    );
  }

  factory BitokHeader.explore({
    Key? key,
    required String title,
    VoidCallback? onProfile,
  }) {
    return BitokHeader._(
      key: key,
      title: title,
      trailing: _IconTap(
        onTap: onProfile,
        child: SvgPicture.asset(
          BitokIcons.myPage24,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(BitokColors.text, BlendMode.srcIn),
        ),
      ),
    );
  }

  factory BitokHeader.home({
    Key? key,
    required Widget logo,
    VoidCallback? onProfile,
  }) {
    return BitokHeader._(
      key: key,
      leading: logo,
      trailing: _IconTap(
        onTap: onProfile,
        child: SvgPicture.asset(BitokIcons.myPage24, width: 24, height: 24),
      ),
    );
  }

  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BitokColors.white,
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: centerTitle ? _centered() : _spaced(),
        ),
      ),
    );
  }

  Widget _centered() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (leading != null)
          Align(alignment: Alignment.centerLeft, child: leading),
        if (title != null)
          Text(
            title!,
            style: BitokTextStyles.header.copyWith(color: BitokColors.text),
          ),
        if (trailing != null)
          Align(alignment: Alignment.centerRight, child: trailing),
      ],
    );
  }

  Widget _spaced() {
    return Row(
      children: [
        ?leading,
        if (title != null)
          Text(
            title!,
            style: BitokTextStyles.titleKOR.copyWith(color: BitokColors.text),
          ),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(width: 24, height: 24, child: child),
    );
  }
}