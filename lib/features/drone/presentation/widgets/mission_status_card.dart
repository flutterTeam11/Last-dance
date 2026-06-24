import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/mission_cubit.dart';
import '../cubit/mission_state.dart';

class MissionStatusCard extends StatelessWidget {
  const MissionStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: BlocBuilder<MissionCubit, MissionState>(
        builder: (context, state) {
          final status = state.status;
          final (icon, iconColor, title, subtitle) = _buildStatusInfo(status, state.message);

          return Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: [
                if (status == MissionStatus.starting
                    || status == MissionStatus.stopping
                    || status == MissionStatus.connecting)
                  SizedBox(
                    width: 36.w,
                    height: 36.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.w,
                      valueColor: AlwaysStoppedAnimation(iconColor),
                    ),
                  )
                else
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconColor.withValues(alpha: 0.12),
                    ),
                    child: Icon(icon, size: 20.w, color: iconColor),
                  ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (state.lastSuccessTime != null)
                  Text(
                    _formatTime(state.lastSuccessTime!),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  (IconData, Color, String, String?) _buildStatusInfo(
      MissionStatus status, String? message) {
    switch (status) {
      case MissionStatus.idle:
        return (
          Icons.timer_outlined,
          AppTheme.textSecondary,
          'Mission Ready',
          'Press Start to begin',
        );
      case MissionStatus.connecting:
        return (
          Icons.wifi_find,
          AppTheme.warningOrange,
          'Connecting...',
          'Establishing connection to Pi',
        );
      case MissionStatus.starting:
        return (
          Icons.rocket_launch_outlined,
          AppTheme.warningOrange,
          'Starting Mission...',
          message ?? 'Sending start command',
        );
      case MissionStatus.running:
        return (
          Icons.check_circle,
          AppTheme.connectedGreen,
          'Mission Running',
          message ?? 'Motors are active',
        );
      case MissionStatus.stopping:
        return (
          Icons.stop_circle_outlined,
          AppTheme.warningOrange,
          'Stopping Mission...',
          message ?? 'Sending stop command',
        );
      case MissionStatus.stopped:
        return (
          Icons.cancel_outlined,
          AppTheme.textSecondary,
          'Mission Stopped',
          message ?? 'Motors are idle',
        );
      case MissionStatus.error:
        return (
          Icons.error_outline,
          AppTheme.disconnectedRed,
          'Error',
          message ?? 'An error occurred',
        );
      case MissionStatus.piOffline:
        return (
          Icons.cloud_off,
          AppTheme.disconnectedRed,
          'Pi Offline',
          message ?? 'Cannot reach Raspberry Pi',
        );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
