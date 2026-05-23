import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import '../../../common/widgets/module_responsive.dart';

class DashboardGeofenceStatusCard extends StatelessWidget {
  const DashboardGeofenceStatusCard({
    super.key,
    required this.isInsideGeofence,
    required this.isLoading,
    required this.zoneTitle,
    required this.zoneSubtitle,
    required this.onRefresh,
  });

  final bool isInsideGeofence;
  final bool isLoading;
  final String zoneTitle;
  final String zoneSubtitle;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    final borderColor =
        isInsideGeofence ? colors.primaryContainer : colors.errorContainer;
    final iconBg =
        isInsideGeofence ? colors.primaryContainer : colors.errorContainer;
    final iconColor =
        isInsideGeofence ? colors.onPrimaryContainer : colors.error;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isInsideGeofence
                  ? Icons.verified
                  : Icons.location_off_outlined,
              color: iconColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zoneTitle,
                  style: text.labelLarge?.copyWith(fontSize: 14.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  zoneSubtitle,
                  style: text.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    color: colors.secondary,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 22.w,
              height: 22.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.refresh, color: colors.onSurfaceVariant, size: 22.sp),
              onPressed: onRefresh,
            ),
        ],
      ),
    );
  }
}
