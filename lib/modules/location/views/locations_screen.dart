import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/routes_name.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/office_location_model.dart';
import '../../common/widgets/module_responsive.dart';
import '../providers/locations_provider.dart';

class LocationsScreen extends ConsumerWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(locationsStreamProvider);
    final colors = context.colors;
    final text = context.textStyles;

    return locationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Failed to load locations: $e',
          style: text.bodyMedium?.copyWith(fontSize: 14.sp),
        ),
      ),
      data: (locations) {
        return SingleChildScrollView(
          padding: ModuleResponsive.screenPadding,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
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
                      child: Icon(Icons.location_on,
                          color: colors.primary, size: 24.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Geofences',
                            style: text.titleMedium?.copyWith(fontSize: 16.sp),
                          ),
                          Text(
                            'Total Active Locations: ${locations.length}',
                            style: text.bodyMedium?.copyWith(fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              if (locations.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 40.h),
                  child: Text(
                    'No locations yet. Tap + to add one.',
                    style: text.bodyMedium?.copyWith(fontSize: 14.sp),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: locations.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final loc = locations[index];
                    return _LocationListTile(
                      location: loc,
                      onEdit: () => context.push(
                        '${RoutesName.addLocation}?id=${loc.id}',
                      ),
                      // onDelete: () => _confirmDeleteLocation(
                      //   context,
                      //   ref,
                      //   loc.id,
                      //   loc.name,
                      // ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// Future<void> _confirmDeleteLocation(
//   BuildContext context,
//   WidgetRef ref,
//   String locationId,
//   String locationName,
// ) async {
//   final colors = context.colors;
//   final text = context.textStyles;
//
//   final confirmed = await showDialog<bool>(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       title: Text('Delete location?', style: text.titleLarge),
//       content: Text(
//         'Remove "$locationName"? Employees will no longer punch at this geofence.',
//         style: text.bodyMedium,
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(ctx).pop(false),
//           child: const Text('Cancel'),
//         ),
//         FilledButton(
//           onPressed: () => Navigator.of(ctx).pop(true),
//           style: FilledButton.styleFrom(backgroundColor: colors.error),
//           child: const Text('Delete'),
//         ),
//       ],
//     ),
//   );
//
//   if (confirmed != true || !context.mounted) return;
//
//   try {
//     await ref.read(locationRepositoryProvider).deleteLocation(locationId);
//     if (!context.mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('"$locationName" deleted')),
//     );
//   } catch (e, s) {
//     Logger.error('Delete location failed', e, s);
//     if (!context.mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Could not delete location: $e'),
//         backgroundColor: colors.error,
//       ),
//     );
//   }
// }

class _LocationListTile extends StatelessWidget {
  const _LocationListTile({
    required this.location,
    required this.onEdit,
    // required this.onDelete,
  });

  final OfficeLocationModel location;
  final VoidCallback onEdit;
  // final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final loc = location;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(loc.listIcon, color: colors.primary, size: 28.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.name,
                  style: text.titleMedium?.copyWith(fontSize: 15.sp),
                ),
                Text(
                  loc.coordinatesLabel,
                  style: text.bodySmall?.copyWith(fontSize: 12.sp),
                ),
                Text(
                  'Radius: ${loc.radiusMeters.toStringAsFixed(0)} m',
                  style: text.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'Active',
              style: text.bodySmall?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
          Container(
            width: 36.w,
            height: 36.w,
            margin: EdgeInsets.only(left: 8.w),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: colors.outlineVariant,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: onEdit,
                child: Center(
                  child: Icon(
                    Icons.edit_rounded,
                    size: 18.sp,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
          )

          // PopupMenuButton<String>(
          //   icon: Icon(Icons.more_vert, size: 24.sp),
          //   onSelected: (value) {
          //     if (value == 'edit') {
          //       onEdit();
          //     }
          //     // else if (value == 'delete') {
          //     //   onDelete();
          //     // }
          //   },
          //   itemBuilder: (context) => [
          //     PopupMenuItem(
          //       value: 'edit',
          //       child: Icon(Icons.edit, size: 22.sp, color: colors.onSurface),
          //     ),
          //     // PopupMenuItem(value: 'delete', child: Text('Delete')),
          //   ],
          // ),
        ],
      ),
    );
  }
}
