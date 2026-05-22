import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/onboarding_page_indicator.dart';
import '../../core/widgets/svg_asset_image.dart';
import 'cubit/onboarding_cubit.dart';
import 'cubit/onboarding_state.dart';
import 'onboarding_data.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: const _OnboardingContent(),
    );
  }
}

class _OnboardingContent extends StatefulWidget {
  const _OnboardingContent();

  @override
  State<_OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<_OnboardingContent> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToNextPage(int page) {
    return _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _OnboardingPageView(
                controller: _pageController,
                onPageChanged: (index) {
                  context.read<OnboardingCubit>().setPage(index);
                },
              ),
            ),
            _BottomControls(onNextPage: _goToNextPage),
            SizedBox(height: 38.h),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  const _OnboardingPageView({
    required this.controller,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      onPageChanged: onPageChanged,
      itemCount: onboardingPages.length,
      itemBuilder: (context, index) {
        final page = onboardingPages[index];
        return _OnboardingPage(
          image: page.image,
          title: page.title,
          description: page.description,
        );
      },
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          children: [
            SizedBox(height: 30.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 305.w, maxHeight: 292.h),
              child: SvgAssetImage(
                path: image,
                fit: BoxFit.contain,
                width: 305.w,
                height: 292.h,
                borderRadius: BorderRadius.circular(95.r),
              ),
            ),
            SizedBox(height: 24.h),
            BlocSelector<OnboardingCubit, OnboardingState, int>(
              selector: (state) => state.currentPage,
              builder: (context, currentPage) {
                return OnboardingPageIndicator(
                  currentPage: currentPage,
                  totalPages: onboardingPages.length,
                );
              },
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 278.w),
              child: _OnboardingDescription(description: description),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _OnboardingDescription extends StatelessWidget {
  final String description;

  const _OnboardingDescription({required this.description});

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 11.sp,
      height: 1.35,
      fontWeight: FontWeight.w400,
    );

    if (!description.contains('ResQer')) {
      return Text(description, style: bodyStyle, textAlign: TextAlign.center);
    }

    final parts = description.split('ResQer');
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: bodyStyle,
        children: [
          TextSpan(text: parts.first),
          TextSpan(
            text: 'ResQer',
            style: bodyStyle?.copyWith(color: AppTheme.brandCyan),
          ),
          TextSpan(text: parts.skip(1).join('ResQer')),
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final ValueChanged<int> onNextPage;

  const _BottomControls({required this.onNextPage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 29.w, end: 29.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              context.go('/home');
            },
            child: Text(
              'skip',
              style: TextStyle(
                color: AppTheme.skipTextColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              final isLastPage =
                  state.currentPage == onboardingPages.length - 1;
              return GradientButton(
                text: isLastPage ? 'Start now' : 'NEXT',
                width: isLastPage ? 116 : 94,
                onPressed: () {
                  if (isLastPage) {
                    context.go('/home');
                  } else {
                    final nextPage = state.currentPage + 1;
                    context.read<OnboardingCubit>().nextPage(
                      onboardingPages.length,
                    );
                    onNextPage(nextPage);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
