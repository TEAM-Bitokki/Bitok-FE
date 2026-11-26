import 'package:json_annotation/json_annotation.dart';

part 'scan_response.g.dart';

/// POST /api/scans 응답. 메뉴판 사진에서 읽은 메뉴 목록입니다.
@JsonSerializable(createToJson: false)
class ScanResponse {
  const ScanResponse({
    required this.scanId,
    required this.items,
    required this.imageQuality,
    this.restaurantId,
  });

  factory ScanResponse.fromJson(Map<String, dynamic> json) =>
      _$ScanResponseFromJson(json);

  final int scanId;
  final int? restaurantId;
  final List<RecognizedItem> items;

  /// ok, blurry, cropped 중 하나입니다.
  final String imageQuality;
}

/// OCR이 읽은 메뉴 한 줄입니다.
@JsonSerializable(createToJson: false)
class RecognizedItem {
  const RecognizedItem({
    required this.tempId,
    required this.rawName,
    required this.confidence,
    this.nameEn,
  });

  factory RecognizedItem.fromJson(Map<String, dynamic> json) =>
      _$RecognizedItemFromJson(json);

  /// 이 스캔 안에서만 쓰는 임시 id입니다. analyze 요청에 그대로 돌려줍니다.
  final String tempId;

  /// 메뉴판에 적힌 이름입니다. 예: 김치찌개
  final String rawName;

  /// 로마자 표기입니다(번역 아님). 예: Kimchi Jjigae
  final String? nameEn;

  /// 0~1. 0.7 미만이면 인식 결과를 덜 믿을 만합니다.
  final double confidence;
}
