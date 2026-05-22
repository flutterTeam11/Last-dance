import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/drone_status.dart';
import '../cubit/drone_status_cubit.dart';
import '../cubit/drone_status_state.dart';
import 'drone_stat_item.dart';

class DroneMapStatusBar extends StatelessWidget {
  const DroneMapStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: BlocBuilder<DroneStatusCubit, DroneStatusState>(
        buildWhen: (prev, curr) {
          if (prev is DroneStatusLoaded && curr is DroneStatusLoaded) {
            return prev.status != curr.status;
          }
          return true;
        },
        builder: (context, state) {
          final status = state is DroneStatusLoaded
              ? state.status
              : const DroneStatus.initial();
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
                  value: '${status.battery}%',
                  label: 'BATTERY',
                  textColor: AppTheme.textPrimary,
                  labelColor: AppTheme.textSecondary,
                ),
                DroneStatItem(
                  value: '${status.humanCount}',
                  label: 'TEMP',
                  textColor: AppTheme.textPrimary,
                  labelColor: AppTheme.textSecondary,
                ),
                DroneStatItem(
                  value: '${status.battery}%',
                  label: 'SIGNAL',
                  textColor: AppTheme.textPrimary,
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
