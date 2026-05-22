import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/video_feed_state.dart';
import 'grid_painter.dart';

class SimulatedFeed extends StatelessWidget {
  final VideoMode mode;

  const SimulatedFeed({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        image: DecorationImage(
          image: const AssetImage('assets/images/camera_grid.png'),
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
          CustomPaint(
            painter: GridPainter(
              color: mode == VideoMode.thermal
                  ? const Color(0xFFFE8C43).withValues(alpha: 0.1)
                  : const Color(0xFF38BDF8).withValues(alpha: 0.08),
            ),
            child: Container(),
          ),
          if (mode == VideoMode.thermal)
            Container(color: const Color(0xFF3B0764).withValues(alpha: 0.3)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  mode == VideoMode.thermal
                      ? Icons.thermostat
                      : (mode == VideoMode.overlay
                            ? Icons.hub
                            : Icons.videocam),
                  size: 44.w,
                  color: mode == VideoMode.thermal
                      ? const Color(0xFFFE8C43)
                      : (mode == VideoMode.overlay
                            ? const Color(0xFF38BDF8)
                            : Colors.white54),
                ),
                SizedBox(height: 8.h),
                Text(
                  mode == VideoMode.thermal
                      ? 'Thermal Stream Live'
                      : (mode == VideoMode.overlay
                            ? 'AI Telemetry Active'
                            : 'Drone Camera Feed'),
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
