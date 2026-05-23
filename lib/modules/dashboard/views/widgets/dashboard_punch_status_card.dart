import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import '/modules/common/module_responsive.dart';

class DashboardPunchStatusCard extends StatelessWidget {
  const DashboardPunchStatusCard({
    super.key,
    required this.isPunchedIn,
    required this.lastPunchLabel,
  });

  final bool isPunchedIn;
  final String lastPunchLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
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
              isPunchedIn
                  ? Icons.door_back_door_outlined
                  : Icons.sensor_door,
              size: 32.sp,
              color: colors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            isPunchedIn ? 'Punched In' : 'Punched Out',
            style: text.headlineMedium?.copyWith(fontSize: 28.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            'CURRENT STATUS',
            style: text.labelSmall?.copyWith(fontSize: 12.sp),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: colors.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: isPunchedIn ? colors.tertiary : colors.outline,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  lastPunchLabel,
                  style: text.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
