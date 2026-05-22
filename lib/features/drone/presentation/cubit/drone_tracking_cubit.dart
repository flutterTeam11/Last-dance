import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/drone_location.dart';
import '../../domain/drone_repository.dart';
import 'drone_tracking_state.dart';

class DroneTrackingCubit extends Cubit<DroneTrackingState> {
  final DroneRepository _repository;
  StreamSubscription<DroneLocation>? _locationSubscription;
  final List<DroneLocation> _pathHistory = [];
  Timer? _disconnectTimer;
  final _centerOnUserController = StreamController<void>.broadcast();

  Stream<void> get centerOnUserStream => _centerOnUserController.stream;

  DroneTrackingCubit({required this._repository})
    : super(const DroneTrackingInitial());

  void triggerCenterOnUser() {
    _centerOnUserController.add(null);
  }

  void startTracking() {
    emit(const DroneTrackingLoading());

    _locationSubscription?.cancel();
    _locationSubscription = _repository.watchDroneLocation().listen(
      (location) {
        _resetDisconnectTimer();
        _pathHistory.add(location);

        emit(
          DroneTrackingActive(
            location: location,
            pathHistory: List.unmodifiable(_pathHistory),
          ),
        );
      },
      onError: (_) {
        final currentState = state;
        emit(
          DroneTrackingDisconnected(
            lastKnownLocation: currentState is DroneTrackingActive
                ? currentState.location
                : null,
          ),
        );
      },
    );
  }

  void _resetDisconnectTimer() {
    _disconnectTimer?.cancel();
    _disconnectTimer = Timer(const Duration(seconds: 10), () {
      final currentState = state;
      if (currentState is DroneTrackingActive) {
        emit(
          DroneTrackingDisconnected(lastKnownLocation: currentState.location),
        );
      }
    });
  }

  void clearPath() {
    _pathHistory.clear();
    final currentState = state;
    if (currentState is DroneTrackingActive) {
      emit(
        DroneTrackingActive(
          location: currentState.location,
          pathHistory: const [],
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _disconnectTimer?.cancel();
    _centerOnUserController.close();
    return super.close();
  }
}
