import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_theme.dart';

class MapMarkers extends StatelessWidget {
  final LatLng? dronePosition;
  final List<LatLng> path;
  final LatLng? userLocation;

  const MapMarkers({
    super.key,
    this.dronePosition,
    required this.path,
    this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        if (dronePosition != null) _droneMarker(dronePosition!),
        if (userLocation != null) _userMarker(userLocation!),
      ],
    );
  }

  Marker _droneMarker(LatLng position) {
    return Marker(
      point: position,
      width: 50.w,
      height: 50.w,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.brandCyan.withValues(alpha: 0.4),
              blurRadius: 12.r,
              spreadRadius: 2.r,
            ),
          ],
        ),
        child: Icon(
          Icons.location_on,
          size: 40.w,
          color: AppTheme.disconnectedRed,
        ),
      ),
    );
  }

  Marker _userMarker(LatLng location) {
    return Marker(
      point: location,
      width: 44.w,
      height: 44.w,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.withValues(alpha: 0.2),
          border: Border.all(color: Colors.white, width: 2.w),
        ),
        child: Center(
          child: Container(
            width: 14.w,
            height: 14.w,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
