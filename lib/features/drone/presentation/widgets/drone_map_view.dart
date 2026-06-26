import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/utils/location_utils.dart';
import '../cubit/drone_tracking_cubit.dart';
import '../cubit/drone_tracking_state.dart';
import 'drone_map_content.dart';
import 'map_placeholder.dart';

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
  StreamSubscription<LatLng>? _userLocationSubscription;

  @override
  void initState() {
    super.initState();
    _centerOnUserSubscription = getIt<DroneTrackingCubit>().centerOnUserStream
        .listen((_) {
          _centerAndZoomOnUser();
        });
    _startUserLocationTracking();
  }

  @override
  void dispose() {
    _centerOnUserSubscription?.cancel();
    _userLocationSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _startUserLocationTracking() async {
    final initialLocation = await getCurrentLocation(
      onError: (msg) {
        if (mounted) showSnakBar(context, msg, isError: true);
      },
    );
    if (!mounted) return;

    if (initialLocation != null) {
      setState(() => _userLocation = initialLocation);
      if (_mapReady) _mapController.move(initialLocation, 16.5);
    }

    final stream = await watchCurrentLocation(
      onError: (msg) {
        if (mounted) showSnakBar(context, msg, isError: true);
      },
    );
    if (stream == null || !mounted) return;

    _userLocationSubscription?.cancel();
    _userLocationSubscription = stream.listen(
      (location) {
        if (!mounted) return;
        setState(() => _userLocation = location);
      },
      onError: (Object error) {
        if (mounted) {
          showSnakBar(
            context,
            'Error watching current location: $error',
            isError: true,
          );
        }
      },
    );
  }

  Future<void> _centerAndZoomOnUser() async {
    final loc = await getCurrentLocation(
      onError: (msg) {
        if (mounted) showSnakBar(context, msg, isError: true);
      },
    );
    if (loc == null || !mounted) return;
    setState(() => _userLocation = loc);
    if (_mapReady) _mapController.move(loc, 16.5);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BlocConsumer<DroneTrackingCubit, DroneTrackingState>(
          listener: (context, state) {
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
              if (_userLocation != null) {
                return DroneMapContent(
                  center: _userLocation!,
                  path: const [],
                  userLocation: _userLocation,
                  mapController: _mapController,
                  onMapReady: () {
                    _mapReady = true;
                    _mapController.move(_userLocation!, 16.5);
                  },
                  onCenterOnUser: _centerAndZoomOnUser,
                );
              }
              return const MapPlaceholder();
            }

            if (state is DroneTrackingActive) {
              final dronePosition = LatLng(
                state.location.lat,
                state.location.lng,
              );
              return DroneMapContent(
                center: dronePosition,
                dronePosition: dronePosition,
                path: state.pathHistory
                    .map((l) => LatLng(l.lat, l.lng))
                    .toList(),
                userLocation: _userLocation,
                mapController: _mapController,
                onMapReady: () => _mapReady = true,
                onCenterOnUser: _centerAndZoomOnUser,
              );
            }

            if (state is DroneTrackingDisconnected &&
                state.lastKnownLocation != null) {
              final dronePosition = LatLng(
                state.lastKnownLocation!.lat,
                state.lastKnownLocation!.lng,
              );
              return DroneMapContent(
                center: dronePosition,
                dronePosition: dronePosition,
                path: const [],
                userLocation: _userLocation,
                mapController: _mapController,
                onMapReady: () => _mapReady = true,
                onCenterOnUser: _centerAndZoomOnUser,
              );
            }

            if (_userLocation != null) {
              return DroneMapContent(
                center: _userLocation!,
                path: const [],
                userLocation: _userLocation,
                mapController: _mapController,
                onMapReady: () {
                  _mapReady = true;
                  _mapController.move(_userLocation!, 16.5);
                },
                onCenterOnUser: _centerAndZoomOnUser,
              );
            }

            return const MapPlaceholder();
          },
        ),
      ),
    );
  }
}
