import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class DroneCircularIndicator extends StatelessWidget {
  final double progress;
  final String valueText;
  final String labelText;

  const DroneCircularIndicator({
    super.key,
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
