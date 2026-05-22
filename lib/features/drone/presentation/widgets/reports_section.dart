import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/drone_report.dart';
import '../cubit/drone_status_cubit.dart';
import '../cubit/drone_status_state.dart';
import 'report_tile.dart';

class ReportsSection extends StatelessWidget {
  const ReportsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'reports',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          BlocBuilder<DroneStatusCubit, DroneStatusState>(
            buildWhen: (prev, curr) {
              if (prev is DroneStatusLoaded && curr is DroneStatusLoaded) {
                return prev.reports != curr.reports;
              }
              return true;
            },
            builder: (context, state) {
              final reports = state is DroneStatusLoaded
                  ? state.reports
                  : <DroneReport>[];
              if (reports.isEmpty) return const _EmptyReports();
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reports.length,
                itemBuilder: (context, index) =>
                    ReportTile(report: reports[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.reportCardBg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 32.w,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 8.h),
            Text(
              'No reports yet',
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
