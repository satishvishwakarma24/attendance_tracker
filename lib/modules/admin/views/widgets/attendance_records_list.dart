import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/theme/app_theme.dart';
import '/data/models/attendance_record.dart';
import '/modules/location/providers/locations_provider.dart';
import '../../../common/widgets/module_responsive.dart';
import 'admin_attendance_session.dart';
import 'attendance_record_tile.dart';

class AttendanceRecordsList extends ConsumerWidget {
  const AttendanceRecordsList({
    super.key,
    required this.records,
  });

  final List<AttendanceRecord> records;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = context.textStyles;
    final liveNames = ref.watch(locationNameMapProvider).value ?? {};
    final sessions = groupAttendanceIntoSessions(records);

    if (sessions.isEmpty) {
      return Center(
        child: Text(
          'No punch records yet.',
          style: text.bodyMedium?.copyWith(fontSize: 14.sp),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return AttendanceSessionTile(
          session: sessions[index],
          liveNames: liveNames,
        );
      },
    );
  }
}
