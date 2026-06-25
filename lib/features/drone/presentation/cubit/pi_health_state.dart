import 'package:equatable/equatable.dart';

class PiHealthState extends Equatable {
  final bool isOnline;
  final DateTime? lastSeen;
  final bool motorsRunning;
  final bool motor1Running;
  final bool motor2Running;
  final double? battery;
  final double? temperature;

  const PiHealthState({
    this.isOnline = false,
    this.lastSeen,
    this.motorsRunning = false,
    this.motor1Running = false,
    this.motor2Running = false,
    this.battery,
    this.temperature,
  });

  PiHealthState copyWith({
    bool? isOnline,
    DateTime? lastSeen,
    bool? motorsRunning,
    bool? motor1Running,
    bool? motor2Running,
    double? battery,
    double? temperature,
  }) {
    return PiHealthState(
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      motorsRunning: motorsRunning ?? this.motorsRunning,
      motor1Running: motor1Running ?? this.motor1Running,
      motor2Running: motor2Running ?? this.motor2Running,
      battery: battery ?? this.battery,
      temperature: temperature ?? this.temperature,
    );
  }

  @override
  List<Object?> get props => [
    isOnline, lastSeen, motorsRunning, motor1Running, motor2Running,
    battery, temperature,
  ];
}
