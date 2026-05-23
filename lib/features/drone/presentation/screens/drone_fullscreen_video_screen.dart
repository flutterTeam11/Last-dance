import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/websocket/drone_ws_bridge.dart';
import '../../domain/drone_status.dart';
import '../cubit/drone_status_cubit.dart';
import '../cubit/drone_status_state.dart';
import '../cubit/video_feed_cubit.dart';
import '../cubit/video_feed_state.dart';
import '../widgets/drone_stats_bar.dart';
import '../widgets/video_back_button.dart';
import '../widgets/video_feed_background.dart';
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
              const _VideoContent(),
              if (_showOverlay) ...[
                _buildTopOverlay(),
                _buildBottomControls(),
                const VideoBackButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
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
                return DroneStatsBar(status: status, isOverlay: true);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final wsBridge = getIt<DroneWsBridge>();
    return Positioned(
      bottom: 30.h,
      left: 24.w,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _showOverlay ? 1.0 : 0.0,
        child: VirtualJoystick(
          onDirectionChanged: (offset) {
            wsBridge.sendCommand('move', {
              'x': offset.dx.toStringAsFixed(2),
              'y': offset.dy.toStringAsFixed(2),
            });
          },
          onDirectionEnd: () {
            wsBridge.sendCommand('move', {'x': '0', 'y': '0'});
          },
        ),
      ),
    );
  }
}

class _VideoContent extends StatelessWidget {
  const _VideoContent();
  @override
  Widget build(BuildContext context) {
    final wsBridge = getIt<DroneWsBridge>();
    return BlocBuilder<VideoFeedCubit, VideoFeedState>(
      builder: (context, state) {
        return StreamBuilder<Uint8List>(
          stream: wsBridge.videoFrame,
          builder: (context, frameSnapshot) {
            return StreamBuilder<List<DetectionBox>>(
              stream: wsBridge.detectionBoxes,
              builder: (context, detSnapshot) {
                return VideoFeedBackground(
                  mode: state.mode,
                  videoFrame: frameSnapshot.data,
                  detections: detSnapshot.data,
                );
              },
            );
          },
        );
      },
    );
  }
}
