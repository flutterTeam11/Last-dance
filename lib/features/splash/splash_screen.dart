import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../auth/presentation/cubit/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    final cubit = getIt<AuthCubit>();
    await cubit.checkAuthStatus();
    if (!mounted) return;

    final state = cubit.state;
    if (state is AuthSuccess) {
      context.go('/home', extra: true);
    } else {
      _scheduleOnboardingNavigation();
    }
  }

  void _scheduleOnboardingNavigation() {
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.splashBackground,
      body: Center(
        child: SvgPicture.asset(
          'assets/images/splash/Phoenix.svg',
          width: 184.w,
          height: 184.w,
        ),
      ),
    );
  }
}
