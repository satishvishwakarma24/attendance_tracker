import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import '/modules/common/module_responsive.dart';

class DashboardPunchButton extends StatelessWidget {
  const DashboardPunchButton({
    super.key,
    required this.isPunchedIn,
    required this.isPunching,
    required this.canPunch,
    required this.onPressed,
  });

  final bool isPunchedIn;
  final bool isPunching;
  final bool canPunch;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: context.appTheme.elevatedButtonTheme.style?.copyWith(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 16.h),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isPunching)
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.onPrimary,
                  ),
                )
              else ...[
                Icon(Icons.fingerprint, size: 28.sp),
                SizedBox(width: 12.w),
                Text(
                  isPunchedIn ? 'Punch Out' : 'Punch In',
                  style: text.titleMedium?.copyWith(
                    fontSize: 18.sp,
                    color: colors.onPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            canPunch
                ? 'Tap to record your workspace clocking time'
                : 'Punch is disabled until you are inside a geofence',
            style: text.bodySmall?.copyWith(
              fontSize: 12.sp,
              color: colors.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
