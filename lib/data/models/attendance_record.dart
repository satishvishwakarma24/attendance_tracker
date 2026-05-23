class AttendanceRecord {
  final String id;
  final String userId;
  final String? userEmail;
  final String locationId;
  final String? locationName;
  final String type;
  final DateTime? timestamp;
  final double? lat;
  final double? lng;

  const AttendanceRecord({
    required this.id,
    required this.userId,
    this.userEmail,
    required this.locationId,
    this.locationName,
    required this.type,
    this.timestamp,
    this.lat,
    this.lng,
  });

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceRecord(
      id: id,
      userId: map['userId'] as String? ?? '',
      userEmail: map['userEmail'] as String?,
      locationId: map['locationId'] as String? ?? '',
      locationName: map['locationName'] as String?,
      type: map['type'] as String? ?? '',
      timestamp: (map['timestamp'] as dynamic)?.toDate() as DateTime?,
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
    );
  }

  bool get isPunchIn => type == 'in';
}
