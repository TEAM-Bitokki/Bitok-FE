import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import '../../../../core/design_system/bitok_colors.dart';
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
    this.sheet,
  });

  final List<MapRestaurant> restaurants;
  final String? selectedId;
  final ValueChanged<MapRestaurant>? onRestaurantTap;
  final VoidCallback? onMapTap;
  final VoidCallback? onMyLocationTap;


  final Widget? sheet;

  @override
  State<RestaurantMapView> createState() => _RestaurantMapViewState();
}

class _RestaurantMapViewState extends State<RestaurantMapView> {
  static const _fallbackPosition = LatLng(37.5636, 126.9850);
  late final Future<({double lat, double lng})?> _startLocation =
  LocationService.current();

  Poi? _myLocationPoi;

  KakaoMapController? _controller;

  final Map<String, MapRestaurant> _poiRestaurants = {};

  final Map<String, _MapMarker> _markers = {};


  DateTime _lastPoiTap = DateTime.fromMillisecondsSinceEpoch(0);

  double _idleButtonBottom(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).bottom;
    return (inset < 34 ? 34 : inset) + 69;
  }

  Future<void> _addMarkers(KakaoMapController controller) async {
    for (final r in widget.restaurants) {
      try {
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
      }
    }
    await _syncSelection();
  }

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
    _moveToSelected();
    _addMarkers(controller);
    _showMyLocation(LocationService.cached);
  }
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
    }
  }

  bool _locating = false;

  void _moveTo(({double lat, double lng}) location) {
    _controller?.moveCamera(
      CameraUpdate.newCenterPosition(LatLng(location.lat, location.lng)),
      animation: const CameraAnimation(300),
    );
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
