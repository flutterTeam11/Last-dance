import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_theme.dart';
import 'map_markers.dart';

class DroneMapContent extends StatelessWidget {
  final LatLng center;
  final LatLng? dronePosition;
  final List<LatLng> path;
  final LatLng? userLocation;
  final MapController mapController;
  final VoidCallback onMapReady;
  final VoidCallback onCenterOnUser;

  const DroneMapContent({
    super.key,
    required this.center,
    this.dronePosition,
    required this.path,
    this.userLocation,
    required this.mapController,
    required this.onMapReady,
    required this.onCenterOnUser,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15,
            onMapReady: onMapReady,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.resqer.app',
              errorImage: null,
            ),
            if (path.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: path,
                    color: AppTheme.brandBlue.withValues(alpha: 0.6),
                    strokeWidth: 3.5,
                  ),
                ],
              ),
            MapMarkers(
              dronePosition: dronePosition,
              path: path,
              userLocation: userLocation,
            ),
          ],
        ),
        Positioned(
          bottom: 16.h,
          right: 16.w,
          child: FloatingActionButton.small(
            heroTag: 'my_location_btn',
            onPressed: onCenterOnUser,
            backgroundColor: Colors.white,
            child: Icon(Icons.my_location, size: 20.w),
          ),
        ),
      ],
    );
  }
}
