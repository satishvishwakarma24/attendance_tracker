import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/theme/app_theme.dart';
import '/modules/common/widgets/module_responsive.dart';

/// Shared date with punch in/out times on a single row.
class PunchSessionTimesBar extends StatelessWidget {
  const PunchSessionTimesBar({
    super.key,
    this.punchInAt,
    this.punchOutAt,
    this.isActive = false,
  });

  final DateTime? punchInAt;
  final DateTime? punchOutAt;
  final bool isActive;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm:ss');

  DateTime? get _sessionDate => punchInAt ?? punchOutAt;

  String _formatTime(DateTime? time) {
    if (time == null) return '—';
    return _timeFormat.format(time);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final dateLabel =
        _sessionDate != null ? _dateFormat.format(_sessionDate!) : '—';
    final outLabel = isActive ? 'Active' : _formatTime(punchOutAt);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLabel,
            style: text.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 11.sp,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _PunchTimeCell(
                  isPunchIn: true,
                  time: _formatTime(punchInAt),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _PunchTimeCell(
                  isPunchIn: false,
                  time: outLabel,
                  muted: isActive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PunchTimeCell extends StatelessWidget {
  const _PunchTimeCell({
    required this.isPunchIn,
    required this.time,
    this.muted = false,
  });

  final bool isPunchIn;
  final String time;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final accent = isPunchIn ? colors.punchIn : colors.punchOut;
    final fill =
        isPunchIn ? colors.punchInContainer : colors.punchOutContainer;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(
            isPunchIn ? Icons.login_rounded : Icons.logout_rounded,
            size: 16.sp,
            color: accent,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPunchIn ? 'IN' : 'OUT',
                  style: text.labelSmall?.copyWith(
                    color: accent,
                    fontSize: 9.sp,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  time,
                  style: text.bodyMedium?.copyWith(
                    color: muted ? colors.onSurfaceVariant : colors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
