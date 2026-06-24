import 'package:equatable/equatable.dart';

class DroneStatus extends Equatable {
  final int battery;
  final int humanCount;
  final double height;
  final double speed;
  final bool isConnected;
  final double temperature;

  const DroneStatus({
    required this.battery,
    required this.humanCount,
    required this.height,
    required this.speed,
    required this.isConnected,
    this.temperature = 0,
  });

  const DroneStatus.initial()
    : battery = 0,
      humanCount = 0,
      height = 0,
      speed = 0,
      isConnected = false,
      temperature = 0;

  DroneStatus copyWith({
    int? battery,
    int? humanCount,
    double? height,
    double? speed,
    bool? isConnected,
    double? temperature,
  }) {
    return DroneStatus(
      battery: battery ?? this.battery,
      humanCount: humanCount ?? this.humanCount,
      height: height ?? this.height,
      speed: speed ?? this.speed,
      isConnected: isConnected ?? this.isConnected,
      temperature: temperature ?? this.temperature,
    );
  }

  @override
  List<Object?> get props =>
      [battery, humanCount, height, speed, isConnected, temperature];
}
