import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_code.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/scan_flow_provider.dart';

/// 스캔·분석 요청이 실패했을 때 사용자에게 보여줄 문구입니다.
String scanErrorMessage(AppLocalizations l10n, Object error) {
  if (error is TooManyScanItemsException) {
    return l10n.scanErrorTooManyItems(error.maxItems);
  }
  if (error is! ApiException) return l10n.errorTryAgain;
  return switch (error.code) {
    ErrorCode.noMenuDetected => l10n.scanErrorNoMenu,
    ErrorCode.ocrLowConfidence => l10n.scanErrorBlurry,
    ErrorCode.invalidImage => l10n.scanErrorInvalidImage,
    ErrorCode.profileRequired => l10n.scanErrorProfileRequired,
    // 저장한 스캔은 다시 분석할 수 없어서(409), 다시 시도해도 계속 실패합니다.
    ErrorCode.alreadyExists => l10n.scanErrorAlreadySaved,
    ErrorCode.llmUnavailable ||
    ErrorCode.llmTimeout ||
    ErrorCode.timeout => l10n.scanErrorSlow,
    _ => l10n.errorTryAgain,
  };
}
