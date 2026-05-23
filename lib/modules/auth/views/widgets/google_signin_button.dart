import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import '/modules/common/module_responsive.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  final VoidCallback? onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: colors.outlineVariant)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'or continue with',
                style: text.bodySmall?.copyWith(fontSize: 13.sp),
              ),
            ),
            Expanded(child: Divider(color: colors.outlineVariant)),
          ],
        ),
        SizedBox(height: 24.h),
        OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: context.appTheme.outlinedButtonTheme.style?.copyWith(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 14.h),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.g_mobiledata, color: colors.error, size: 28.sp),
              SizedBox(width: 8.w),
              Text(
                'Continue with Google',
                style: text.titleMedium?.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
