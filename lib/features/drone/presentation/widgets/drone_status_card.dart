import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/drone_status.dart';
import '../cubit/drone_tracking_cubit.dart';

class DroneStatusCard extends StatelessWidget {
  final DroneStatus status;
  final VoidCallback? onMapTap;

  const DroneStatusCard({
    super.key,
    required this.status,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.black, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Telemetry Info & Circular Progresses
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Drone Status',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    // SIGNAL Indicator
                    _CircularProgressIndicator(
                      progress: status.battery / 100.0,
                      valueText: '${status.battery}%',
                      labelText: 'SIGNAL',
                    ),
                    SizedBox(width: 24.w),
                    // HUMAN Indicator
                    _CircularProgressIndicator(
                      progress: status.humanCount > 0
                          ? (status.humanCount / 10.0).clamp(0.0, 1.0)
                          : 0.0,
                      valueText: '${status.humanCount}',
                      labelText: 'HUMAN',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right side: Map Preview Card
          _buildMiniMapPreview(context),
        ],
      ),
    );
  }

  Widget _buildMiniMapPreview(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Trigger centering on user and navigate to map tab
        context.read<DroneTrackingCubit>().triggerCenterOnUser();
        onMapTap?.call();
      },
      child: Container(
        width: 140.w,
        height: 96.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Map SVG placeholder
            SvgPicture.asset(
              'assets/map/map.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            // Red pin in center
            Center(
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: 26.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String valueText;
  final String labelText;

  const _CircularProgressIndicator({
    required this.progress,
    required this.valueText,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 56.w,
          height: 56.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Track circle (background)
              SizedBox(
                width: 56.w,
                height: 56.w,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 4.5.w,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFFF8A00).withValues(alpha: 0.15),
                  ),
                ),
              ),
              // Active progress circle
              SizedBox(
                width: 56.w,
                height: 56.w,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4.5.w,
                  strokeCap: StrokeCap.round,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF8A00),
                  ),
                ),
              ),
              // Value inside circle
              Text(
                valueText,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          labelText,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
