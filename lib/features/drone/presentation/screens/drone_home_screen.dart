import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/websocket/drone_ws_bridge.dart';
// import '../../../../core/widgets/gradient_button.dart';
import '../../domain/drone_status.dart';
import '../cubit/drone_status_cubit.dart';
import '../cubit/drone_status_state.dart';
import '../cubit/video_feed_cubit.dart';
import '../cubit/video_feed_state.dart';
import '../widgets/connection_status_bar.dart';
import '../widgets/drone_status_card.dart';
import '../widgets/reports_section.dart';
import '../widgets/video_mode_toggle.dart';
import '../widgets/video_preview_card.dart';

class DroneHomeScreen extends StatelessWidget {
  final VoidCallback? onMapTap;
  const DroneHomeScreen({super.key, this.onMapTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              _buildConnectionBar(context),
              SizedBox(height: 16.h),
              _buildVideoSection(context),
              SizedBox(height: 16.h),
              _buildStatusSection(context),
              SizedBox(height: 16.h),
              // _buildPlanMissionButton(context),
              SizedBox(height: 20.h),
              const ReportsSection(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionBar(BuildContext context) {
    return BlocBuilder<DroneStatusCubit, DroneStatusState>(
      buildWhen: (prev, curr) {
        if (prev is DroneStatusLoaded && curr is DroneStatusLoaded) {
          return prev.status.isConnected != curr.status.isConnected;
        }
        return true;
      },
      builder: (context, state) {
        final isConnected =
            state is DroneStatusLoaded && state.status.isConnected;
        return ConnectionStatusBar(
          isConnected: isConnected,
          onSettingsTap: () {},
        );
      },
    );
  }

  Widget _buildVideoSection(BuildContext context) {
    final wsBridge = getIt<DroneWsBridge>();

    return BlocBuilder<VideoFeedCubit, VideoFeedState>(
      builder: (context, videoState) {
        return Column(
          children: [
            StreamBuilder<Uint8List>(
              stream: wsBridge.videoFrame,
              builder: (context, frameSnapshot) {
                return StreamBuilder<List<DetectionBox>>(
                  stream: wsBridge.detectionBoxes,
                  builder: (context, detSnapshot) {
                    return VideoPreviewCard(
                      mode: videoState.mode,
                      videoFrame: frameSnapshot.data,
                      detections: detSnapshot.data,
                      onTap: () => context.push('/fullscreen-video'),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 12.h),
            VideoModeToggle(
              currentMode: videoState.mode,
              onModeChanged: (mode) {
                context.read<VideoFeedCubit>().switchMode(mode);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return BlocBuilder<DroneStatusCubit, DroneStatusState>(
      buildWhen: (prev, curr) {
        if (prev is DroneStatusLoaded && curr is DroneStatusLoaded) {
          return prev.status != curr.status;
        }
        return true;
      },
      builder: (context, state) {
        final status = state is DroneStatusLoaded
            ? state.status
            : const DroneStatus.initial();
        return DroneStatusCard(status: status, onMapTap: onMapTap);
      },
    );
  }

  // Widget _buildPlanMissionButton(BuildContext context) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: 20.w),
  //     child: GradientButton(
  //       text: 'PLAN MISSION',
  //       width: double.infinity,
  //       height: 52,
  //       onPressed: () {},
  //     ),
  //   );
  // }
}
