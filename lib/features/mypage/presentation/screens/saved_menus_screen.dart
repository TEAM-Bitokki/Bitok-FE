import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_empty_state.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_load_more.dart';
import '../../../../common/widgets/bitok_menu_card.dart';
import '../../../../common/widgets/bitok_status_chip.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

class SavedMenu {
  const SavedMenu({
    required this.analysisId,
    required this.koreanName,
    required this.englishName,
    required this.subtitle,
    required this.status,
  });

  /// 내 기록의 메뉴 상세('/analysis/:id')로 이동할 때 쓰는 analysis_id입니다.
  final int analysisId;
  final String koreanName;
  final String englishName;

  final String subtitle;
  final BitokMenuStatus status;
}

class SavedMenusScreen extends StatefulWidget {
  const SavedMenusScreen({
    super.key,
    required this.menus,
    this.isLoading = false,
    this.loadFailed = false,
    this.onRetry,
    this.loadingMore = false,
    this.loadMoreFailed = false,
    this.onLoadMore,
    this.onRetryLoadMore,
    this.onBack,
    this.onMenuTap,
  });

  final List<SavedMenu> menus;

  /// 목록을 처음 불러오는 중이면 true입니다. 목록 대신 로딩 표시를 보여줍니다.
  final bool isLoading;

  /// 목록을 불러오지 못했으면 true입니다. 빈 화면 대신 안내 문구와 [onRetry] 버튼을 보여줍니다.
  /// (저장한 메뉴가 없는 것과 불러오지 못한 것을 구분합니다)
  final bool loadFailed;
  final VoidCallback? onRetry;

  /// 다음 페이지를 불러오는 중이면 true입니다. 목록 끝에 로딩 표시를 보여줍니다.
  final bool loadingMore;

  /// 다음 페이지를 불러오지 못했으면 true입니다. 목록 끝에 다시 시도 버튼을 보여줍니다.
  final bool loadMoreFailed;

  /// 목록 끝에 가까워지면 호출됩니다(무한 스크롤).
  final VoidCallback? onLoadMore;
  final VoidCallback? onRetryLoadMore;

  final VoidCallback? onBack;
  final ValueChanged<SavedMenu>? onMenuTap;

  @override
  State<SavedMenusScreen> createState() => _SavedMenusScreenState();
}

class _SavedMenusScreenState extends State<SavedMenusScreen>
    with LoadMoreOnScroll {
  @override
  void onNearEnd() => widget.onLoadMore?.call();

  @override
  Widget build(BuildContext context) {
    checkLoadMoreAfterBuild();
    final menus = widget.menus;

    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Saved Menues',
        onBack: widget.onBack ?? () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        top: false,
        child: widget.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: BitokColors.primary),
              )
            : menus.isEmpty
            // 홈 Recent checks의 빈 상태와 같은 위치(목록 시작점 아래)에 둡니다.
            ? Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 45, 24, 24),
                  child: widget.loadFailed
                      ? BitokLoadMoreFooter(
                          loading: false,
                          failed: true,
                          onRetry: widget.onRetry,
                        )
                      : BitokEmptyState(
                          message: AppLocalizations.of(context).savedMenusEmpty,
                        ),
                ),
              )
            : ListView.separated(
                controller: loadMoreController,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                // 마지막 한 칸은 다음 페이지 로딩·다시 시도 영역입니다.
                itemCount: menus.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == menus.length) {
                    return BitokLoadMoreFooter(
                      loading: widget.loadingMore,
                      failed: widget.loadMoreFailed,
                      onRetry: widget.onRetryLoadMore,
                    );
                  }
                  final menu = menus[index];
                  return BitokRecentMenuCard(
                    koreanName: menu.koreanName,
                    englishName: menu.englishName,
                    subtitle: menu.subtitle,
                    status: menu.status,
                    onTap: () => widget.onMenuTap?.call(menu),
                  );
                },
              ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Saved Menus', size: Size(390, 844))
Widget savedMenusPreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: SavedMenusScreen(
    menus: [
      SavedMenu(
        analysisId: 551,
        koreanName: '비빔밥',
        englishName: 'Bibimbap',
        subtitle: 'Myeongdong Kyoja · Today',
        status: BitokMenuStatus.safe,
      ),
      SavedMenu(
        analysisId: 552,
        koreanName: '김치찌개',
        englishName: 'Kimchi Jjigae',
        subtitle: 'Myeongdong Kyoja · Today',
        status: BitokMenuStatus.avoid,
      ),
      SavedMenu(
        analysisId: 553,
        koreanName: '불고기',
        englishName: 'Bulgogi',
        subtitle: 'Myeongdong Kyoja · Today',
        status: BitokMenuStatus.notSure,
      ),
    ],
  ),
);
