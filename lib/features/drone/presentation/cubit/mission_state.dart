import 'package:equatable/equatable.dart';

enum MissionStatus {
  idle,
  connecting,
  starting,
  running,
  stopping,
  stopped,
  error,
  piOffline,
}

class MissionState extends Equatable {
  final MissionStatus status;
  final String? message;
  final DateTime? lastSuccessTime;

  const MissionState({
    this.status = MissionStatus.idle,
    this.message,
    this.lastSuccessTime,
  });

  MissionState copyWith({
    MissionStatus? status,
    String? message,
    DateTime? lastSuccessTime,
    bool clearMessage = false,
  }) {
    return MissionState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      lastSuccessTime: lastSuccessTime ?? this.lastSuccessTime,
    );
  }

  bool get isBusy => status == MissionStatus.starting
      || status == MissionStatus.stopping
      || status == MissionStatus.connecting;

  bool get isRunning => status == MissionStatus.running;

  @override
  List<Object?> get props => [status, message, lastSuccessTime];
}
