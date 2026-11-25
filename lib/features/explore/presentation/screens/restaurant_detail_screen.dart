import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_menu_card.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_icons.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';

class CheckedMenu {
  const CheckedMenu({
    required this.dishId,
    required this.koreanName,
    required this.englishName,
  });

  /// 메뉴 상세로 이동할 때 쓰는 dish id입니다.
  final int dishId;
  final String koreanName;
  final String englishName;
}

/// 저장(북마크) 상태는 바깥에서 받습니다. ([saved], [onToggleSaved])
class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({
    super.key,
    required this.name,
    required this.info,
    required this.menus,
    this.saved = false,
    this.loadingMore = false,
    this.loadMoreFailed = false,
    this.onBack,
    this.onToggleSaved,
    this.onForYouTap,
    this.onMenuTap,
    this.onLoadMore,
    this.onRetryLoadMore,
  });

  final String name;
  final String info;
  final List<CheckedMenu> menus;
  final bool saved;
  final bool loadingMore;
  final bool loadMoreFailed;

  final VoidCallback? onBack;
  final VoidCallback? onToggleSaved;
  final VoidCallback? onForYouTap;
  final ValueChanged<CheckedMenu>? onMenuTap;

  /// 목록 끝에 가깝거나 화면에 다 들어갈 때 호출됩니다. (다음 페이지 불러오기)
  final VoidCallback? onLoadMore;

  /// 다음 페이지 요청이 실패했을 때 다시 시도 버튼에서 호출됩니다.
  final VoidCallback? onRetryLoadMore;

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  static const _loadMoreThreshold = 300.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkLoadMore);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkLoadMore() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < _loadMoreThreshold) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkLoadMore();
    });

    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Restaurant Detail',
        onBack: widget.onBack ?? () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    style: BitokTextStyles.title.copyWith(
                      color: BitokColors.text,
                    ),
                  ),
                ),
                _BookmarkButton(
                  saved: widget.saved,
                  onTap: widget.onToggleSaved,
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              widget.info,
              style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.exploreCheckedMenu,
                    style: BitokTextStyles.subTitle.copyWith(
                      fontSize: 20,
                      color: BitokColors.text,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onForYouTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.exploreForYou,
                        style: BitokTextStyles.buttonText2.copyWith(
                          color: BitokColors.primary,
                        ),
                      ),
                      SvgPicture.asset(
                        BitokIcons.leftArrow20,
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            for (final menu in widget.menus) ...[
              BitokMenuDetailCard(
                koreanName: menu.koreanName,
                englishName: menu.englishName,
                onTap: () => widget.onMenuTap?.call(menu),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.loadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (widget.loadMoreFailed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      l10n.errorLoadFailed,
                      style: BitokTextStyles.body2.copyWith(
                        color: BitokColors.grey0,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onRetryLoadMore,
                      style: TextButton.styleFrom(
                        foregroundColor: BitokColors.primary,
                      ),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.saved, this.onTap});

  final bool saved;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SvgPicture.asset(
          saved ? BitokIcons.saveOn24 : BitokIcons.saveOff24,
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}
