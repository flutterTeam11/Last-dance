import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/drone_status.dart';
import '../cubit/drone_status_cubit.dart';
import '../cubit/drone_status_state.dart';
import '../cubit/video_feed_cubit.dart';
import '../cubit/video_feed_state.dart';
import '../widgets/drone_stats_bar.dart';
import '../widgets/virtual_joystick.dart';

class DroneFullscreenVideoScreen extends StatefulWidget {
  const DroneFullscreenVideoScreen({super.key});

  @override
  State<DroneFullscreenVideoScreen> createState() =>
      _DroneFullscreenVideoScreenState();
}

class _DroneFullscreenVideoScreenState
    extends State<DroneFullscreenVideoScreen> {
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<DroneStatusCubit>()),
        BlocProvider.value(value: getIt<VideoFeedCubit>()),
      ],
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () => setState(() => _showOverlay = !_showOverlay),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildVideoBackground(),
              if (_showOverlay) ...[
                _buildTopOverlay(),
                _buildBottomControls(),
                _buildBackButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoBackground() {
    return BlocBuilder<VideoFeedCubit, VideoFeedState>(
      builder: (context, state) {
        return ColorFiltered(
          colorFilter: state.mode == VideoMode.thermal
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
          child: Container(
            color: AppTheme.darkBackground,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videocam_outlined,
                    size: 60.w,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Live Feed',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _showOverlay ? 1.0 : 0.0,
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 16.w,
            right: 16.w,
            bottom: 12.h,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.6),
                Colors.transparent,
              ],
            ),
          ),
          child: BlocBuilder<DroneStatusCubit, DroneStatusState>(
            builder: (context, state) {
              final status = state is DroneStatusLoaded
                  ? state.status
                  : const DroneStatus.initial();
              return DroneStatsBar(
                status: status,
                isOverlay: true,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 30.h,
      left: 24.w,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _showOverlay ? 1.0 : 0.0,
        child: VirtualJoystick(
          onDirectionChanged: (direction) {},
          onDirectionEnd: () {},
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8.h,
      left: 16.w,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
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
