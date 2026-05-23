import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/theme/app_theme.dart';
import '/modules/admin/views/widgets/attendance_records_list.dart';
import '../../common/widgets/module_responsive.dart';
import '/modules/common/widgets/app_scaffold.dart';
import '../providers/attendance_monitor_provider.dart';

class AttendanceMonitorScreen extends ConsumerWidget {
  const AttendanceMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(attendanceMonitorProvider);
    final text = context.textStyles;

    return AppScaffold(
      title: 'Attendance Log',
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              'Could not load attendance: $e',
              style: text.bodyMedium?.copyWith(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (records) => AttendanceRecordsList(records: records),
      ),
    );
  }
}
