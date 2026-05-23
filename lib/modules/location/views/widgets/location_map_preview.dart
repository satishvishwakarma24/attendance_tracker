import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import '/modules/common/module_responsive.dart';

class LocationMapPreview extends StatelessWidget {
  const LocationMapPreview({
    super.key,
    required this.radius,
    required this.officeLat,
    required this.officeLng,
    required this.deviceLat,
    required this.deviceLng,
    required this.gpsPillLabel,
    required this.isFetchingGps,
    required this.onUseGps,
  });

  final double radius;
  final double? officeLat;
  final double? officeLng;
  final double? deviceLat;
  final double? deviceLng;
  final String gpsPillLabel;
  final bool isFetchingGps;
  final VoidCallback onUseGps;

  static const _mapImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBd_oFgQAyFXrYLfjhr5G8uCXM5BTMSqSG-EZfRH8_U4Z8Ec8TeMvPvNqwtwDwZ1LnyK_MdjTzVnvqYAcq8XWAj4kNwyKPr93BiYFjWyFj4TT941_BbACsKdAL_yRCA-stwF_vZHpWoEN_UCyUGD_8nNWU7YV8b0TjQtgxDTX4x5pLwakWmd_DoQCMvMm4QJFldbAu5div0Bg8FH5aDzO8yIFBjuMxgFi84hiz4Iayo4zHsd9ImZlFPktuhy4ZzhXsEL7AQy8jxbIGm';

  Offset _deviceOffset() {
    if (officeLat == null ||
        officeLng == null ||
        deviceLat == null ||
        deviceLng == null) {
      return Offset.zero;
    }
    final scale = 4200.0.w;
    final dx = ((deviceLng! - officeLng!) * scale).clamp(-72.w, 72.w);
    final dy = ((officeLat! - deviceLat!) * scale).clamp(-56.h, 56.h);
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final hasOffice = officeLat != null && officeLng != null;
    final showDevice = deviceLat != null &&
        deviceLng != null &&
        hasOffice &&
        (deviceLat != officeLat || deviceLng != officeLng);
    final deviceOffset = showDevice ? _deviceOffset() : Offset.zero;
    final circleSize = 50.w + (radius * 0.3).w;

    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.outline),
        image: const DecorationImage(
          image: NetworkImage(_mapImageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!hasOffice)
            Center(
              child: Text(
                'Set coordinates or tap GPS',
                style: text.labelLarge?.copyWith(fontSize: 13.sp),
              ),
            ),
          if (hasOffice)
            Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.5),
                        width: 2.w,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.location_on,
                    color: colors.error,
                    size: 36.sp,
                  ),
                ],
              ),
            ),
          if (showDevice)
            Center(
              child: Transform.translate(
                offset: deviceOffset,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surfaceContainerLowest, width: 2.w),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.25),
                        blurRadius: 6.r,
                        spreadRadius: 2.r,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 12.h,
            right: 12.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isFetchingGps ? null : onUseGps,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFetchingGps)
                        SizedBox(
                          width: 14.w,
                          height: 14.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        )
                      else
                        Icon(Icons.my_location,
                            size: 14.sp, color: colors.primary),
                      SizedBox(width: 6.w),
                      Text(
                        gpsPillLabel,
                        style: text.labelLarge?.copyWith(
                          fontSize: 12.sp,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
