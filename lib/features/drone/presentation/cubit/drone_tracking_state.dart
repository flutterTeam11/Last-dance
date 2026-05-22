import 'package:equatable/equatable.dart';

import '../../domain/drone_location.dart';

abstract class DroneTrackingState extends Equatable {
  const DroneTrackingState();

  @override
  List<Object?> get props => [];
}

class DroneTrackingInitial extends DroneTrackingState {
  const DroneTrackingInitial();
}

class DroneTrackingLoading extends DroneTrackingState {
  const DroneTrackingLoading();
}

class DroneTrackingActive extends DroneTrackingState {
  final DroneLocation location;
  final List<DroneLocation> pathHistory;

  const DroneTrackingActive({
    required this.location,
    this.pathHistory = const [],
  });

  @override
  List<Object?> get props => [location, pathHistory];
}

class DroneTrackingDisconnected extends DroneTrackingState {
  final DroneLocation? lastKnownLocation;

  const DroneTrackingDisconnected({this.lastKnownLocation});

  @override
  List<Object?> get props => [lastKnownLocation];
}
