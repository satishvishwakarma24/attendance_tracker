import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import '../../../common/widgets/module_responsive.dart';

class DashboardAdminSection extends StatelessWidget {
  const DashboardAdminSection({
    super.key,
    required this.onManageLocations,
    required this.onViewAttendance,
  });

  final VoidCallback onManageLocations;
  final VoidCallback onViewAttendance;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 32.sp,
                  color: colors.primary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Super Admin',
                style: text.titleMedium?.copyWith(fontSize: 24.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                'Punch in/out is for employees only. Use the actions below.',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(fontSize: 13.sp, height: 1.4),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        DashboardAdminActionCard(
          icon: Icons.location_on_outlined,
          title: 'Manage Locations',
          subtitle: 'Add, edit, or delete office geofences',
          onTap: onManageLocations,
        ),
        SizedBox(height: 12.h),
        DashboardAdminActionCard(
          icon: Icons.fact_check_outlined,
          title: 'Attendance Log',
          subtitle: 'View recent employee punch records',
          onTap: onViewAttendance,
        ),
      ],
    );
  }
}

class DashboardAdminActionCard extends StatelessWidget {
  const DashboardAdminActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.primary, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleMedium?.copyWith(fontSize: 16.sp),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: text.bodySmall?.copyWith(fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.onSurface.withValues(alpha: 0.5),
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
