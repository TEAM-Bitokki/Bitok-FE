import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';
import 'bitok_status_chip.dart';

/// 최근 확인한 메뉴 카드입니다.
///
/// 메뉴명, 음식점과 확인 시점, View details 링크, 판정 칩을 보여줍니다.
class BitokRecentMenuCard extends StatelessWidget {
  const BitokRecentMenuCard({
    super.key,
    required this.koreanName,
    required this.englishName,
    required this.subtitle,
    required this.status,
    this.onTap,
    this.onViewDetailsTap,
  });

  /// 한글 메뉴명입니다. 예: '비빔밥'
  final String koreanName;

  /// 영문 메뉴명입니다. 예: 'Bibimbap'
  final String englishName;

  /// 메뉴명 아래에 표시할 음식점과 확인 시점입니다. 예: 'Myeongdong Kyoja · Today'
  final String subtitle;

  /// 칩에 표시할 판정 결과입니다.
  final BitokMenuStatus status;

  /// 카드를 누르면 호출됩니다.
  final VoidCallback? onTap;

  /// View details를 누르면 호출됩니다. 없으면 [onTap]이 호출됩니다.
  final VoidCallback? onViewDetailsTap;

  @override
  Widget build(BuildContext context) {
    return _MenuCardContainer(
      onTap: onTap,
      trailing: BitokStatusChip(status: status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MenuName(
            koreanName: koreanName,
            englishName: englishName,
            englishColor: BitokColors.text,
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BitokTextStyles.body3.copyWith(color: BitokColors.grey0),
          ),
          const SizedBox(height: 13),
          _ViewDetails(onTap: onViewDetailsTap ?? onTap),
        ],
      ),
    );
  }
}

/// 메뉴 판정 결과 화면의 메뉴 카드입니다.
///
/// [status]를 넘기면 View details 링크와 판정 칩이 있는 카드가,
/// 넘기지 않으면 메뉴명과 화살표만 있는 카드가 됩니다.
class BitokMenuDetailCard extends StatelessWidget {
  const BitokMenuDetailCard({
    super.key,
    required this.koreanName,
    required this.englishName,
    this.status,
    this.onTap,
    this.onViewDetailsTap,
  });

  /// 한글 메뉴명입니다. 예: '김치찌개'
  final String koreanName;

  /// 영문 메뉴명입니다. 예: 'Kimchi Jjigae'
  final String englishName;

  /// 칩에 표시할 판정 결과입니다. 없으면 판정 없는 카드가 됩니다.
  final BitokMenuStatus? status;

  /// 카드를 누르면 호출됩니다.
  final VoidCallback? onTap;

  /// View details를 누르면 호출됩니다. 없으면 [onTap]이 호출됩니다. [status]가 없으면 쓰이지 않습니다.
  final VoidCallback? onViewDetailsTap;

  @override
  Widget build(BuildContext context) {
    final status = this.status;

    if (status == null) {
      return _MenuCardContainer(
        onTap: onTap,
        trailing: const _TrailingChevron(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _KoreanName(koreanName),
            const SizedBox(height: 6),
            _EnglishName(englishName, color: BitokColors.grey0),
          ],
        ),
      );
    }

    return _MenuCardContainer(
      onTap: onTap,
      trailing: BitokStatusChip(status: status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MenuName(
            koreanName: koreanName,
            englishName: englishName,
            englishColor: BitokColors.grey0,
          ),
          const SizedBox(height: 16),
          _ViewDetails(onTap: onViewDetailsTap ?? onTap),
        ],
      ),
    );
  }
}

/// 저장한 음식점 카드입니다.
///
/// 음식점 이름, 업종, 주소와 오른쪽 화살표를 보여줍니다.
class BitokSavedRestaurantCard extends StatelessWidget {
  const BitokSavedRestaurantCard({
    super.key,
    required this.name,
    required this.category,
    required this.address,
    this.onTap,
  });

  /// 음식점 이름입니다. 예: 'Myeongdong Kyoja'
  final String name;

  /// 업종입니다. 예: 'Korean Restaurant'
  final String category;

  /// 주소입니다. 예: '29 Myeongdong 10-gil, Jung-gu'
  final String address;

  /// 카드를 누르면 호출됩니다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final detailStyle = BitokTextStyles.body3.copyWith(
      color: BitokColors.grey0,
    );

    return _MenuCardContainer(
      onTap: onTap,
      trailing: const _TrailingChevron(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BitokTextStyles.body1.copyWith(color: BitokColors.text),
          ),
          const SizedBox(height: 15),
          Text(
            category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: detailStyle,
          ),
          const SizedBox(height: 5),
          Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: detailStyle,
          ),
        ],
      ),
    );
  }
}

class _MenuCardContainer extends StatelessWidget {
  const _MenuCardContainer({
    required this.child,
    required this.trailing,
    this.onTap,
  });

  final Widget child;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: BitokColors.grey3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: child),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _MenuName extends StatelessWidget {
  const _MenuName({
    required this.koreanName,
    required this.englishName,
    required this.englishColor,
  });

  final String koreanName;
  final String englishName;
  final Color englishColor;

  // 한글 이름 한 줄, 영문 이름 한 줄로 나눠 보여주고, 각 줄이 넘치면 '…'로 자릅니다.
  // (한 줄에 나란히 두면 한글 이름이 줄어들 수 없어서, 긴 서버 메뉴명에서 overflow가 났습니다)
  // 판정 없는 카드(BitokMenuDetailCard, status: null)와 같은 배치·간격입니다.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 사용자가 직접 추가한 메뉴처럼 한글 이름이 없으면 영문 이름만 보여줍니다.
        if (koreanName.isNotEmpty) ...[
          _KoreanName(koreanName),
          const SizedBox(height: 6),
        ],
        _EnglishName(englishName, color: englishColor),
      ],
    );
  }
}

class _KoreanName extends StatelessWidget {
  const _KoreanName(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: BitokTextStyles.body1KOR.copyWith(color: BitokColors.text),
    );
  }
}

class _EnglishName extends StatelessWidget {
  const _EnglishName(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: BitokTextStyles.body2.copyWith(color: color),
    );
  }
}

class _ViewDetails extends StatelessWidget {
  const _ViewDetails({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View details',
              style: BitokTextStyles.body2.copyWith(color: BitokColors.primary),
            ),
            SvgPicture.asset(BitokIcons.leftArrow20, width: 20, height: 20),
          ],
        ),
      ),
    );
  }
}

class _TrailingChevron extends StatelessWidget {
  const _TrailingChevron();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(BitokIcons.leftArrow24, width: 24, height: 24);
  }
}

@Preview(group: 'Common', name: 'Menu Card', size: Size(390, 640))
Widget menuCardPreview() => const ColoredBox(
  color: BitokColors.white,
  child: Padding(
    padding: EdgeInsets.all(24),
    child: Column(
      spacing: 22,
      children: [
        BitokRecentMenuCard(
          koreanName: '비빔밥',
          englishName: 'Bibimbap',
          subtitle: 'Myeongdong Kyoja · Today',
          status: BitokMenuStatus.safe,
        ),
        BitokSavedRestaurantCard(
          name: 'Myeongdong Kyoja',
          category: 'Korean Restaurant',
          address: '29 Myeongdong 10-gil, Jung-gu',
        ),
        BitokMenuDetailCard(
          koreanName: '김치찌개',
          englishName: 'Kimchi Jjigae',
          status: BitokMenuStatus.avoid,
        ),
        BitokMenuDetailCard(
          koreanName: '불고기',
          englishName: 'Bulgogi',
          status: BitokMenuStatus.notSure,
        ),
        BitokMenuDetailCard(koreanName: '김치찌개', englishName: 'Kimchi Jjigae'),
      ],
    ),
  ),
);
