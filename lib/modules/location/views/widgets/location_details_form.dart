import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import '/modules/common/module_responsive.dart';

class LocationDetailsForm extends StatelessWidget {
  const LocationDetailsForm({
    super.key,
    required this.nameController,
    required this.latController,
    required this.lngController,
    required this.radius,
    required this.onRadiusChanged,
    required this.isEditing,
    required this.isActive,
    required this.onActiveChanged,
    required this.isFetchingGps,
    required this.onUseCurrentLocation,
    required this.isSaving,
    required this.onSave,
  });

  final TextEditingController nameController;
  final TextEditingController latController;
  final TextEditingController lngController;
  final double radius;
  final ValueChanged<double> onRadiusChanged;
  final bool isEditing;
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;
  final bool isFetchingGps;
  final VoidCallback onUseCurrentLocation;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Office Name', style: text.labelLarge?.copyWith(fontSize: 14.sp)),
              SizedBox(height: 8.h),
              TextField(
                controller: nameController,
                style: text.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: colors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Headquarters',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Latitude',
                            style: text.labelLarge?.copyWith(fontSize: 14.sp)),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: latController,
                          keyboardType: TextInputType.number,
                          style: text.bodyMedium?.copyWith(fontSize: 14.sp),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Longitude',
                            style: text.labelLarge?.copyWith(fontSize: 14.sp)),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: lngController,
                          keyboardType: TextInputType.number,
                          style: text.bodyMedium?.copyWith(fontSize: 14.sp),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: isFetchingGps ? null : onUseCurrentLocation,
                  icon: isFetchingGps
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        )
                      : Icon(Icons.my_location, size: 18.sp),
                  label: Text(
                    'Use current location',
                    style: text.labelLarge?.copyWith(
                      fontSize: 14.sp,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Geofence Radius (meters)',
                      style: text.labelLarge?.copyWith(fontSize: 14.sp)),
                  Text(
                    '${radius.toInt()}m',
                    style: text.labelLarge?.copyWith(
                      fontSize: 14.sp,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: radius,
                min: 10,
                max: 500,
                onChanged: onRadiusChanged,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('10m', style: text.bodySmall?.copyWith(fontSize: 12.sp)),
                  Text('500m', style: text.bodySmall?.copyWith(fontSize: 12.sp)),
                ],
              ),
              if (isEditing) ...[
                SizedBox(height: 8.h),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Active geofence',
                      style: text.labelLarge?.copyWith(fontSize: 14.sp)),
                  subtitle: Text(
                    'Inactive locations are hidden from employees',
                    style: text.bodySmall?.copyWith(fontSize: 12.sp),
                  ),
                  value: isActive,
                  activeThumbColor: colors.primary,
                  onChanged: onActiveChanged,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 48.h),
        ElevatedButton(
          onPressed: isSaving ? null : onSave,
          style: context.appTheme.elevatedButtonTheme.style?.copyWith(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 16.h),
            ),
            minimumSize: WidgetStatePropertyAll(Size(double.infinity, 50.h)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSaving)
                SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onPrimary,
                  ),
                )
              else ...[
                Icon(Icons.save, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  isEditing ? 'Update Location' : 'Save Location',
                  style: text.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    color: colors.onPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
