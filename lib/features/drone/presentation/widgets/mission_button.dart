import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class MissionButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const MissionButton({super.key, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.primaryGradient : null,
          color: isActive ? null : AppTheme.reportCardBg,
          borderRadius: BorderRadius.circular(14.r),
          border: isActive ? null : Border.all(color: AppTheme.cardBorder),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.brandCyan.withValues(alpha: 0.3),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 18.w,
              color: isActive ? Colors.white : AppTheme.navBarInactive,
            ),
            SizedBox(width: 6.w),
            Text(
              'MISSION',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppTheme.navBarInactive,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
