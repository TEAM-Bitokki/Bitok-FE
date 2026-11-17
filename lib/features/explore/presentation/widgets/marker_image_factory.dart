import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';

class MarkerImageFactory {
  const MarkerImageFactory._();

  static const _defaultAsset = 'assets/icons/ic_location_default.png';
  static const _selectedAsset = 'assets/icons/ic_location_selected.png';
  static const _myLocationAsset = 'assets/icons/ic_mylocation.png';

  static const int width = 28;
  static const int height = 36;

  static final Map<String, Future<KImage>> _cache = {};

  static Future<KImage> create({required int count, bool selected = false}) {
    return _cache.putIfAbsent(
      '$count-$selected',
          () => _build(count: count, selected: selected),
    );
  }

  static Future<Offset> _findCircleCenter(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final pixels = data!.buffer.asUint8List();
    final w = image.width;

    var bestRow = 0;
    var bestWidth = 0;
    var bestCenterX = w / 2;
    for (var y = 0; y < image.height; y++) {
      var first = -1;
      var last = -1;
      for (var x = 0; x < w; x++) {
        if (pixels[(y * w + x) * 4 + 3] >= 250) {
          if (first < 0) first = x;
          last = x;
        }
      }
      if (first >= 0 && last - first + 1 > bestWidth) {
        bestWidth = last - first + 1;
        bestRow = y;
        bestCenterX = (first + last) / 2;
      }
    }
    return Offset(bestCenterX + 0.5, bestRow + 0.5);
  }

  static Future<KImage> _build({
    required int count,
    required bool selected,
  }) async {
    final bytes = await rootBundle.load(
      selected ? _selectedAsset : _defaultAsset,
    );
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    final base = (await codec.getNextFrame()).image;

    final scale = base.width / width;
    final center = await _findCircleCenter(base);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(base, Offset.zero, Paint());

    if (count >= 0) {
      final label = count > 99 ? '99+' : '$count';
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: BitokTextStyles.body1.copyWith(
            fontSize: (label.length >= 3 ? 13 : 16) * scale,
            color: selected ? BitokColors.white : BitokColors.primary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          center.dx - painter.width / 2,
          center.dy - painter.height / 2,
        ),
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(base.width, base.height);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return KImage.fromData(data!.buffer.asUint8List(), width, height);
  }

  static KImage myLocation() => KImage.fromAsset(_myLocationAsset, 18, 18);
}