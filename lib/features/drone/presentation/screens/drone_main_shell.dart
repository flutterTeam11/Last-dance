import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../cubit/drone_status_cubit.dart';
import '../cubit/drone_tracking_cubit.dart';
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

  final List<Widget> _screens = const [
    DroneHomeScreen(),
    DroneMapScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _trackingCubit = getIt<DroneTrackingCubit>();
    _statusCubit = getIt<DroneStatusCubit>();
    _videoFeedCubit = getIt<VideoFeedCubit>();

    _statusCubit.startListening();
    _trackingCubit.startTracking();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _trackingCubit),
        BlocProvider.value(value: _statusCubit),
        BlocProvider.value(value: _videoFeedCubit),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: DroneBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
