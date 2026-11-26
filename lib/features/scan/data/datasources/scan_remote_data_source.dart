import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/analyze_request.dart';
import '../models/analyze_response.dart';
import '../models/answer_request.dart';
import '../models/scan_response.dart';
import '../models/scan_result_response.dart';

class ScanRemoteDataSource {
  ScanRemoteDataSource(this._api);

  final ApiClient _api;

  /// 메뉴판 사진을 올려 메뉴명을 읽습니다. 응답까지 10~25초 걸립니다.
  ///
  /// [imagePath]는 업로드 전에 긴 변 1600px, JPEG 85로 줄여 둔 파일이어야 합니다.
  /// FormData를 넘기면 Dio가 Content-Type을 multipart/form-data로 바꿉니다.
  Future<ScanResponse> createScan({
    required String imagePath,
    int? restaurantId,
  }) async => ApiClient.decode(
    await _api.post(
      '/api/scans',
      data: FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
        'restaurant_id': ?restaurantId,
      }),
      options: ApiClient.longRunning,
    ),
    ScanResponse.fromJson,
  );

  /// 고른 메뉴를 분석하고 직원에게 확인할 질문을 만듭니다. LLM을 거치므로 오래 걸립니다.
  Future<AnalyzeResponse> analyze(int scanId, AnalyzeRequest request) async =>
      ApiClient.decode(
        await _api.post(
          '/api/scans/$scanId/analyze',
          data: request.toJson(),
          options: ApiClient.longRunning,
        ),
        AnalyzeResponse.fromJson,
      );

  /// 질문 하나에 대한 직원 응답을 기록합니다. 성공하면 204(body 없음)입니다.
  Future<void> answer(int scanId, AnswerRequest request) async {
    await _api.post('/api/scans/$scanId/answers', data: request.toJson());
  }

  /// 모든 질문이 끝난 뒤 직원 응답을 반영한 최종 판정을 가져옵니다.
  Future<ScanResultResponse> result(int scanId) async => ApiClient.decode(
    await _api.get('/api/scans/$scanId/result'),
    ScanResultResponse.fromJson,
  );
}

final scanRemoteDataSourceProvider = Provider<ScanRemoteDataSource>(
  (ref) => ScanRemoteDataSource(ref.watch(apiClientProvider)),
);
