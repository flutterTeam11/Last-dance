import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/websocket/drone_ws_bridge.dart';
import '../../../../core/websocket/ws_client.dart';
import '../cubit/drone_status_cubit.dart';
import '../cubit/drone_tracking_cubit.dart';
import '../cubit/mission_cubit.dart';
import '../cubit/pi_health_cubit.dart';
import '../cubit/video_feed_cubit.dart';
import '../screens/drone_home_screen.dart';
import '../screens/drone_map_screen.dart';
import '../widgets/drone_bottom_nav_bar.dart';

class DroneMainShell extends StatefulWidget {
  const DroneMainShell({super.key});

  @override
  State<DroneMainShell> createState() => _DroneMainShellState();
}

class _DroneMainShellState extends State<DroneMainShell> {
  int _currentIndex = 0;

  late final DroneTrackingCubit _trackingCubit;
  late final DroneStatusCubit _statusCubit;
  late final VideoFeedCubit _videoFeedCubit;
  late final MissionCubit _missionCubit;
  late final PiHealthCubit _piHealthCubit;
  late final WsClient _wsClient;
  late final DroneWsBridge _wsBridge;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _trackingCubit = getIt<DroneTrackingCubit>();
    _statusCubit = getIt<DroneStatusCubit>();
    _videoFeedCubit = getIt<VideoFeedCubit>();
    _missionCubit = getIt<MissionCubit>();
    _piHealthCubit = getIt<PiHealthCubit>();
    _wsClient = getIt<WsClient>();
    _wsBridge = DroneWsBridge(_wsClient);

    _statusCubit.startListening();
    _trackingCubit.startTracking();
    _wsClient.connect();
    _wsBridge.start();

    _screens = [
      DroneHomeScreen(
        onMapTap: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const DroneMapScreen(),
    ];
  }

  @override
  void dispose() {
    _wsBridge.dispose();
    _wsClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _trackingCubit),
        BlocProvider.value(value: _statusCubit),
        BlocProvider.value(value: _videoFeedCubit),
        BlocProvider.value(value: _missionCubit),
        BlocProvider.value(value: _piHealthCubit),
      ],
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: DroneBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
