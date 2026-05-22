import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const VideoBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8.h,
      left: 16.w,
      child: GestureDetector(
        onTap: onTap ?? () => Navigator.of(context).pop(),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18.w,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
