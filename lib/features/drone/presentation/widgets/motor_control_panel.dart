import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/pi_http_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/pi_health_cubit.dart';
import '../cubit/pi_health_state.dart';

class MotorControlPanel extends StatelessWidget {
  const MotorControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PiHealthCubit, PiHealthState>(
      builder: (context, state) {
        if (!state.isOnline) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              children: [
                _buildMotorRow(
                  context,
                  label: 'Motor 1',
                  isRunning: state.motor1Running,
                  piOnline: state.isOnline,
                  onStart: () => _startMotor(context, 1),
                  onStop: () => _stopMotor(context, 1),
                ),
                Divider(height: 1, color: AppTheme.cardBorder),
                _buildMotorRow(
                  context,
                  label: 'Motor 2',
                  isRunning: state.motor2Running,
                  piOnline: state.isOnline,
                  onStart: () => _startMotor(context, 2),
                  onStop: () => _stopMotor(context, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMotorRow(
    BuildContext context, {
    required String label,
    required bool isRunning,
    required bool piOnline,
    required VoidCallback onStart,
    required VoidCallback onStop,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRunning
                  ? AppTheme.connectedGreen
                  : AppTheme.textSecondary,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          if (isRunning)
            Padding(
              padding: EdgeInsets.only(left: 6.w),
              child: Text(
                'RUNNING',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.connectedGreen,
                ),
              ),
            ),
          const Spacer(),
          SizedBox(
            height: 32.h,
            child: ElevatedButton(
              onPressed: (!piOnline || isRunning) ? null : onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandCyan,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white60,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Start',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            height: 32.h,
            child: ElevatedButton(
              onPressed: (!piOnline || !isRunning) ? null : onStop,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white60,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Stop',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startMotor(BuildContext context, int motorId) async {
    try {
      final client = getIt<PiHttpClient>();
      final ok = motorId == 1
          ? await client.startMotor1()
          : await client.startMotor2();
      if (ok && context.mounted) {
        showSnakBar(context, 'Motor $motorId started');
      } else if (context.mounted) {
        showSnakBar(context, 'Failed to start motor $motorId', isError: true);
      }
    } catch (e) {
      if (context.mounted) {
        showSnakBar(context, 'Error starting motor $motorId', isError: true);
      }
    }
  }

  Future<void> _stopMotor(BuildContext context, int motorId) async {
    try {
      final client = getIt<PiHttpClient>();
      final ok = motorId == 1
          ? await client.stopMotor1()
          : await client.stopMotor2();
      if (ok && context.mounted) {
        showSnakBar(context, 'Motor $motorId stopped');
      } else if (context.mounted) {
        showSnakBar(context, 'Failed to stop motor $motorId', isError: true);
      }
    } catch (e) {
      if (context.mounted) {
        showSnakBar(context, 'Error stopping motor $motorId', isError: true);
      }
    }
  }
}
