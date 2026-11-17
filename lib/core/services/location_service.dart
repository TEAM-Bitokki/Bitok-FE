import 'package:geolocator/geolocator.dart';

enum LocationIssue { serviceDisabled, denied, deniedForever, unavailable }

class LocationResult {
  const LocationResult({this.location, this.issue});

  final ({double lat, double lng})? location;
  final LocationIssue? issue;
}

class LocationService {
  const LocationService._();

  static ({double lat, double lng})? _cached;

  static ({double lat, double lng})? get cached => _cached;

  static Future<({double lat, double lng})?> current({
    bool forceRefresh = false,
  }) async {
    final result = await locate(forceRefresh: forceRefresh);
    return result.location;
  }

  static Future<LocationResult> locate({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) {
      return LocationResult(location: _cached);
    }

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationResult(
          location: _cached,
          issue: LocationIssue.serviceDisabled,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          location: _cached,
          issue: LocationIssue.deniedForever,
        );
      }
      if (permission == LocationPermission.denied) {
        return LocationResult(location: _cached, issue: LocationIssue.denied);
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
      if (position == null) return _unavailable();

      _cached = (lat: position.latitude, lng: position.longitude);
      return LocationResult(location: _cached);
    } catch (_) {
      return _unavailable();
    }
  }

  static LocationResult _unavailable() => LocationResult(
    location: _cached,
    issue: _cached == null ? LocationIssue.unavailable : null,
  );

  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();

  static Future<bool> openAppSettings() => Geolocator.openAppSettings();
}