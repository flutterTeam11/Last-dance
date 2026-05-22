import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/video_feed_state.dart';

class VideoModeToggle extends StatelessWidget {
  final VideoMode currentMode;
  final ValueChanged<VideoMode> onModeChanged;

  const VideoModeToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.reportCardBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem(
            label: 'Normal',
            mode: VideoMode.normal,
            isActive: currentMode == VideoMode.normal,
          ),
          _buildToggleItem(
            label: 'Thermal',
            mode: VideoMode.thermal,
            isActive: currentMode == VideoMode.thermal,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required VideoMode mode,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.brandCyan.withValues(alpha: 0.3),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
