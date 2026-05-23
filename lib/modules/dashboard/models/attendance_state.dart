import '../../../data/models/office_location_model.dart';

class AttendanceState {
  final bool isPunchedIn;
  final DateTime? lastPunchTime;
  final bool isInsideGeofence;
  final OfficeLocationModel? matchedOffice;
  final OfficeLocationModel? nearestOffice;
  final double? distanceMeters;
  final bool isLoading;
  final bool isPunching;
  final String? errorMessage;
  final bool needsLocationPermission;

  const AttendanceState({
    this.isPunchedIn = false,
    this.lastPunchTime,
    this.isInsideGeofence = false,
    this.matchedOffice,
    this.nearestOffice,
    this.distanceMeters,
    this.isLoading = true,
    this.isPunching = false,
    this.errorMessage,
    this.needsLocationPermission = false,
  });

  AttendanceState copyWith({
    bool? isPunchedIn,
    DateTime? lastPunchTime,
    bool? isInsideGeofence,
    OfficeLocationModel? matchedOffice,
    OfficeLocationModel? nearestOffice,
    double? distanceMeters,
    bool? isLoading,
    bool? isPunching,
    String? errorMessage,
    bool? needsLocationPermission,
    bool clearMatchedOffice = false,
    bool clearError = false,
  }) {
    return AttendanceState(
      isPunchedIn: isPunchedIn ?? this.isPunchedIn,
      lastPunchTime: lastPunchTime ?? this.lastPunchTime,
      isInsideGeofence: isInsideGeofence ?? this.isInsideGeofence,
      matchedOffice:
          clearMatchedOffice ? null : (matchedOffice ?? this.matchedOffice),
      nearestOffice: nearestOffice ?? this.nearestOffice,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isLoading: isLoading ?? this.isLoading,
      isPunching: isPunching ?? this.isPunching,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      needsLocationPermission:
          needsLocationPermission ?? this.needsLocationPermission,
    );
  }
}
