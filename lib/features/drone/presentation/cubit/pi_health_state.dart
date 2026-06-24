import 'package:equatable/equatable.dart';

class PiHealthState extends Equatable {
  final bool isOnline;
  final DateTime? lastSeen;
  final bool motorsRunning;
  final double? battery;
  final double? temperature;

  const PiHealthState({
    this.isOnline = false,
    this.lastSeen,
    this.motorsRunning = false,
    this.battery,
    this.temperature,
  });

  PiHealthState copyWith({
    bool? isOnline,
    DateTime? lastSeen,
    bool? motorsRunning,
    double? battery,
    double? temperature,
  }) {
    return PiHealthState(
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      motorsRunning: motorsRunning ?? this.motorsRunning,
      battery: battery ?? this.battery,
      temperature: temperature ?? this.temperature,
    );
  }

  @override
  List<Object?> get props => [isOnline, lastSeen, motorsRunning, battery, temperature];
}
