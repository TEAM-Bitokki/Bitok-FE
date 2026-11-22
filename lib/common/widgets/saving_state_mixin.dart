import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// 화면 하단에 안내 문구를 스낵바로 띄웁니다. 이미 떠 있는 스낵바는 바로 닫습니다.
void showMessageSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// 서버에 저장하는 버튼이 있는 화면에서 쓰는 공통 처리입니다.
///
/// - 저장하는 동안 [saving]이 true입니다. 버튼을 비활성화해 중복 요청을 막으세요.
/// - 실패하면 '다시 시도' 스낵바를 띄우고 화면에 그대로 남습니다.
///
/// ```dart
/// onPressed: saving ? null : () => runSaving(widget.onSave!),
/// ```
mixin SavingStateMixin<T extends StatefulWidget> on State<T> {
  bool _saving = false;

  bool get saving => _saving;

  Future<void> runSaving(Future<void> Function() save) async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await save();
    } catch (_) {
      if (mounted) {
        showMessageSnackBar(
          context,
          AppLocalizations.of(context).errorTryAgain,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
