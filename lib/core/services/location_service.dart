import 'package:geolocator/geolocator.dart';


class LocationService {
  const LocationService._();

  static ({double lat, double lng})? _cached;

  static ({double lat, double lng})? get cached => _cached;

  static Future<({double lat, double lng})?> current({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cached != null) return _cached;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) return _cached;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _cached;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }
      if (position == null) return _cached;

      _cached = (lat: position.latitude, lng: position.longitude);
      return _cached;
    } catch (_) {
      return _cached;
    }
  }
}