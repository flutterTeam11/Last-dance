import 'package:equatable/equatable.dart';

import '../../domain/drone_report.dart';
import '../../domain/drone_status.dart';

abstract class DroneStatusState extends Equatable {
  const DroneStatusState();

  @override
  List<Object?> get props => [];
}

class DroneStatusInitial extends DroneStatusState {
  const DroneStatusInitial();
}

class DroneStatusLoaded extends DroneStatusState {
  final DroneStatus status;
  final List<DroneReport> reports;

  const DroneStatusLoaded({
    required this.status,
    this.reports = const [],
  });

  DroneStatusLoaded copyWith({
    DroneStatus? status,
    List<DroneReport>? reports,
  }) {
    return DroneStatusLoaded(
      status: status ?? this.status,
      reports: reports ?? this.reports,
    );
  }

  @override
  List<Object?> get props => [status, reports];
}
