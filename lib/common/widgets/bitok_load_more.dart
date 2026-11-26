import 'package:flutter/material.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';

/// 무한 스크롤 목록에서 끝에 가까워지면 다음 페이지를 요청하는 공통 처리입니다.
///
/// [loadMoreController]를 목록의 ScrollController로 쓰고, [onNearEnd]에서 다음 페이지를 요청하세요.
/// 스크롤할 때뿐 아니라 화면을 그릴 때마다 확인하므로, 첫 페이지가 짧아 스크롤할 수 없을 때도 이어서 불러옵니다.
/// (중복 요청을 막는 건 받는 쪽(provider)이 맡습니다)
mixin LoadMoreOnScroll<T extends StatefulWidget> on State<T> {
  /// 목록 끝까지 이 높이보다 적게 남으면 다음 페이지를 요청합니다.
  static const double _threshold = 300;

  final ScrollController loadMoreController = ScrollController();

  /// 목록 끝에 가까워졌을 때 호출됩니다.
  void onNearEnd();

  @override
  void initState() {
    super.initState();
    loadMoreController.addListener(_check);
  }

  @override
  void dispose() {
    loadMoreController.dispose();
    super.dispose();
  }

  /// build에서 호출하세요. 그린 뒤 목록이 짧으면 바로 다음 페이지를 요청합니다.
  void checkLoadMoreAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _check();
    });
  }

  void _check() {
    if (!loadMoreController.hasClients) return;
    if (loadMoreController.position.extentAfter < _threshold) onNearEnd();
  }
}

/// 무한 스크롤 목록 끝에 붙이는 영역입니다.
/// 다음 페이지를 불러오는 중이면 로딩 표시, 실패했으면 안내 문구와 다시 시도 버튼을 보여줍니다.
class BitokLoadMoreFooter extends StatelessWidget {
  const BitokLoadMoreFooter({
    super.key,
    required this.loading,
    required this.failed,
    this.onRetry,
  });

  final bool loading;
  final bool failed;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(color: BitokColors.primary),
        ),
      );
    }
    if (!failed) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            l10n.errorLoadFailed,
            style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: BitokColors.primary),
            child: Text(l10n.commonRetry),
          ),
        ],
      ),
    );
  }
}
