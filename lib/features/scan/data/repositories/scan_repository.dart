import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/scan_remote_data_source.dart';
import '../models/analyze_request.dart';
import '../models/analyze_response.dart';
import '../models/answer_request.dart';
import '../models/scan_response.dart';
import '../models/scan_result_response.dart';

// 스캔 플로우 순서: createScan → analyze → answer(질문마다) → result
// 실패하면 ApiException을 던집니다. 스캔에서 자주 보는 code:
//   createScan: noMenuDetected, ocrLowConfidence, invalidImage, profileRequired,
//               llmUnavailable, llmTimeout
//   analyze:    validationError(목록에 없는 temp_id), alreadyExists, profileRequired,
//               llmUnavailable, llmTimeout
//   result:     notFound(아직 분석 전)
class ScanRepository {
  const ScanRepository(this._remote);

  final ScanRemoteDataSource _remote;

  Future<ScanResponse> createScan({
    required String imagePath,
    int? restaurantId,
  }) => _remote.createScan(imagePath: imagePath, restaurantId: restaurantId);

  Future<AnalyzeResponse> analyze({
    required int scanId,
    required List<AnalyzeItem> items,
    required List<String> selectedTempIds,
  }) => _remote.analyze(
    scanId,
    AnalyzeRequest(items: items, selectedTempIds: selectedTempIds),
  );

  Future<void> answer({
    required int scanId,
    required int questionId,
    required StaffAnswerValue answer,
  }) => _remote.answer(
    scanId,
    AnswerRequest(questionId: questionId, answer: answer),
  );

  Future<ScanResultResponse> result(int scanId) => _remote.result(scanId);
}

final scanRepositoryProvider = Provider<ScanRepository>(
  (ref) => ScanRepository(ref.watch(scanRemoteDataSourceProvider)),
);
