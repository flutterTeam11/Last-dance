import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/drone_tracking_cubit.dart';
import '../widgets/drone_map_status_bar.dart';
import '../widgets/drone_map_view.dart';
import '../widgets/map_screen_header.dart';
import '../widgets/mission_status_card.dart';
import '../widgets/start_mission_button.dart';

class DroneMapScreen extends StatefulWidget {
  const DroneMapScreen({super.key});

  @override
  State<DroneMapScreen> createState() => _DroneMapScreenState();
}

class _DroneMapScreenState extends State<DroneMapScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DroneTrackingCubit>().startTracking();
  }

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
              SizedBox(height: 12.h),
              const MapScreenHeader(),
              SizedBox(height: 16.h),
              const _MapSection(),
              SizedBox(height: 16.h),
              const DroneMapStatusBar(),
              SizedBox(height: 16.h),
              const MissionStatusCard(),
              SizedBox(height: 16.h),
              const StartMissionButton(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: const DroneMapView(height: 280),
    );
  }
}
