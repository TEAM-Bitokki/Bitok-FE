import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';
import 'bitok_status_chip.dart';

// Figma: Card / Menu (543:3020)
// - BitokRecentMenuCard      : RecentChekedMenu (최근 확인 메뉴)
// - BitokMenuDetailCard      : Menu_detail_personal / Menu_detail_notpersonal
// - BitokSavedRestaurantCard : Saved_resturant (저장한 음식점)

/// 최근 확인한 메뉴 카드. 메뉴명, 음식점·확인 시점, 판정 칩을 보여줍니다.
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

  final String koreanName;
  final String englishName;

  /// 예: 'Myeongdong Kyoja · Today'
  final String subtitle;
  final BitokMenuStatus status;
  final VoidCallback? onTap;

  /// 'View details' 탭 시 호출됩니다. 없으면 [onTap]이 호출됩니다.
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

/// 메뉴 상세 카드.
///
/// [status]가 있으면 개인 맞춤 판정(칩 + View details)을,
/// 없으면 판정 없이 메뉴명과 chevron만 보여줍니다.
class BitokMenuDetailCard extends StatelessWidget {
  const BitokMenuDetailCard({
    super.key,
    required this.koreanName,
    required this.englishName,
    this.status,
    this.onTap,
    this.onViewDetailsTap,
  });

  final String koreanName;
  final String englishName;
  final BitokMenuStatus? status;
  final VoidCallback? onTap;

  /// 'View details' 탭 시 호출됩니다. 없으면 [onTap]이 호출됩니다.
  /// [status]가 없으면 'View details'가 표시되지 않으므로 사용되지 않습니다.
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

/// 저장한 음식점 카드.
class BitokSavedRestaurantCard extends StatelessWidget {
  const BitokSavedRestaurantCard({
    super.key,
    required this.name,
    required this.category,
    required this.address,
    this.onTap,
  });

  final String name;
  final String category;
  final String address;
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

/// 공통 카드 틀: grey3 배경, 모서리 12, 상하 15 / 좌우 18 여백.
/// [trailing]은 카드 오른쪽에 세로 중앙 정렬됩니다.
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

/// 한글 메뉴명 + 영문 메뉴명 (가로 배치, 간격 10)
class _MenuName extends StatelessWidget {
  const _MenuName({
    required this.koreanName,
    required this.englishName,
    required this.englishColor,
  });

  final String koreanName;
  final String englishName;
  final Color englishColor;

  @override
  Widget build(BuildContext context) {
    // 폰트(Pretendard/Roboto)와 크기가 달라 박스 중앙 정렬로는 글자 바닥선이
    // 어긋나므로, 기준선(baseline)에 맞춰 정렬합니다.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        _KoreanName(koreanName),
        const SizedBox(width: 10),
        Flexible(child: _EnglishName(englishName, color: englishColor)),
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
        // 글자 사이 빈 공간까지 터치 영역에 포함합니다.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View details',
              style: BitokTextStyles.body2.copyWith(color: BitokColors.primary),
            ),
            // 에셋 이름과 달리 오른쪽을 향하는 파란색 chevron입니다.
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
    // 에셋 이름과 달리 오른쪽을 향하는 회색 chevron입니다.
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
