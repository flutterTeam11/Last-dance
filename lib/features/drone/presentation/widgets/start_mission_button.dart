import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/mission_state.dart';

class StartMissionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isStop;
  final bool isLoading;
  final MissionStatus? missionStatus;

  const StartMissionButton({
    super.key,
    this.label = 'Start Mission',
    this.onPressed,
    this.isStop = false,
    this.isLoading = false,
    this.missionStatus,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: disabled ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            gradient: isStop
                ? const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                  )
                : disabled
                    ? const LinearGradient(
                        colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)],
                      )
                    : AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: (isStop ? Colors.red : AppTheme.brandCyan)
                          .withValues(alpha: 0.3),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5.w,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: disabled ? Colors.white60 : Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
