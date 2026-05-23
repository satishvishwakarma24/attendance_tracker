import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import '/data/models/attendance_record.dart';
import '/modules/common/module_responsive.dart';
import 'attendance_record_tile.dart';

class AttendanceRecordsList extends StatelessWidget {
  const AttendanceRecordsList({
    super.key,
    required this.records,
  });

  final List<AttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;

    if (records.isEmpty) {
      return Center(
        child: Text(
          'No punch records yet.',
          style: text.bodyMedium?.copyWith(fontSize: 14.sp),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: records.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        return AttendanceRecordTile(record: records[index]);
      },
    );
  }
}
