import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/video_feed_state.dart';
import 'ai_detection_overlay.dart';
import 'simulated_feed.dart';

class VideoPreviewCard extends StatelessWidget {
  final VideoMode mode;
  final VoidCallback? onTap;
  final Widget? videoWidget;

  const VideoPreviewCard({
    super.key,
    required this.mode,
    this.onTap,
    this.videoWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: AppTheme.darkBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (videoWidget != null)
              ColorFiltered(
                colorFilter: mode == VideoMode.thermal
                    ? const ColorFilter.matrix(<double>[
                        0.5,
                        0.5,
                        0.5,
                        0,
                        0,
                        0.1,
                        0.1,
                        0.1,
                        0,
                        0,
                        -0.2,
                        -0.2,
                        -0.2,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ])
                    : const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      ),
                child: videoWidget!,
              )
            else
              SimulatedFeed(mode: mode),
            if (mode == VideoMode.overlay) const AIDetectionOverlay(),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fullscreen, size: 16.w, color: Colors.white70),
                    SizedBox(width: 4.w),
                    Text(
                      'Tap to expand',
                      style: TextStyle(fontSize: 10.sp, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
