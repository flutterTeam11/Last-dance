import 'package:equatable/equatable.dart';

class DroneLocation extends Equatable {
  final double lat;
  final double lng;
  final DateTime? timestamp;

  const DroneLocation({
    required this.lat,
    required this.lng,
    this.timestamp,
  });

  @override
  List<Object?> get props => [lat, lng, timestamp];
}
