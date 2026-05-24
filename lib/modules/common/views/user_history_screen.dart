import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/theme/app_theme.dart';
import '/core/widgets/punch_session_times_bar.dart';
import '/data/models/user_session.dart';
import '../widgets/module_responsive.dart';
import '/modules/common/providers/session_provider.dart';
import '/modules/location/providers/locations_provider.dart';

class UserHistoryScreen extends ConsumerWidget {
  const UserHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(userSessionsProvider);
    final liveNames = ref.watch(locationNameMapProvider).value ?? {};
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
              return _SessionTile(
                session: sessions[index],
                liveNames: liveNames,
              );
            },
          );
        },
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.liveNames,
  });

  final UserSession session;
  final Map<String, String> liveNames;

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
    final durationAccent =
        session.isActive ? colors.punchIn : colors.primary;
    final locationLabel = resolveLocationDisplayName(
      locationId: session.locationId,
      storedName: session.locationName,
      liveNames: liveNames,
    );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: durationAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    session.isActive
                        ? Icons.login_rounded
                        : Icons.work_history_outlined,
                    color: durationAccent,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    locationLabel,
                    style: text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    _formatDuration(_effectiveDuration(session)),
                    style: text.labelSmall?.copyWith(
                      color: colors.onPrimaryContainer,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            PunchSessionTimesBar(
              punchInAt: session.punchInAt,
              punchOutAt: session.punchOutAt,
              isActive: session.isActive,
            ),
          ],
        ),
      ),
    );
  }
}
