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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildToggleItem(
            label: 'Normal',
            mode: VideoMode.normal,
            isActive: currentMode == VideoMode.normal,
          ),
          SizedBox(width: 12.w),
          _buildToggleItem(
            label: 'Thermal',
            mode: VideoMode.thermal,
            isActive: currentMode == VideoMode.thermal,
          ),
          SizedBox(width: 12.w),
          _buildToggleItem(
            label: 'Overlay',
            mode: VideoMode.overlay,
            isActive: currentMode == VideoMode.overlay,
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
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isActive ? null : Colors.white,
          gradient: isActive ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(24.r),
          border: isActive
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.brandCyan.withValues(alpha: 0.3),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4.r,
                    offset: Offset(0, 1.h),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
