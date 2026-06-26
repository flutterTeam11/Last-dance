import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

Future<bool> _ensureLocationReady({void Function(String)? onError}) async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    onError?.call('Location services are disabled.');
    return false;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied) {
    onError?.call('Location permissions are denied.');
    return false;
  }

  if (permission == LocationPermission.deniedForever) {
    onError?.call('Location permissions are permanently denied.');
    return false;
  }

  return true;
}

Future<LatLng?> getCurrentLocation({void Function(String)? onError}) async {
  try {
    if (!await _ensureLocationReady(onError: onError)) return null;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return LatLng(position.latitude, position.longitude);
  } catch (e) {
    onError?.call('Error getting current location: $e');
    return null;
  }
}

Future<Stream<LatLng>?> watchCurrentLocation({
  void Function(String)? onError,
}) async {
  try {
    if (!await _ensureLocationReady(onError: onError)) return null;

    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).map((position) => LatLng(position.latitude, position.longitude));
  } catch (e) {
    onError?.call('Error watching current location: $e');
    return null;
  }
}

void logError(String msg) => log(msg);
