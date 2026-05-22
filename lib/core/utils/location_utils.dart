import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

Future<LatLng?> getCurrentLocation({void Function(String)? onError}) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      onError?.call('Location services are disabled.');
      return null;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      if (result == LocationPermission.denied) {
        onError?.call('Location permissions are denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      onError?.call('Location permissions are permanently denied.');
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return LatLng(position.latitude, position.longitude);
  } catch (e) {
    onError?.call('Error getting current location: $e');
    return null;
  }
}

void logError(String msg) => log(msg);
