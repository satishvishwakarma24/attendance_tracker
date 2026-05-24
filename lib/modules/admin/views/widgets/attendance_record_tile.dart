import 'package:flutter/material.dart';

import '/core/theme/app_theme.dart';
import '/core/widgets/punch_session_times_bar.dart';
import '/modules/location/providers/locations_provider.dart';
import '../../../common/widgets/module_responsive.dart';
import 'admin_attendance_session.dart';

class AttendanceSessionTile extends StatelessWidget {
  const AttendanceSessionTile({
    super.key,
    required this.session,
    required this.liveNames,
  });

  final AdminAttendanceSession session;
  final Map<String, String> liveNames;

  String _formatDuration(Duration? duration) {
    if (duration == null) return '—';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    final punchInTime = session.punchIn?.timestamp;
    final punchOutTime = session.punchOut?.timestamp;
    final locationLabel = resolveLocationDisplayName(
      locationId: session.locationId,
      storedName: session.locationName,
      liveNames: liveNames,
      fallback: session.locationId,
    );
    final statusColor = session.isActive ? colors.punchIn : colors.primary;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    _initials(session.userEmail),
                    style: text.labelSmall?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.userEmail,
                        style: text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 14.sp,
                            color: colors.onSurfaceVariant,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              locationLabel,
                              style: text.bodySmall?.copyWith(
                                fontSize: 12.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _SessionStatusChip(
                  isActive: session.isActive,
                  durationLabel: session.isActive
                      ? 'Active'
                      : _formatDuration(session.duration),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            if (session.isActive)
              Padding(
                padding: EdgeInsets.only(left: 50.w),
                child: Text(
                  'Currently punched in',
                  style: text.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            SizedBox(height: 12.h),
            PunchSessionTimesBar(
              punchInAt: punchInTime,
              punchOutAt: punchOutTime,
              isActive: session.isActive,
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return '?';
    final parts = local.split(RegExp(r'[._-]')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase());
    final result = letters.join();
    return result.isEmpty ? local[0].toUpperCase() : result;
  }
}

class _SessionStatusChip extends StatelessWidget {
  const _SessionStatusChip({
    required this.isActive,
    required this.durationLabel,
  });

  final bool isActive;
  final String durationLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final bg = isActive ? colors.punchInContainer : colors.secondaryContainer;
    final fg = isActive ? colors.punchIn : colors.onSecondaryContainer;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Text(
        durationLabel,
        style: text.labelSmall?.copyWith(
          color: fg,
          fontSize: 11.sp,
          letterSpacing: 0.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
