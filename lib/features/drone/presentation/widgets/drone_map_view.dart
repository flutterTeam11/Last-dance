import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/drone_tracking_cubit.dart';
import '../cubit/drone_tracking_state.dart';

class DroneMapView extends StatefulWidget {
  final double height;

  const DroneMapView({super.key, this.height = 300});

  @override
  State<DroneMapView> createState() => _DroneMapViewState();
}

class _DroneMapViewState extends State<DroneMapView> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BlocConsumer<DroneTrackingCubit, DroneTrackingState>(
          listener: (context, state) {
            if (state is DroneTrackingActive && _mapReady) {
              _mapController.move(
                LatLng(state.location.lat, state.location.lng),
                16,
              );
            }
          },
          builder: (context, state) {
            if (state is DroneTrackingLoading || state is DroneTrackingInitial) {
              return _buildPlaceholder();
            }

            LatLng center;
            List<LatLng> path = [];

            if (state is DroneTrackingActive) {
              center = LatLng(state.location.lat, state.location.lng);
              path = state.pathHistory
                  .map((l) => LatLng(l.lat, l.lng))
                  .toList();
            } else if (state is DroneTrackingDisconnected &&
                state.lastKnownLocation != null) {
              center = LatLng(
                state.lastKnownLocation!.lat,
                state.lastKnownLocation!.lng,
              );
            } else {
              return _buildPlaceholder();
            }

            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15,
                onMapReady: () {
                  _mapReady = true;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.resqer.app',
                  errorImage: null,
                ),
                if (path.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: path,
                        color: AppTheme.brandBlue.withValues(alpha: 0.6),
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 50.w,
                      height: 50.w,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.brandCyan.withValues(alpha: 0.4),
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
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.reportCardBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/map/map.svg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
