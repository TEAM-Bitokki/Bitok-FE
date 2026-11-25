import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../core/services/location_service.dart';
import '../models/map_restaurant.dart';
import 'marker_image_factory.dart';

class RestaurantMapView extends StatefulWidget {
  const RestaurantMapView({
    super.key,
    required this.restaurants,
    this.selectedId,
    this.onRestaurantTap,
    this.onMapTap,
    this.onMyLocationTap,
    this.onCenterChanged,
    this.sheet,
  });

  final List<MapRestaurant> restaurants;
  final String? selectedId;
  final ValueChanged<MapRestaurant>? onRestaurantTap;
  final VoidCallback? onMapTap;
  final VoidCallback? onMyLocationTap;

  /// 사용자가 지도를 옮기거나 내 위치로 이동했을 때, 새 화면 중심을 알려줍니다.
  final ValueChanged<({double lat, double lng})>? onCenterChanged;

  final Widget? sheet;

  @override
  State<RestaurantMapView> createState() => _RestaurantMapViewState();
}

class _RestaurantMapViewState extends State<RestaurantMapView> {
  static const _fallbackPosition = LatLng(37.5636, 126.9850);
  static const _poiTapGuard = Duration(milliseconds: 400);

  late final LatLng _initialPosition;

  ({double lat, double lng})? _startLocation;
  bool _startApplied = false;

  Future<Poi>? _myLocationPoiFuture;

  KakaoMapController? _controller;

  final Map<String, MapRestaurant> _poiRestaurants = {};

  final Map<String, _MapMarker> _markers = {};

  int _markerGeneration = 0;

  DateTime _lastPoiTap = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastSelectedMove = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    final cached = LocationService.cached;
    _initialPosition = cached == null
        ? _fallbackPosition
        : LatLng(cached.lat, cached.lng);
    LocationService.current().then((location) {
      if (!mounted) return;
      _startLocation = location;
      _applyStartLocation();
    });
  }

  void _log(String message, Object error) {
    if (kDebugMode) debugPrint('$message: $error');
  }

  double _idleButtonBottom(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).bottom;
    return (inset < 34 ? 34 : inset) + 69;
  }

  Future<void> _addMarkers(
    KakaoMapController controller,
    int generation,
  ) async {
    bool isStale() =>
        !mounted ||
        _controller != controller ||
        generation != _markerGeneration;

    for (final r in widget.restaurants) {
      try {
        final normal = PoiStyle(
          icon: await MarkerImageFactory.create(count: r.checkedMenuCount),
        );
        final selected = PoiStyle(
          icon: await MarkerImageFactory.create(
            count: r.checkedMenuCount,
            selected: true,
          ),
        );
        if (isStale()) return;
        final poi = await controller.labelLayer.addPoi(
          LatLng(r.lat, r.lng),
          style: normal,
        );
        if (isStale()) {
          await poi.remove();
          return;
        }
        _poiRestaurants[poi.id.toString()] = r;
        _markers[r.id] = _MapMarker(poi, normal, selected);
      } catch (e) {
        _log('addPoi failed', e);
      }
    }
    if (isStale()) return;
    await _syncSelection();
  }

  Future<void> _reloadMarkers() async {
    final controller = _controller;
    if (controller == null) return;
    final generation = ++_markerGeneration;
    final old = _markers.values.toList();
    _markers.clear();
    _poiRestaurants.clear();
    for (final marker in old) {
      try {
        await marker.poi.remove();
      } catch (e) {
        _log('removePoi failed', e);
      }
    }
    if (!mounted ||
        _controller != controller ||
        generation != _markerGeneration) {
      return;
    }
    await _addMarkers(controller, generation);
  }

  Future<void> _syncSelection() async {
    for (final entry in _markers.entries.toList()) {
      final marker = entry.value;
      final shouldSelect = entry.key == widget.selectedId;
      if (marker.selected == shouldSelect) continue;
      marker.selected = shouldSelect;
      try {
        await marker.poi.changeStyles(
          shouldSelect ? marker.selectedStyle : marker.normalStyle,
        );
      } catch (e) {
        _log('changeStyles failed', e);
      }
    }
  }

  void _moveToSelected() {
    final id = widget.selectedId;
    if (id == null) return;
    for (final r in widget.restaurants) {
      if (r.id == id) {
        _lastSelectedMove = DateTime.now();
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
    _moveToSelected();
    _addMarkers(controller, ++_markerGeneration);
    _showMyLocation(LocationService.cached);
    _applyStartLocation();
  }

  void _applyStartLocation() {
    final location = _startLocation;
    if (location == null || _controller == null || _startApplied) return;
    _startApplied = true;
    if (widget.selectedId == null) _moveTo(location);
    _showMyLocation(location);
  }

  Future<void> _showMyLocation(({double lat, double lng})? location) async {
    final controller = _controller;
    if (location == null || controller == null) return;
    final position = LatLng(location.lat, location.lng);
    try {
      final existing = _myLocationPoiFuture;
      if (existing != null) {
        final poi = await existing;
        await poi.move(position);
      } else {
        final future = controller.labelLayer.addPoi(
          position,
          style: PoiStyle(icon: MarkerImageFactory.myLocation()),
        );
        _myLocationPoiFuture = future;
        await future;
      }
    } catch (e) {
      _myLocationPoiFuture = null;
      _log('showMyLocation failed', e);
    }
  }

  bool _locating = false;

  void _moveTo(({double lat, double lng}) location) {
    _controller?.moveCamera(
      CameraUpdate.newCenterPosition(LatLng(location.lat, location.lng)),
      animation: const CameraAnimation(300),
    );
    widget.onCenterChanged?.call(location);
  }

  Future<void> _goToMyLocation() async {
    widget.onMyLocationTap?.call();

    final cached = LocationService.cached;
    if (cached != null) {
      _moveTo(cached);
      _showMyLocation(cached);
    }

    if (_locating) return;
    _locating = true;
    try {
      final result = await LocationService.locate(forceRefresh: true);
      if (!mounted) return;
      final location = result.location;
      if (location != null) {
        _moveTo(location);
        _showMyLocation(location);
      }
      final issue = result.issue;
      if (issue != null) _showLocationIssue(issue);
    } finally {
      _locating = false;
    }
  }

  void _showLocationIssue(LocationIssue issue) {
    final String message;
    String? actionLabel;
    VoidCallback? onAction;

    switch (issue) {
      case LocationIssue.serviceDisabled:
        message = 'Location services are turned off.';
        actionLabel = 'Turn on';
        onAction = LocationService.openLocationSettings;
      case LocationIssue.denied:
        message = 'Allow location access to see where you are.';
        actionLabel = 'Retry';
        onAction = _goToMyLocation;
      case LocationIssue.deniedForever:
        message = 'Location access is turned off for this app.';
        actionLabel = 'Settings';
        onAction = LocationService.openAppSettings;
      case LocationIssue.unavailable:
        message = 'Could not find your location.';
    }

    final messenger = ScaffoldMessenger.of(context);
    final action = onAction;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
          content: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: BitokTextStyles.body1.copyWith(
                    color: BitokColors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              if (actionLabel != null && action != null)
                TextButton(
                  onPressed: () {
                    messenger.hideCurrentSnackBar();
                    action();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: BitokColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    textStyle: BitokTextStyles.body1.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(actionLabel),
                ),
            ],
          ),
        ),
      );
  }

  void _onPoiClick(LabelController labelController, Poi poi) {
    final restaurant = _poiRestaurants[poi.id.toString()];
    if (restaurant == null) return;
    _lastPoiTap = DateTime.now();
    widget.onRestaurantTap?.call(restaurant);
  }

  void _onMapClick(KPoint point, LatLng latLng) {
    if (DateTime.now().difference(_lastPoiTap) < _poiTapGuard) return;
    widget.onMapTap?.call();
  }

  void _onCameraMoveEnd(CameraPosition position, GestureType gesture) {
    if (DateTime.now().difference(_lastSelectedMove) <
        const Duration(milliseconds: 800)) {
      return;
    }
    widget.onCenterChanged?.call((
      lat: position.position.latitude,
      lng: position.position.longitude,
    ));
  }

  @override
  void didUpdateWidget(covariant RestaurantMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.restaurants, oldWidget.restaurants)) {
      _reloadMarkers();
    }
    if (widget.selectedId != oldWidget.selectedId) {
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
          child: KakaoMap(
            option: KakaoMapOption(
              position: _initialPosition,
              zoomLevel: 16,
              mapType: MapType.normal,
            ),
            onMapReady: _onMapReady,
            onMapClick: _onMapClick,
            onPoiClick: _onPoiClick,
            onCameraMoveEnd: _onCameraMoveEnd,
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

class _MapMarker {
  _MapMarker(this.poi, this.normalStyle, this.selectedStyle);

  final Poi poi;
  final PoiStyle normalStyle;
  final PoiStyle selectedStyle;
  bool selected = false;
}

class _CurrentLocationButton extends StatelessWidget {
  const _CurrentLocationButton({this.onTap});

  final VoidCallback? onTap;

  static const double _size = 32;
  static const String _iconAsset = 'assets/icons/ic_to_my_location.svg';
  static const double touchExtra = 12;

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
            child: SvgPicture.asset(_iconAsset, width: 24, height: 24),
          ),
        ),
      ),
    );
  }
}
