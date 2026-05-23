import 'package:attendance_tracker/config/constant/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../config/routes/routes_name.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/location_permission_helper.dart';
import '../../auth/providers/auth_providers.dart';
import '../../common/module_responsive.dart';
import '../../common/widgets/app_scaffold.dart';
import '../providers/attendance_provider.dart';
import 'widgets/dashboard_admin_section.dart';
import 'widgets/dashboard_geofence_status_card.dart';
import 'widgets/dashboard_punch_button.dart';
import 'widgets/dashboard_punch_status_card.dart';
import 'widgets/location_permission_banner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _locationPromptShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(isSuperAdminProvider)) return;
      _promptLocationAccess();
    });
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  Future<void> _promptLocationAccess() async {
    if (_locationPromptShown || !mounted) return;

    var access = await LocationPermissionHelper.checkStatus();
    if (access == LocationAccess.granted) {
      if (mounted) {
        ref.read(attendanceProvider.notifier).refreshLocationStatus();
      }
      return;
    }

    _locationPromptShown = true;
    if (!mounted) return;

    final openSettings = access == LocationAccess.permanentlyDenied ||
        access == LocationAccess.serviceDisabled;
    final text = context.textStyles;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Enable location', style: text.titleLarge),
        content: Text(
          openSettings
              ? LocationPermissionHelper.messageFor(access)
              : 'Attendance Tracker needs your location while you use the app '
                  'to verify you are inside an office geofence before punch in '
                  'or out.',
          style: text.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(openSettings ? 'Open Settings' : 'Allow location'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (accepted == true) {
      if (openSettings) {
        await openAppSettings();
      } else {
        access = await LocationPermissionHelper.requestWhileInUse();
      }
      if (mounted) {
        await ref.read(attendanceProvider.notifier).requestLocationAccess();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final attendance = ref.watch(attendanceProvider);
    final isPunchedIn = attendance.isPunchedIn;
    final profile = ref.watch(userProfileProvider).value;
    final isAdmin = ref.watch(isSuperAdminProvider);

    final displayName = profile?.displayName ??
        profile?.email.split('@').first ??
        'Team Member';

    Future<void> handlePunchAction() async {
      await ref.read(attendanceProvider.notifier).punch();
      final next = ref.read(attendanceProvider);
      if (!context.mounted) return;
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colors.error,
          ),
        );
      } else if (!next.isPunching) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.isPunchedIn
                  ? 'Punched in at ${next.matchedOffice?.name ?? 'office'}'
                  : 'Punched out successfully',
            ),
            backgroundColor: colors.primary,
          ),
        );
      }
    }

    final canPunch = attendance.isInsideGeofence &&
        !attendance.isLoading &&
        !attendance.isPunching;

    final zoneTitle = attendance.isInsideGeofence
        ? 'Inside Office Zone'
        : 'Outside Office Zone';
    final zoneSubtitle = attendance.isInsideGeofence
        ? attendance.matchedOffice?.name ?? 'Location verified'
        : attendance.nearestOffice != null
            ? '${attendance.nearestOffice!.name} · '
                '${(attendance.distanceMeters ?? 0).toStringAsFixed(0)}m away'
            : 'No nearby office found';

    final lastPunchLabel = attendance.lastPunchTime != null
        ? 'Last punch ${_formatTime(attendance.lastPunchTime!)}'
        : 'No punch recorded today';

    return AppScaffold(
      title: AppConfig.appName,
      currentRoute: RoutesName.dashboard,
      body: RefreshIndicator(
        onRefresh: isAdmin
            ? () async {}
            : () =>
                ref.read(attendanceProvider.notifier).refreshLocationStatus(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: ModuleResponsive.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $displayName',
                style: text.headlineMedium?.copyWith(fontSize: 28.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                isAdmin
                    ? 'Manage office geofences and attendance records.'
                    : 'Ready for a productive day?',
                style: text.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 24.h),
              if (isAdmin)
                DashboardAdminSection(
                  onManageLocations: () => context.push(RoutesName.locations),
                  onViewAttendance: () =>
                      context.push(RoutesName.attendanceMonitor),
                )
              else ...[
                DashboardPunchStatusCard(
                  isPunchedIn: isPunchedIn,
                  lastPunchLabel: lastPunchLabel,
                ),
                SizedBox(height: 16.h),
                DashboardGeofenceStatusCard(
                  isInsideGeofence: attendance.isInsideGeofence,
                  isLoading: attendance.isLoading,
                  zoneTitle: zoneTitle,
                  zoneSubtitle: attendance.isLoading
                      ? 'Checking your location…'
                      : zoneSubtitle,
                  onRefresh: () => ref
                      .read(attendanceProvider.notifier)
                      .refreshLocationStatus(),
                ),
                if (attendance.needsLocationPermission) ...[
                  SizedBox(height: 12.h),
                  LocationPermissionBanner(
                    message: attendance.errorMessage ??
                        'Enable location while using the app to punch.',
                    onEnable: () async {
                      var access =
                          await LocationPermissionHelper.checkStatus();
                      if (access == LocationAccess.denied) {
                        access =
                            await LocationPermissionHelper.requestWhileInUse();
                      }
                      if (!context.mounted) return;
                      if (access == LocationAccess.permanentlyDenied ||
                          access == LocationAccess.serviceDisabled) {
                        await openAppSettings();
                      }
                      await ref
                          .read(attendanceProvider.notifier)
                          .refreshLocationStatus();
                    },
                  ),
                ] else if (attendance.errorMessage != null) ...[
                  SizedBox(height: 12.h),
                  Text(
                    attendance.errorMessage!,
                    style: text.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                      color: colors.error,
                    ),
                  ),
                ],
                SizedBox(height: 48.h),
                DashboardPunchButton(
                  isPunchedIn: isPunchedIn,
                  isPunching: attendance.isPunching,
                  canPunch: canPunch,
                  onPressed: canPunch ? handlePunchAction : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
