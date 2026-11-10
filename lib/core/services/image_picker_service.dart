import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// 메뉴판 이미지를 카메라 또는 갤러리에서 가져옵니다.
///
/// 업로드 용량을 줄이기 위해 긴 변을 [_maxDimension]으로 줄이고 [_imageQuality]로 압축합니다.
/// 사용자가 선택을 취소하면 null을 반환합니다.
class ImagePickerService {
  ImagePickerService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const double _maxDimension = 2048;
  static const int _imageQuality = 85;

  /// 카메라로 메뉴판을 촬영합니다.
  Future<XFile?> pickFromCamera() => _pick(ImageSource.camera);

  /// 갤러리에서 메뉴판 사진을 선택합니다.
  Future<XFile?> pickFromGallery() => _pick(ImageSource.gallery);

  Future<XFile?> _pick(ImageSource source) {
    return _picker.pickImage(
      source: source,
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
      imageQuality: _imageQuality,
    );
  }
}

final imagePickerServiceProvider = Provider<ImagePickerService>(
  (ref) => ImagePickerService(),
);
