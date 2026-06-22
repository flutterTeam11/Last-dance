import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../drone/domain/drone_repository.dart';
import '../widgets/drone_map_status_bar.dart';
import '../widgets/drone_map_view.dart';
import '../widgets/map_screen_header.dart';
import '../widgets/mission_status_card.dart';
import '../widgets/start_mission_button.dart';

class DroneMapScreen extends StatelessWidget {
  const DroneMapScreen({super.key});

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
              StartMissionButton(
                onPressed: () {
                  getIt<DroneRepository>().sendCommand('start_mission', {});
                },
              ),
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
