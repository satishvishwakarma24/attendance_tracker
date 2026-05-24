import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import '/core/widgets/map_background_image.dart';
import '../../../common/widgets/module_responsive.dart';

class LocationMapPreview extends StatelessWidget {
  const LocationMapPreview({
    super.key,
    required this.radius,
    required this.officeLat,
    required this.officeLng,
    required this.deviceLat,
    required this.deviceLng,
    required this.isFetchingGps,
    required this.onCurrentLocation,
    required this.onSelectOnMap,
  });

  final double radius;
  final double? officeLat;
  final double? officeLng;
  final double? deviceLat;
  final double? deviceLng;
  final bool isFetchingGps;
  final VoidCallback onCurrentLocation;
  final VoidCallback onSelectOnMap;

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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.outline),
      ),
      child: MapBackgroundImage(
        latitude: officeLat,
        longitude: officeLng,
        zoom: 14,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (!hasOffice)
              Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color:
                        colors.surfaceContainerLowest.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'No Location Chosen',
                    style: text.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      color: colors.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
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
                      border: Border.all(
                          color: colors.surfaceContainerLowest, width: 2.w),
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
              left: 16.w,
              right: 16.w,
              bottom: 12.h,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isFetchingGps ? null : onCurrentLocation,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: colors.surfaceContainerLowest
                            .withValues(alpha: 0.92),
                      ),
                      icon: isFetchingGps
                          ? SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            )
                          : Icon(Icons.my_location, size: 16.sp),
                      label: Text(
                        isFetchingGps ? 'Locating…' : 'Current Location',
                        style: text.labelLarge?.copyWith(fontSize: 12.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isFetchingGps ? null : onSelectOnMap,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: colors.surfaceContainerLowest
                            .withValues(alpha: 0.92),
                      ),
                      icon: Icon(Icons.map_outlined, size: 16.sp),
                      label: Text(
                        'Select on Map',
                        style: text.labelLarge?.copyWith(fontSize: 12.sp),
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
