import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/drone_status.dart';
import 'drone_stat_item.dart';

class DroneStatsBar extends StatelessWidget {
  final DroneStatus status;
  final bool isOverlay;

  const DroneStatsBar({
    super.key,
    required this.status,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isOverlay ? AppTheme.statsOverlay : AppTheme.cardBackground;
    final textColor = isOverlay ? Colors.white : AppTheme.textPrimary;
    final labelColor = isOverlay ? Colors.white60 : AppTheme.textSecondary;

    return Container(
      margin: isOverlay
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isOverlay ? 12.r : 16.r),
        border: isOverlay ? null : Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          DroneStatItem(
            value: '${status.battery}%',
            label: 'BATTERY',
            textColor: textColor,
            labelColor: labelColor,
          ),
          DroneStatItem(
            value: '${status.humanCount}',
            label: 'HUMAN',
            textColor: textColor,
            labelColor: labelColor,
          ),
          DroneStatItem(
            value: '${status.height.toStringAsFixed(0)}m',
            label: 'Hight',
            textColor: textColor,
            labelColor: labelColor,
          ),
          DroneStatItem(
            value: '${status.speed.toStringAsFixed(0)}Km',
            label: 'Speed',
            textColor: textColor,
            labelColor: labelColor,
          ),
        ],
      ),
    );
  }
}
