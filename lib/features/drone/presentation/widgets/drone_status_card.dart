import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/drone_status.dart';
import '../cubit/drone_tracking_cubit.dart';
import 'drone_circular_indicator.dart';

class DroneStatusCard extends StatelessWidget {
  final DroneStatus status;
  final VoidCallback? onMapTap;

  const DroneStatusCard({super.key, required this.status, this.onMapTap});

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
                    DroneCircularIndicator(
                      progress: status.battery / 100.0,
                      valueText: '${status.battery}%',
                      labelText: 'SIGNAL',
                    ),
                    SizedBox(width: 24.w),
                    DroneCircularIndicator(
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
          _buildMiniMapPreview(context),
        ],
      ),
    );
  }

  Widget _buildMiniMapPreview(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
            SvgPicture.asset(
              'assets/map/map.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Center(
              child: Icon(Icons.location_on, color: Colors.red, size: 26.w),
            ),
          ],
        ),
      ),
    );
  }
}
