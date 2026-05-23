import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '/config/routes/routes_name.dart';
import '/core/theme/app_theme.dart';
import '/data/models/user_session.dart';
import '/modules/common/module_responsive.dart';
import '/modules/common/providers/session_provider.dart';
import '/modules/common/widgets/app_scaffold.dart';

class UserHistoryScreen extends ConsumerWidget {
  const UserHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(userSessionsProvider);
    final text = context.textStyles;

    return AppScaffold(
      title: 'User History',
      currentRoute: RoutesName.userHistory,
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              'Could not load sessions: $e',
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Text(
                'No login sessions yet.',
                style: text.bodyMedium,
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
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final UserSession session;

  Duration? _effectiveDuration(UserSession session) {
    if (!session.isActive) return session.duration;
    if (session.loginAt == null) return null;
    return DateTime.now().difference(session.loginAt!);
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

    final loginLabel = session.loginAt != null
        ? dateFormat.format(session.loginAt!)
        : 'Login pending…';
    final logoutLabel = session.isActive
        ? 'Still signed in'
        : session.logoutAt != null
            ? dateFormat.format(session.logoutAt!)
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
                      ? Icons.play_circle_outline
                      : Icons.check_circle_outline,
                  color: session.isActive ? colors.primary : colors.tertiary,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  session.isActive ? 'Active session' : 'Completed',
                  style: text.labelLarge?.copyWith(
                    color: session.isActive ? colors.primary : null,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
            _RowLabel(label: 'Login', value: loginLabel, text: text),
            SizedBox(height: 6.h),
            _RowLabel(label: 'Logout', value: logoutLabel, text: text),
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
          width: 64.w,
          child: Text(label, style: text.bodySmall),
        ),
        Expanded(
          child: Text(value, style: text.bodyMedium),
        ),
      ],
    );
  }
}
