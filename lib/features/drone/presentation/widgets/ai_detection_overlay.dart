import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AIDetectionOverlay extends StatelessWidget {
  const AIDetectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
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
            ],
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
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
        color: const Color(0xFF22C55E),
        letterSpacing: 0.5,
        shadows: const [
          Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 1),
        ],
      ),
    );
  }
}
