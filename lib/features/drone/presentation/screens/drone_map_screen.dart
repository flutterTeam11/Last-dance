import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/drone_status.dart';
import '../cubit/drone_status_cubit.dart';
import '../cubit/drone_status_state.dart';
import '../cubit/drone_tracking_cubit.dart';
import '../widgets/drone_map_view.dart';

class DroneMapScreen extends StatefulWidget {
  const DroneMapScreen({super.key});

  @override
  State<DroneMapScreen> createState() => _DroneMapScreenState();
}

class _DroneMapScreenState extends State<DroneMapScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DroneTrackingCubit>().startTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              _buildHeader(),
              SizedBox(height: 16.h),
              _buildMapSection(),
              SizedBox(height: 16.h),
              _buildDroneStatusBar(),
              SizedBox(height: 16.h),
              _buildMissionStatus(),
              SizedBox(height: 16.h),
              _buildStartMissionButton(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  'Hi Mr. Shawki!',
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
                      color: (isConnected
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

  Widget _buildMapSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: const DroneMapView(height: 280),
    );
  }

  Widget _buildDroneStatusBar() {
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
                _StatusItem(
                  value: '${status.battery}%',
                  label: 'BATTERY',
                ),
                _StatusItem(
                  value: '${status.humanCount}',
                  label: 'TEMP',
                ),
                _StatusItem(
                  value: '${status.battery}%',
                  label: 'SIGNAL',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMissionStatus() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.connectedGreen.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.check_circle,
                size: 20.w,
                color: AppTheme.connectedGreen,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pre-completed 4 rescue missions',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Last run',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartMissionButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.brandCyan.withValues(alpha: 0.3),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Start Mission',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatusItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
