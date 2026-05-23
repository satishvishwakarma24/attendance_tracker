import 'package:flutter/material.dart';

class OfficeLocationModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool isActive;
  final String? createdBy;
  final DateTime? createdAt;

  const OfficeLocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.isActive = true,
    this.createdBy,
    this.createdAt,
  });

  factory OfficeLocationModel.fromMap(String id, Map<String, dynamic> map) {
    return OfficeLocationModel(
      id: id,
      name: map['name'] as String? ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      radiusMeters: (map['radiusMeters'] as num?)?.toDouble() ?? 100,
      isActive: map['isActive'] as bool? ?? true,
      createdBy: map['createdBy'] as String?,
      createdAt: (map['createdAt'] as dynamic)?.toDate() as DateTime?,
    );
  }

  Map<String, dynamic> toMap({required String createdBy}) {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  String get coordinatesLabel {
    final latSuffix = latitude >= 0 ? 'N' : 'S';
    final lngSuffix = longitude >= 0 ? 'E' : 'W';
    return '${latitude.abs().toStringAsFixed(4)}° $latSuffix, '
        '${longitude.abs().toStringAsFixed(4)}° $lngSuffix';
  }

  IconData get listIcon => Icons.location_on;
}
