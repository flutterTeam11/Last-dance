import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/video_feed_state.dart';
import 'ai_detection_overlay.dart';

class VideoFeedBackground extends StatelessWidget {
  final VideoMode mode;

  const VideoFeedBackground({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
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
              : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
          child: Container(
            color: AppTheme.darkBackground,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mode == VideoMode.thermal
                        ? Icons.thermostat
                        : (mode == VideoMode.overlay
                              ? Icons.hub
                              : Icons.videocam_outlined),
                    size: 60.w,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    mode == VideoMode.thermal
                        ? 'Thermal Feed'
                        : (mode == VideoMode.overlay
                              ? 'AI Telemetry Feed'
                              : 'Live Feed'),
                    style: TextStyle(fontSize: 16.sp, color: Colors.white24),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (mode == VideoMode.overlay) const AIDetectionOverlay(),
      ],
    );
  }
}
