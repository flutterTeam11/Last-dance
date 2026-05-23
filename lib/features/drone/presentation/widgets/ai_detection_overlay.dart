import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/websocket/drone_ws_bridge.dart';

class AIDetectionOverlay extends StatelessWidget {
  final List<DetectionBox>? detections;

  const AIDetectionOverlay({super.key, this.detections});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF22C55E),
                width: 1.5.w,
              ),
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
        ),
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
        ..._buildDetectionBoxes(),
      ],
    );
  }

  List<Widget> _buildDetectionBoxes() {
    if (detections == null || detections!.isEmpty) return [];

    return detections!.map((det) {
      return Positioned(
        top: det.y.h,
        left: det.x.w,
        child: Container(
          width: det.w.w,
          height: det.h.h,
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
                    '${det.label.toUpperCase()} ${(det.confidence * 100).toInt()}%',
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
      );
    }).toList();
  }

  Widget _buildHudLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF22C55E),
        letterSpacing: 0.5,
        shadows: const [
          Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 1),
        ],
      ),
    );
  }
}
