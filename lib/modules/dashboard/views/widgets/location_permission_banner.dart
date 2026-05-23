import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import '/modules/common/module_responsive.dart';

class LocationPermissionBanner extends StatelessWidget {
  const LocationPermissionBanner({
    super.key,
    required this.message,
    required this.onEnable,
  });

  final String message;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return Material(
      color: colors.tertiaryContainer,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_outlined,
              color: colors.onTertiaryContainer,
              size: 22.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: text.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                      color: colors.onTertiaryContainer,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextButton(
                    onPressed: onEnable,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: colors.onTertiaryContainer,
                    ),
                    child: Text(
                      'Enable location',
                      style: text.labelLarge?.copyWith(
                        fontSize: 13.sp,
                        color: colors.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
