import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '/core/theme/app_theme.dart';
import '/data/models/user_session.dart';
import '../widgets/module_responsive.dart';
import '/modules/common/providers/session_provider.dart';

class UserHistoryScreen extends ConsumerWidget {
  const UserHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(userSessionsProvider);
    final text = context.textStyles;

    return sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              'Could not load punch history: $e',
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Text(
                'No punch sessions yet.\nPunch in and out to see your work duration.',
                style: text.bodyMedium,
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            padding: ModuleResponsive.screenPadding,
            itemCount: sessions.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              return _SessionTile(session: sessions[index]);
            },
          );
        },
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final UserSession session;

  Duration? _effectiveDuration(UserSession session) {
    if (!session.isActive) return session.duration;
    if (session.punchInAt == null) return null;
    return DateTime.now().difference(session.punchInAt!);
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'In progress';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final dateFormat = DateFormat('MMM d, yyyy · hh:mm a');

    final punchInLabel = session.punchInAt != null
        ? dateFormat.format(session.punchInAt!)
        : '—';
    final punchOutLabel = session.isActive
        ? 'Still punched in'
        : session.punchOutAt != null
            ? dateFormat.format(session.punchOutAt!)
            : '—';

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  session.isActive
                      ? Icons.login
                      : Icons.logout,
                  color: session.isActive ? colors.primary : colors.tertiary,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    session.locationName ?? 'Office',
                    style: text.labelLarge?.copyWith(
                      color: session.isActive ? colors.primary : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    _formatDuration(_effectiveDuration(session)),
                    style: text.labelSmall?.copyWith(
                      color: colors.onSecondaryContainer,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _RowLabel(label: 'Punch in', value: punchInLabel, text: text),
            SizedBox(height: 6.h),
            _RowLabel(label: 'Punch out', value: punchOutLabel, text: text),
          ],
        ),
      ),
    );
  }
}

class _RowLabel extends StatelessWidget {
  const _RowLabel({
    required this.label,
    required this.value,
    required this.text,
  });

  final String label;
  final String value;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72.w,
          child: Text(label, style: text.bodySmall),
        ),
        Expanded(
          child: Text(value, style: text.bodyMedium),
        ),
      ],
    );
  }
}
