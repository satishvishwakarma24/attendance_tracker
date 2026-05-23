import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/utils/geofence_service.dart';
import '../../../core/utils/location_permission_helper.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../../location/providers/locations_provider.dart';
import '../models/attendance_state.dart';

class AttendanceNotifier extends Notifier<AttendanceState> {
  bool get _isSuperAdmin => ref.read(isSuperAdminProvider);

  @override
  AttendanceState build() {
    if (!_isSuperAdmin) {
      ref.listen(locationsStreamProvider, (prev, next) {
        if (next.hasValue && next.value!.isNotEmpty) {
          Future.microtask(refreshLocationStatus);
        }
      });
      Future.microtask(refreshLocationStatus);
    }
    return const AttendanceState();
  }

  AttendanceRepository get _attendanceRepo =>
      ref.read(attendanceRepositoryProvider);

  SessionRepository get _sessionRepo => ref.read(sessionRepositoryProvider);

  Future<void> refreshLocationStatus() async {
    if (_isSuperAdmin) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final latest = await _attendanceRepo.getLatestForUser(user.uid);
          if (latest != null) {
            state = state.copyWith(
              isPunchedIn: latest.isPunchIn,
              lastPunchTime: latest.timestamp,
            );
          }
        } on FirebaseException catch (e) {
          if (e.code == 'failed-precondition') {
            Logger.warning(
              'Firestore index missing for attendance query; deploy '
              'firestore.indexes.json',
            );
          } else {
            rethrow;
          }
        }
      }

      final locations = ref.read(locationsStreamProvider).value ?? [];
      if (locations.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          isInsideGeofence: false,
          clearMatchedOffice: true,
          errorMessage: 'No office locations configured yet.',
        );
        return;
      }

      final access = await LocationPermissionHelper.ensureWhileInUse();
      if (access != LocationAccess.granted) {
        state = state.copyWith(
          isLoading: false,
          isInsideGeofence: false,
          needsLocationPermission: true,
          errorMessage: LocationPermissionHelper.messageFor(access),
        );
        return;
      }
      state = state.copyWith(needsLocationPermission: false);

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final inside = GeofenceService.findInsideOffice(
        userLat: position.latitude,
        userLng: position.longitude,
        offices: locations,
      );
      final nearest = GeofenceService.findNearest(
        userLat: position.latitude,
        userLng: position.longitude,
        offices: locations,
      );

      state = state.copyWith(
        isLoading: false,
        isInsideGeofence: inside != null,
        matchedOffice: inside?.location,
        nearestOffice: nearest?.location,
        distanceMeters: inside?.distanceMeters ?? nearest?.distanceMeters,
        clearError: true,
      );
    } catch (e, s) {
      Logger.error('Failed to refresh location status', e, s);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not read your location. Try again.',
      );
    }
  }

  Future<void> punch() async {
    if (_isSuperAdmin) {
      state = state.copyWith(
        errorMessage: 'Super admins manage locations and attendance only.',
      );
      return;
    }

    if (state.isPunching) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(errorMessage: 'You must be signed in to punch.');
      return;
    }

    if (!state.isInsideGeofence || state.matchedOffice == null) {
      state = state.copyWith(
        errorMessage: 'Move inside an office geofence to punch.',
      );
      return;
    }

    final punchingOut = state.isPunchedIn;
    final punchInAt = state.lastPunchTime;
    final punchIn = !punchingOut;
    state = state.copyWith(isPunching: true, clearError: true);

    try {
      final access = await LocationPermissionHelper.ensureWhileInUse();
      if (access != LocationAccess.granted) {
        state = state.copyWith(
          isPunching: false,
          needsLocationPermission: true,
          errorMessage: LocationPermissionHelper.messageFor(access),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final office = state.matchedOffice!;
      final inside = GeofenceService.findInsideOffice(
        userLat: position.latitude,
        userLng: position.longitude,
        offices: [office],
      );

      if (inside == null) {
        state = state.copyWith(
          isPunching: false,
          errorMessage: 'You left the office zone. Punch cancelled.',
        );
        await refreshLocationStatus();
        return;
      }

      await _attendanceRepo.recordPunch(
        userId: user.uid,
        userEmail: user.email ?? '',
        locationId: office.id,
        locationName: office.name,
        punchIn: punchIn,
        lat: position.latitude,
        lng: position.longitude,
      );

      if (punchingOut) {
        final punchInRecord =
            await _attendanceRepo.getLatestPunchInForUser(user.uid);
        final sessionStart =
            punchInAt ?? punchInRecord?.timestamp;
        if (sessionStart != null) {
          await _sessionRepo.recordPunchOutSession(
            userId: user.uid,
            locationId: office.id,
            locationName: office.name,
            punchInAt: sessionStart,
            punchInAttendanceId: punchInRecord?.id,
          );
        } else {
          Logger.warning(
            'Punch out without punch-in time; session not saved',
          );
        }
      }

      state = state.copyWith(
        isPunching: false,
        isPunchedIn: punchIn,
        lastPunchTime: DateTime.now(),
        clearError: true,
      );
    } catch (e, s) {
      Logger.error('Punch failed', e, s);
      state = state.copyWith(
        isPunching: false,
        errorMessage: 'Punch failed. Check connection and try again.',
      );
    }
  }

  /// Called from dashboard after the user accepts the location rationale dialog.
  Future<void> requestLocationAccess() async {
    await refreshLocationStatus();
  }
}

final attendanceProvider =
    NotifierProvider<AttendanceNotifier, AttendanceState>(() {
  return AttendanceNotifier();
});
