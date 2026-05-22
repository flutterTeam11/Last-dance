import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class ConnectionStatusBar extends StatelessWidget {
  final bool isConnected;
  final VoidCallback? onSettingsTap;

  const ConnectionStatusBar({
    super.key,
    required this.isConnected,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Text(
            isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 10.w,
            height: 10.w,
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
                  spreadRadius: 1.r,
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSettingsTap,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.reportCardBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.settings_outlined,
                size: 22.w,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
