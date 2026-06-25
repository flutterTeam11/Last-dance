import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/pi_http_client.dart';
import '../cubit/drone_status_cubit.dart';
import 'pi_health_state.dart';

class PiHealthCubit extends Cubit<PiHealthState> {
  final PiHttpClient _piClient;
  final DroneStatusCubit _droneStatusCubit;
  StreamSubscription<void>? _healthSubscription;
  Timer? _pollTimer;
  int _consecutiveFailures = 0;

  static const _pollInterval = Duration(seconds: 5);
  static const _maxRetries = 3;

  PiHealthCubit({
    required this._piClient,
    required this._droneStatusCubit,
  }) : super(const PiHealthState());

  void startPolling() {
    _pollTimer?.cancel();
    developer.log('[PiHealthCubit] Starting health polling', name: 'pi_health');
    _poll();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final status = await _piClient.getStatus();
      _consecutiveFailures = 0;

      developer.log('[PiHealthCubit] Pi online | motors=${status['motors_running']}',
          name: 'pi_health');

      final motorsRunning = status['motors_running'] == true;
      final motor1Running = status['motor1'] == true;
      final motor2Running = status['motor2'] == true;
      final battery = (status['battery'] as num?)?.toDouble();
      final temperature = (status['temperature'] as num?)?.toDouble();

      emit(state.copyWith(
        isOnline: true,
        lastSeen: DateTime.now(),
        motorsRunning: motorsRunning,
        motor1Running: motor1Running,
        motor2Running: motor2Running,
        battery: battery,
        temperature: temperature,
      ));

      _droneStatusCubit.updateConnectionStatus(true);
    } catch (e) {
      _consecutiveFailures++;
      developer.log('[PiHealthCubit] Poll failed ($_consecutiveFailures/$_maxRetries): $e',
          name: 'pi_health');

      if (_consecutiveFailures >= _maxRetries) {
        developer.log('[PiHealthCubit] Pi marked offline', name: 'pi_health');
        emit(state.copyWith(isOnline: false));
        _droneStatusCubit.updateConnectionStatus(false);
      }
    }
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _healthSubscription?.cancel();
    return super.close();
  }
}
