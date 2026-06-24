import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/pi_http_client.dart';
import 'mission_state.dart';

class MissionCubit extends Cubit<MissionState> {
  final PiHttpClient _piClient;

  MissionCubit({required this._piClient}) : super(const MissionState());

  Future<void> startMission() async {
    developer.log('[MissionCubit] Starting mission...', name: 'mission');
    emit(state.copyWith(status: MissionStatus.starting, message: null));

    try {
      final ok = await _piClient.startMission();
      if (!ok) {
        developer.log('[MissionCubit] Start mission failed', name: 'mission');
        emit(state.copyWith(
          status: MissionStatus.error,
          message: 'Failed to start mission — check Pi connection',
        ));
        return;
      }
      developer.log('[MissionCubit] Mission started successfully', name: 'mission');
      emit(state.copyWith(
        status: MissionStatus.running,
        message: 'Motors started successfully',
        lastSuccessTime: DateTime.now(),
      ));
    } catch (e) {
      developer.log('[MissionCubit] Start mission error: $e', name: 'mission');
      emit(state.copyWith(
        status: MissionStatus.error,
        message: 'Error starting mission: $e',
      ));
    }
  }

  Future<void> stopMission() async {
    developer.log('[MissionCubit] Stopping mission...', name: 'mission');
    emit(state.copyWith(status: MissionStatus.stopping, message: null));

    try {
      final ok = await _piClient.stopMission();
      if (!ok) {
        developer.log('[MissionCubit] Stop mission failed', name: 'mission');
        emit(state.copyWith(
          status: MissionStatus.error,
          message: 'Failed to stop mission',
        ));
        return;
      }
      developer.log('[MissionCubit] Mission stopped successfully', name: 'mission');
      emit(state.copyWith(
        status: MissionStatus.stopped,
        message: 'Motors stopped successfully',
        lastSuccessTime: DateTime.now(),
      ));
    } catch (e) {
      developer.log('[MissionCubit] Stop mission error: $e', name: 'mission');
      emit(state.copyWith(
        status: MissionStatus.error,
        message: 'Error stopping mission: $e',
      ));
    }
  }

  void setOffline() {
    developer.log('[MissionCubit] Pi marked offline', name: 'mission');
    emit(state.copyWith(status: MissionStatus.piOffline, message: 'Raspberry Pi is offline'));
  }

  void setIdle() {
    developer.log('[MissionCubit] State reset to idle', name: 'mission');
    emit(state.copyWith(status: MissionStatus.idle, clearMessage: true));
  }

  void clearMessage() {
    emit(state.copyWith(clearMessage: true));
  }
}
