import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graduatio_project/core/helper/show_snak_bar.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/service_locator.dart';
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
  LatLng? _userLocation;
  StreamSubscription<void>? _centerOnUserSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for center-on-user events triggered from the Home Screen's mini-map
    _centerOnUserSubscription = getIt<DroneTrackingCubit>().centerOnUserStream
        .listen((_) {
          _centerAndZoomOnUser();
        });
  }

  @override
  void dispose() {
    _centerOnUserSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _centerAndZoomOnUser() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          log('Location services are disabled.');
          showSnakBar(
            context,
            "Location services are disabled.",
            isError: true,
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            log('Location permissions are denied.');
            showSnakBar(
              context,
              "Location permissions are denied.",
              isError: true,
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          log(
            'Location permissions are permanently denied. Please enable them in settings.',
          );
          showSnakBar(
            context,
            "Location permissions are permanently denied. Please enable them in settings.",
            isError: true,
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });

        if (_mapReady) {
          _mapController.move(_userLocation!, 16.5);
        }
      }
    } catch (e) {
      if (mounted) {
        log('Error getting current location: $e');
        showSnakBar(
          context,
          "Error getting current location: $e",
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BlocConsumer<DroneTrackingCubit, DroneTrackingState>(
          listener: (context, state) {
            // Center on drone when active tracking coordinates change
            if (state is DroneTrackingActive &&
                _mapReady &&
                _userLocation == null) {
              _mapController.move(
                LatLng(state.location.lat, state.location.lng),
                15,
              );
            }
          },
          builder: (context, state) {
            if (state is DroneTrackingLoading ||
                state is DroneTrackingInitial) {
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

            return Stack(
              children: [
                FlutterMap(
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
                            strokeWidth: 3.5,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        // Drone Telemetry Marker
                        Marker(
                          point: center,
                          width: 50.w,
                          height: 50.w,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.brandCyan.withValues(
                                    alpha: 0.4,
                                  ),
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
                        // User Current GPS Marker
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 44.w,
                            height: 44.w,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.w,
                                ),
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
                          ),
                      ],
                    ),
                  ],
                ),
                // "My Location" Quick Action overlay button on the map
                Positioned(
                  bottom: 16.h,
                  right: 16.w,
                  child: FloatingActionButton.small(
                    heroTag: 'my_location_btn',
                    onPressed: _centerAndZoomOnUser,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.my_location, size: 20.w),
                  ),
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
