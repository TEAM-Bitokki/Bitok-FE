import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/generated/app_localizations.dart';
import 'bitok_toast.dart';

/// 뒤로 가기를 누르면 앱이 종료되는 화면(로그인, 홈·Explore 탭 등)을 감쌉니다.
///
/// 첫 번째 뒤로 가기에는 '한 번 더 누르면 종료' 안내를 띄우고,
/// [_window] 안에 한 번 더 누르면 앱을 종료합니다.
///
/// 하위 화면의 PopScope가 뒤로 가기를 막고 있으면(예: Explore 검색 닫기) 그쪽이 먼저 처리하고,
/// 이 위젯은 호출되지 않습니다.
///
/// 안내 위치: 화면 하단 안전 영역 위로 [bottomOffset] + [gap]만큼 떨어진 곳에 안내 아래쪽 끝이 옵니다.
/// (안전 영역(홈 인디케이터 등) 높이는 Scaffold가 알아서 더하므로 여기 넣지 않습니다)
class DoubleBackToExit extends StatefulWidget {
  const DoubleBackToExit({
    super.key,
    required this.child,
    this.bottomOffset = 0,
    this.gap = defaultGap,
  });

  /// 안내와 그 아래 요소(버튼, 네비게이션 바) 사이의 기본 간격입니다.
  static const double defaultGap = bitokToastGap;

  final Widget child;

  /// 안내가 가리지 않아야 하는 하단 요소의 높이입니다. 안전 영역 위부터 그 요소 윗변까지 잽니다.
  /// 예: 하단 버튼(60)이 안전 영역에서 10 떨어져 있으면 70.
  final double bottomOffset;

  /// 그 요소 윗변과 안내 사이의 간격입니다.
  final double gap;

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  /// 두 번째 뒤로 가기를 기다리는 시간이자 안내가 떠 있는 시간입니다.
  static const Duration _window = Duration(seconds: 2);

  /// 첫 번째 뒤로 가기 뒤 [_window] 동안 켜져 있는 타이머입니다. 켜져 있을 때 또 누르면 종료합니다.
  Timer? _exitWindow;

  @override
  void dispose() {
    _exitWindow?.cancel();
    super.dispose();
  }

  void _onBack() {
    if (_exitWindow?.isActive ?? false) {
      _exitWindow?.cancel();
      SystemNavigator.pop();
      return;
    }
    _exitWindow = Timer(_window, () {});

    showBitokToast(
      context,
      AppLocalizations.of(context).appExitConfirm,
      bottomOffset: widget.bottomOffset,
      gap: widget.gap,
      duration: _window,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: widget.child,
    );
  }
}
