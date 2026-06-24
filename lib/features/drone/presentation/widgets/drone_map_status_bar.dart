import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/pi_health_cubit.dart';
import '../cubit/pi_health_state.dart';
import 'drone_stat_item.dart';

class DroneMapStatusBar extends StatelessWidget {
  const DroneMapStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: BlocBuilder<PiHealthCubit, PiHealthState>(
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DroneStatItem(
                  value: state.battery != null
                      ? '${state.battery!.toInt()}%'
                      : '--%',
                  label: 'BATTERY',
                  textColor: AppTheme.textPrimary,
                  labelColor: AppTheme.textSecondary,
                ),
                DroneStatItem(
                  value: state.temperature != null
                      ? '${state.temperature!.toStringAsFixed(1)}°C'
                      : '--°C',
                  label: 'TEMP',
                  textColor: AppTheme.textPrimary,
                  labelColor: AppTheme.textSecondary,
                ),
                DroneStatItem(
                  value: state.motorsRunning ? 'RUNNING' : 'IDLE',
                  label: 'MOTORS',
                  textColor: state.motorsRunning
                      ? AppTheme.connectedGreen
                      : AppTheme.textPrimary,
                  labelColor: AppTheme.textSecondary,
                ),
                DroneStatItem(
                  value: state.isOnline ? 'ONLINE' : 'OFFLINE',
                  label: 'PI',
                  textColor: state.isOnline
                      ? AppTheme.connectedGreen
                      : AppTheme.disconnectedRed,
                  labelColor: AppTheme.textSecondary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
