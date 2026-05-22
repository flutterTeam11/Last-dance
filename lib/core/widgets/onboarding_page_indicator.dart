import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingPageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          width: currentPage == index ? 24.w : 8.w,
          height: 4.h,
          decoration: BoxDecoration(
            gradient: currentPage == index ? AppTheme.primaryGradient : null,
            color: currentPage == index
                ? null
                : AppTheme.inactiveIndicatorColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }
}
