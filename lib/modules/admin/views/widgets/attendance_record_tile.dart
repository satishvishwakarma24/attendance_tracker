import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/theme/app_theme.dart';
import '/data/models/attendance_record.dart';
import '/modules/common/module_responsive.dart';

class AttendanceRecordTile extends StatelessWidget {
  const AttendanceRecordTile({
    super.key,
    required this.record,
  });

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final time = record.timestamp != null
        ? DateFormat('MMM d, hh:mm a').format(record.timestamp!)
        : '—';
    final isIn = record.isPunchIn;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            isIn ? Icons.login : Icons.logout,
            color: isIn ? colors.tertiary : colors.primary,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.userEmail ?? record.userId,
                  style: text.labelLarge?.copyWith(
                    fontSize: 14.sp,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  '${record.locationName ?? record.locationId} · ${isIn ? 'In' : 'Out'}',
                  style: text.bodySmall?.copyWith(fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: text.bodySmall?.copyWith(
              fontSize: 12.sp,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
