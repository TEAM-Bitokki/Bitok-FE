import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_load_more.dart';
import '../../../../common/widgets/bitok_menu_card.dart';
import '../../../../common/widgets/bitok_status_chip.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_images.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../core/router/main_shell.dart';
import '../widgets/home_check_menu_card.dart';

class RecentCheck {
  const RecentCheck({
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.recentChecks,
    this.isLoading = false,
    this.loadFailed = false,
    this.onRetry,
    this.loadingMore = false,
    this.loadMoreFailed = false,
    this.onLoadMore,
    this.onRetryLoadMore,
    this.onProfileTap,
    this.onCheckMenuTap,
    this.onRecentCheckTap,
  });

  /// 최근 확인한 메뉴 목록입니다. 비어 있으면 안내 문구를 보여줍니다.
  final List<RecentCheck> recentChecks;

  /// 목록을 처음 불러오는 중이면 true입니다. 목록 자리에 로딩 표시를 보여줍니다.
  final bool isLoading;

  /// 목록을 불러오지 못했으면 true입니다. 'No checks yet' 대신 안내 문구와 [onRetry] 버튼을 보여줍니다.
  final bool loadFailed;
  final VoidCallback? onRetry;

  /// 다음 페이지를 불러오는 중이면 true입니다. 목록 끝에 로딩 표시를 보여줍니다.
  final bool loadingMore;

  /// 다음 페이지를 불러오지 못했으면 true입니다. 목록 끝에 다시 시도 버튼을 보여줍니다.
  final bool loadMoreFailed;

  /// 목록 끝에 가까워지면 호출됩니다(무한 스크롤).
  final VoidCallback? onLoadMore;
  final VoidCallback? onRetryLoadMore;

  final VoidCallback? onProfileTap;
  final VoidCallback? onCheckMenuTap;
  final ValueChanged<RecentCheck>? onRecentCheckTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with LoadMoreOnScroll {
  static const double _horizontalPadding = 24;

  /// 스크롤 끝에서 콘텐츠와 네비게이션 바 사이에 남겨 둘 간격입니다.
  static const double _contentEndGap = 20;

  @override
  void onNearEnd() => widget.onLoadMore?.call();

  @override
  Widget build(BuildContext context) {
    checkLoadMoreAfterBuild();
    final recentChecks = widget.recentChecks;

    // 네비게이션 바가 콘텐츠 위에 떠 있으므로, 스크롤 끝의 콘텐츠가 가려지지 않게 여백을 둡니다.
    final contentBottomPadding =
        MediaQuery.paddingOf(context).bottom +
        MainShell.contentBottomInset +
        _contentEndGap;

    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.home(
        logo: Image.asset(
          BitokImages.wordmarkNavy,
          width: 69,
          height: 40,
          // 이미지(207×120)가 박스와 비율이 같아 그대로 맞고, 바뀌더라도 찌그러지지 않게 비율을 지킵니다.
          fit: BoxFit.contain,
        ),
        onProfile: widget.onProfileTap,
      ),
      body: CustomScrollView(
        controller: loadMoreController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              _horizontalPadding,
              12,
              _horizontalPadding,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeCheckMenuCard(onTap: widget.onCheckMenuTap),
                  const SizedBox(height: 30),
                  Text(
                    'Recent checks',
                    style: BitokTextStyles.subTitle.copyWith(
                      color: BitokColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isLoading)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                _horizontalPadding,
                60,
                _horizontalPadding,
                contentBottomPadding,
              ),
              sliver: const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(color: BitokColors.primary),
                ),
              ),
            )
          else if (recentChecks.isEmpty && widget.loadFailed)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                _horizontalPadding,
                45,
                _horizontalPadding,
                contentBottomPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: BitokLoadMoreFooter(
                  loading: false,
                  failed: true,
                  onRetry: widget.onRetry,
                ),
              ),
            )
          else if (recentChecks.isEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                _horizontalPadding,
                33,
                _horizontalPadding,
                contentBottomPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Image.asset(BitokImages.noChecks, width: 200, height: 200),
                    const SizedBox(height: 17),
                    Text(
                      'No checks yet',
                      textAlign: TextAlign.center,
                      style: BitokTextStyles.body1.copyWith(
                        color: BitokColors.grey0,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                _horizontalPadding,
                15,
                _horizontalPadding,
                0,
              ),
              sliver: SliverList.separated(
                itemCount: recentChecks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final check = recentChecks[index];
                  return BitokRecentMenuCard(
                    koreanName: check.koreanName,
                    englishName: check.englishName,
                    subtitle: check.subtitle,
                    status: check.status,
                    onTap: () => widget.onRecentCheckTap?.call(check),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                _horizontalPadding,
                0,
                _horizontalPadding,
                contentBottomPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: BitokLoadMoreFooter(
                  loading: widget.loadingMore,
                  failed: widget.loadMoreFailed,
                  onRetry: widget.onRetryLoadMore,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Home', size: Size(390, 844))
Widget homePreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: HomeScreen(
    recentChecks: [
      RecentCheck(
        analysisId: 551,
        koreanName: '비빔밥',
        englishName: 'Bibimbap',
        subtitle: 'Myeongdong Kyoja · Today',
        status: BitokMenuStatus.safe,
      ),
      RecentCheck(
        analysisId: 552,
        koreanName: '비빔밥',
        englishName: 'Bibimbap',
        subtitle: 'Myeongdong Kyoja · Today',
        status: BitokMenuStatus.safe,
      ),
      RecentCheck(
        analysisId: 553,
        koreanName: '비빔밥',
        englishName: 'Bibimbap',
        subtitle: 'Myeongdong Kyoja · Today',
        status: BitokMenuStatus.safe,
      ),
    ],
  ),
);

@Preview(group: 'Screens', name: 'Home (Empty)', size: Size(390, 844))
Widget homeEmptyPreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: HomeScreen(recentChecks: []),
);
