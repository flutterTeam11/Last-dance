import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/drone_report.dart';

class ReportTile extends StatelessWidget {
  final DroneReport report;

  const ReportTile({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.reportCardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppTheme.cardBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _iconColor.withValues(alpha: 0.12),
            ),
            child: Icon(
              _icon,
              size: 20.w,
              color: _iconColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  report.timeAgo,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 20.w,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  String get _title {
    switch (report.type) {
      case ReportType.humanDetected:
        return 'HUMAN DETECTED';
      case ReportType.systemOverheated:
        return 'SYSTEM OVERHEATED';
      case ReportType.missionComplete:
        return 'MISSION COMPLETE';
    }
  }

  IconData get _icon {
    switch (report.type) {
      case ReportType.humanDetected:
        return Icons.person_search;
      case ReportType.systemOverheated:
        return Icons.warning_amber;
      case ReportType.missionComplete:
        return Icons.check_circle_outline;
    }
  }

  Color get _iconColor {
    switch (report.type) {
      case ReportType.humanDetected:
        return AppTheme.brandBlue;
      case ReportType.systemOverheated:
        return AppTheme.warningOrange;
      case ReportType.missionComplete:
        return AppTheme.connectedGreen;
    }
  }
}
