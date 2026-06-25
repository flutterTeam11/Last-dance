import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/mission_cubit.dart';
import '../cubit/mission_state.dart';
import '../cubit/pi_health_cubit.dart';
import '../widgets/drone_map_status_bar.dart';
import '../widgets/drone_map_view.dart';
import '../widgets/map_screen_header.dart';
import '../widgets/mission_status_card.dart';
import '../widgets/motor_control_panel.dart';
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
    context.read<PiHealthCubit>().startPolling();
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
              const _MissionButtons(),
              SizedBox(height: 16.h),
              const _MotorControlsSection(),
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

class _MissionButtons extends StatelessWidget {
  const _MissionButtons();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MissionCubit, MissionState>(
      listener: (context, state) {
        if (state.message != null && state.message!.isNotEmpty) {
          final isError = state.status == MissionStatus.error
              || state.status == MissionStatus.piOffline;
          showSnakBar(context, state.message!, isError: isError);
        }
      },
      builder: (context, state) {
        final piOnline = context.watch<PiHealthCubit>().state.isOnline;
        final isBusy = state.isBusy;
        final isRunning = state.isRunning;

        return Column(
          children: [
            StartMissionButton(
              label: isRunning ? 'RUNNING' : 'Start Mission',
              onPressed: (isRunning || isBusy || !piOnline)
                  ? null
                  : () => context.read<MissionCubit>().startMission(),
              isLoading: state.status == MissionStatus.starting,
            ),
            SizedBox(height: 12.h),
            StartMissionButton(
              label: 'Stop Mission',
              onPressed: (!isRunning || isBusy || !piOnline)
                  ? null
                  : () => context.read<MissionCubit>().stopMission(),
              isStop: true,
              isLoading: state.status == MissionStatus.stopping,
            ),
          ],
        );
      },
    );
  }
}

class _MotorControlsSection extends StatelessWidget {
  const _MotorControlsSection();

  @override
  Widget build(BuildContext context) {
    return const MotorControlPanel();
  }
}
