import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/drone_status_cubit.dart';
import '../cubit/drone_status_state.dart';

class MapScreenHeader extends StatelessWidget {
  const MapScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandCyan.withValues(alpha: 0.3),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'R',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi Mr. Phoenix!',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Are you ready for a new rescue mission today?',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<DroneStatusCubit, DroneStatusState>(
            buildWhen: (prev, curr) {
              if (prev is DroneStatusLoaded && curr is DroneStatusLoaded) {
                return prev.status.isConnected != curr.status.isConnected;
              }
              return true;
            },
            builder: (context, state) {
              final isConnected =
                  state is DroneStatusLoaded && state.status.isConnected;
              return Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected
                      ? AppTheme.connectedGreen
                      : AppTheme.disconnectedRed,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isConnected
                                  ? AppTheme.connectedGreen
                                  : AppTheme.disconnectedRed)
                              .withValues(alpha: 0.4),
                      blurRadius: 6.r,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
