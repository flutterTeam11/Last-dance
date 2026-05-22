import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/video_feed_state.dart';

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
            // Video Feed or Simulated Grid Layout
            if (videoWidget != null)
              ColorFiltered(
                colorFilter: mode == VideoMode.thermal
                    ? const ColorFilter.matrix(<double>[
                        0.5, 0.5, 0.5, 0, 0,
                        0.1, 0.1, 0.1, 0, 0,
                        -0.2, -0.2, -0.2, 0, 0,
                        0, 0, 0, 1, 0,
                      ])
                    : const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      ),
                child: videoWidget!,
              )
            else
              _buildSimulatedFeed(),

            // AI Detection Overlay Layer
            if (mode == VideoMode.overlay)
              const AIDetectionOverlay(),

            // Top-right Expand Indicator
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
                    Icon(
                      Icons.fullscreen,
                      size: 16.w,
                      color: Colors.white70,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Tap to expand',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white70,
                      ),
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

  Widget _buildSimulatedFeed() {
    // Elegant dark grid simulation when no real camera feed is connected
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark slate
        image: DecorationImage(
          image: const AssetImage('assets/images/camera_grid.png'), // Fallback if exists
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.6),
            BlendMode.darken,
          ),
          onError: (exception, stackTrace) {},
        ),
      ),
      child: Stack(
        children: [
          // Background Tech Grid pattern
          CustomPaint(
            painter: _GridPainter(
              color: mode == VideoMode.thermal
                  ? const Color(0xFFFE8C43).withValues(alpha: 0.1) // Orange grids for thermal
                  : const Color(0xFF38BDF8).withValues(alpha: 0.08), // Cyan grids for normal/overlay
            ),
            child: Container(),
          ),
          if (mode == VideoMode.thermal)
            Container(
              color: const Color(0xFF3B0764).withValues(alpha: 0.3), // Thermal purple overlay
            ),
          // Connection details or dummy scene
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  mode == VideoMode.thermal
                      ? Icons.thermostat
                      : (mode == VideoMode.overlay ? Icons.hub : Icons.videocam),
                  size: 44.w,
                  color: mode == VideoMode.thermal
                      ? const Color(0xFFFE8C43)
                      : (mode == VideoMode.overlay ? const Color(0xFF38BDF8) : Colors.white54),
                ),
                SizedBox(height: 8.h),
                Text(
                  mode == VideoMode.thermal
                      ? 'Thermal Stream Live'
                      : (mode == VideoMode.overlay ? 'AI Telemetry Active' : 'Drone Camera Feed'),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AIDetectionOverlay extends StatelessWidget {
  const AIDetectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Center crosshair
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF22C55E), width: 1.5.w), // Green accent
                ),
                child: Center(
                  child: Container(
                    width: 4.w,
                    height: 4.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // HUD Overlay text (Left)
        Positioned(
          top: 16.h,
          left: 16.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHudLabel('SYS: ONLINE'),
              SizedBox(height: 2.h),
              _buildHudLabel('AI RECOGNITION: ENABLED'),
            ],
          ),
        ),
        // HUD Overlay text (Right)
        Positioned(
          bottom: 16.h,
          right: 16.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildHudLabel('ALT: 42.8M'),
              SizedBox(height: 2.h),
              _buildHudLabel('ZOOM: 1.5X'),
            ],
          ),
        ),
        // Bounding Box simulation (simulated AI target detection)
        Positioned(
          top: 50.h,
          left: 80.w,
          child: Container(
            width: 70.w,
            height: 90.h,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.redAccent, width: 2.w),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -16.h,
                  left: -2.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    color: Colors.redAccent,
                    child: Text(
                      'HUMAN 92%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHudLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF22C55E), // Neon green
        letterSpacing: 0.5,
        shadows: const [
          Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 1),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const step = 25.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }


  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.color != color;
}
