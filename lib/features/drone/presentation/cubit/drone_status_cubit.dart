import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/drone_report.dart';
import '../../domain/drone_repository.dart';
import '../../domain/drone_status.dart';
import 'drone_status_state.dart';

class DroneStatusCubit extends Cubit<DroneStatusState> {
  final DroneRepository _repository;
  StreamSubscription<DroneStatus>? _statusSubscription;
  StreamSubscription<List<DroneReport>>? _reportsSubscription;

  DroneStatusCubit({required this._repository})
      : super(const DroneStatusInitial());

  void startListening() {
    _statusSubscription?.cancel();
    _statusSubscription = _repository.watchDroneStatus().listen(
      (status) {
        final currentState = state;
        if (currentState is DroneStatusLoaded) {
          emit(currentState.copyWith(status: status));
        } else {
          emit(DroneStatusLoaded(status: status));
        }
      },
      onError: (_) {},
    );

    _reportsSubscription?.cancel();
    _reportsSubscription = _repository.watchDroneReports().listen(
      (reports) {
        final currentState = state;
        if (currentState is DroneStatusLoaded) {
          emit(currentState.copyWith(reports: reports));
        } else {
          emit(DroneStatusLoaded(
            status: const DroneStatus.initial(),
            reports: reports,
          ));
        }
      },
      onError: (_) {},
    );
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    _reportsSubscription?.cancel();
    return super.close();
  }
}
