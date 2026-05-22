import 'package:equatable/equatable.dart';

class DroneStatus extends Equatable {
  final int battery;
  final int humanCount;
  final double height;
  final double speed;
  final bool isConnected;

  const DroneStatus({
    required this.battery,
    required this.humanCount,
    required this.height,
    required this.speed,
    required this.isConnected,
  });

  const DroneStatus.initial()
      : battery = 0,
        humanCount = 0,
        height = 0,
        speed = 0,
        isConnected = false;

  @override
  List<Object?> get props => [battery, humanCount, height, speed, isConnected];
}
