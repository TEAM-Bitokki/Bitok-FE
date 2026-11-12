import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/services/location_service.dart';
import '../models/map_restaurant.dart';
import 'marker_image_factory.dart';

/// 지도 영역입니다. 식당은 위도/경도 기준으로 지도 위에 마커(POI)로 표시합니다.
///
/// 선택된 식당의 마커는 파란색(ic_marker_selected.png) 이미지로 바뀝니다.
/// 처음 시작 위치는 내 위치 주변입니다. 위치를 못 받으면 명동 근처에서 시작합니다.
class RestaurantMapView extends StatefulWidget {
  const RestaurantMapView({
    super.key,
    required this.restaurants,
    this.selectedId,
    this.onRestaurantTap,
    this.onMapTap,
    this.onMyLocationTap,
    this.sheet,
  });

  final List<MapRestaurant> restaurants;
  final String? selectedId;
  final ValueChanged<MapRestaurant>? onRestaurantTap;
  final VoidCallback? onMapTap;
  final VoidCallback? onMyLocationTap;

  /// 지도 아래쪽에 올라오는 카드 (식당 미리보기)
  final Widget? sheet;

  @override
  State<RestaurantMapView> createState() => _RestaurantMapViewState();
}

class _RestaurantMapViewState extends State<RestaurantMapView> {
  // 위치를 못 받을 때의 기본 시작 위치 (명동 근처)
  static const _fallbackPosition = LatLng(37.5636, 126.9850);

  // 내 위치를 알아낸 뒤 그 위치로 지도를 시작합니다.
  late final Future<({double lat, double lng})?> _startLocation =
  LocationService.current();

  Poi? _myLocationPoi;

  KakaoMapController? _controller;

  // POI id -> 식당. 마커를 눌렀을 때 어떤 식당인지 찾습니다.
  final Map<String, MapRestaurant> _poiRestaurants = {};

  // 식당 id -> 지도 위 마커. 선택이 바뀔 때 마커 이미지를 바꿉니다.
  final Map<String, _MapMarker> _markers = {};

  // 마커를 누르면 지도 클릭 이벤트도 같이 올 수 있어서, 직후의 지도 클릭은 무시합니다.
  DateTime _lastPoiTap = DateTime.fromMillisecondsSinceEpoch(0);

  // 시안: 아무것도 선택하지 않았을 때 현재 위치 버튼은 화면 아래에서 103px 위
  // (홈 바 34 + 69). 하단 탭 필 바로 위에 놓입니다.
  double _idleButtonBottom(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).bottom;
    return (inset < 34 ? 34 : inset) + 69;
  }

  Future<void> _addMarkers(KakaoMapController controller) async {
    for (final r in widget.restaurants) {
      try {
        // 마커 이미지에 메뉴 개수(숫자)를 그려서 기본/선택 두 가지 스타일을 만듭니다.
        final normal = PoiStyle(
          icon: await MarkerImageFactory.create(count: r.menuCount),
        );
        final selected = PoiStyle(
          icon: await MarkerImageFactory.create(
            count: r.menuCount,
            selected: true,
          ),
        );
        final poi = await controller.labelLayer.addPoi(
          LatLng(r.lat, r.lng),
          style: normal,
        );
        _poiRestaurants[poi.id.toString()] = r;
        _markers[r.id] = _MapMarker(poi, normal, selected);
      } catch (_) {
        // 마커 하나가 실패해도 나머지는 계속 표시합니다.
      }
    }
    await _syncSelection();
  }

  // 선택된 식당의 마커만 파란색 이미지로 바꾸고, 나머지는 기본 이미지로 되돌립니다.
  Future<void> _syncSelection() async {
    for (final entry in _markers.entries) {
      final marker = entry.value;
      final shouldSelect = entry.key == widget.selectedId;
      if (marker.selected == shouldSelect) continue;
      marker.selected = shouldSelect;
      try {
        await marker.poi.changeStyles(
          shouldSelect ? marker.selectedStyle : marker.normalStyle,
        );
      } catch (_) {
        // 이미지 변경에 실패하면 이전 모양을 유지합니다.
      }
    }
  }

  void _moveToSelected() {
    final id = widget.selectedId;
    if (id == null) return;
    for (final r in widget.restaurants) {
      if (r.id == id) {
        _controller?.moveCamera(
          CameraUpdate.newCenterPosition(LatLng(r.lat, r.lng)),
          animation: const CameraAnimation(300),
        );
        return;
      }
    }
  }

  void _onMapReady(KakaoMapController controller) {
    _controller = controller;
    // 검색 목록에서 돌아와 지도가 새로 만들어진 경우에도 선택된 식당을 보여 줍니다.
    _moveToSelected();
    _addMarkers(controller);
    _showMyLocation(LocationService.cached);
  }

  // 내 위치 점을 표시하거나, 이미 있으면 새 위치로 옮깁니다.
  Future<void> _showMyLocation(({double lat, double lng})? location) async {
    final controller = _controller;
    if (location == null || controller == null) return;
    final position = LatLng(location.lat, location.lng);
    try {
      final existing = _myLocationPoi;
      if (existing != null) {
        await existing.move(position);
      } else {
        final icon = MarkerImageFactory.myLocation();
        _myLocationPoi = await controller.labelLayer.addPoi(
          position,
          style: PoiStyle(icon: icon),
        );
      }
    } catch (_) {
      // 내 위치 점을 못 그려도 지도는 계속 사용할 수 있습니다.
    }
  }

  bool _locating = false;

  void _moveTo(({double lat, double lng}) location) {
    _controller?.moveCamera(
      CameraUpdate.newCenterPosition(LatLng(location.lat, location.lng)),
      animation: const CameraAnimation(300),
    );
  }

  // 현재 위치 버튼: 내 위치로 지도를 옮깁니다.
  Future<void> _goToMyLocation() async {
    widget.onMyLocationTap?.call();

    // 이미 알고 있는 위치가 있으면 기다리지 않고 바로 이동합니다.
    final cached = LocationService.cached;
    if (cached != null) {
      _moveTo(cached);
      _showMyLocation(cached);
    }

    // 위치를 새로 받는 중에 또 눌러도 요청이 겹치지 않게 합니다.
    if (_locating) return;
    _locating = true;
    try {
      final location = await LocationService.current(forceRefresh: true);
      if (!mounted) return;
      if (location == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Turn on location to see where you are.'),
          ),
        );
        return;
      }
      _moveTo(location);
      _showMyLocation(location);
    } finally {
      _locating = false;
    }
  }

  void _onPoiClick(LabelController labelController, Poi poi) {
    final restaurant = _poiRestaurants[poi.id.toString()];
    if (restaurant == null) return;
    _lastPoiTap = DateTime.now();
    widget.onRestaurantTap?.call(restaurant);
  }

  void _onMapClick(KPoint point, LatLng latLng) {
    if (DateTime.now().difference(_lastPoiTap).inMilliseconds < 400) return;
    widget.onMapTap?.call();
  }

  @override
  void didUpdateWidget(covariant RestaurantMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId != oldWidget.selectedId) {
      // 식당이 선택되면 그 식당 위치로 지도를 옮기고 마커 색을 바꿉니다.
      _moveToSelected();
      _syncSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sheet = widget.sheet;

    return Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder<({double lat, double lng})?>(
            future: _startLocation,
            builder: (context, snapshot) {
              // 위치를 알아내는 동안에는 빈 배경을 보여 줍니다.
              if (snapshot.connectionState != ConnectionState.done) {
                return const ColoredBox(color: BitokColors.grey3);
              }
              final start = snapshot.data;
              return KakaoMap(
                option: KakaoMapOption(
                  position: start == null
                      ? _fallbackPosition
                      : LatLng(start.lat, start.lng),
                  zoomLevel: 16,
                  mapType: MapType.normal,
                ),
                onMapReady: _onMapReady,
                onMapClick: _onMapClick,
                onPoiClick: _onPoiClick,
              );
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                // 터치 영역이 보이는 버튼보다 사방으로 커서, 그만큼 여백을 줄여 위치를 맞춥니다.
                padding: EdgeInsets.fromLTRB(
                  0,
                  0,
                  24 - _CurrentLocationButton.touchExtra,
                  (sheet == null ? _idleButtonBottom(context) : 16) -
                      _CurrentLocationButton.touchExtra,
                ),
                child: _CurrentLocationButton(onTap: _goToMyLocation),
              ),
              if (sheet != null) sheet,
            ],
          ),
        ),
      ],
    );
  }
}

/// 지도 위 마커 하나와 그 스타일입니다.
class _MapMarker {
  _MapMarker(this.poi, this.normalStyle, this.selectedStyle);

  final Poi poi;
  final PoiStyle normalStyle;
  final PoiStyle selectedStyle;
  bool selected = false;
}

/// Figma: Current Location (32 x 32 흰 원 버튼)
/// 손가락으로 누르기 쉽도록 보이는 크기는 그대로 두고 터치 영역만 사방 [touchExtra]씩 넓혔습니다.
class _CurrentLocationButton extends StatelessWidget {
  const _CurrentLocationButton({this.onTap});

  final VoidCallback? onTap;

  static const double _size = 32;

  /// 버튼 둘레로 더 넓힌 터치 영역 (한쪽 기준)
  static const double touchExtra = 16;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: _size + touchExtra * 2,
        height: _size + touchExtra * 2,
        child: Center(
          child: Container(
            width: _size,
            height: _size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: BitokColors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            // TODO: Figma '지도' 아이콘을 BitokIcons 에 추가하면 교체합니다.
            child: const Icon(
              Icons.my_location,
              size: 20,
              color: BitokColors.grey0,
            ),
          ),
        ),
      ),
    );
  }
}