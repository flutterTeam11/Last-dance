import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/drone_status.dart';

class DroneStatusCard extends StatelessWidget {
  final DroneStatus status;

  const DroneStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drone Status',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _StatusIndicator(
                      icon: Icons.signal_cellular_alt,
                      value: '${status.battery}%',
                      label: 'SIGNAL',
                      color: _signalColor(status.battery),
                    ),
                    SizedBox(width: 16.w),
                    _StatusIndicator(
                      icon: Icons.flight,
                      value: '',
                      label: '',
                      color: status.isConnected
                          ? AppTheme.connectedGreen
                          : AppTheme.disconnectedRed,
                      isIconOnly: true,
                    ),
                    SizedBox(width: 16.w),
                    _StatusIndicator(
                      icon: Icons.person_pin_circle,
                      value: '${status.humanCount}',
                      label: 'HUMAN',
                      color: status.humanCount > 0
                          ? AppTheme.disconnectedRed
                          : AppTheme.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _signalColor(int battery) {
    if (battery > 60) return AppTheme.connectedGreen;
    if (battery > 30) return AppTheme.warningOrange;
    return AppTheme.disconnectedRed;
  }
}

class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isIconOnly;

  const _StatusIndicator({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.isIconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
          ),
          child: Icon(icon, size: 18.w, color: color),
        ),
        if (!isIconOnly) ...[
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
