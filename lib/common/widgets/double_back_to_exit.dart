import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';

/// 뒤로 가기를 누르면 앱이 종료되는 화면(로그인, 홈·Explore 탭 등)을 감쌉니다.
///
/// 첫 번째 뒤로 가기에는 '한 번 더 누르면 종료' 안내를 띄우고,
/// [_window] 안에 한 번 더 누르면 앱을 종료합니다.
///
/// 하위 화면의 PopScope가 뒤로 가기를 막고 있으면(예: Explore 검색 닫기) 그쪽이 먼저 처리하고,
/// 이 위젯은 호출되지 않습니다.
class DoubleBackToExit extends StatefulWidget {
  const DoubleBackToExit({
    super.key,
    required this.child,
    this.bottomOffset = 0,
  });

  final Widget child;

  /// 안내가 화면 하단 요소(예: 떠 있는 네비게이션 바)에 가리지 않도록 띄울 높이입니다.
  final double bottomOffset;

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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: _window,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(24, 0, 24, widget.bottomOffset + 16),
          content: Text(
            AppLocalizations.of(context).appExitConfirm,
            textAlign: TextAlign.center,
            style: BitokTextStyles.body2.copyWith(color: BitokColors.white),
          ),
        ),
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
