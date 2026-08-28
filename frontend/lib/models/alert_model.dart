import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum AlertSeverity {
  info,
  warning,
  severe,
  extreme,
}

extension AlertSeverityExtension on AlertSeverity {
  Color get color {
    switch (this) {
      case AlertSeverity.info:
        return AppColors.alertWatch;
      case AlertSeverity.warning:
        return AppColors.alertWarning;
      case AlertSeverity.severe:
      case AlertSeverity.extreme:
        return AppColors.alertSevere;
    }
  }

  String get label {
    switch (this) {
      case AlertSeverity.info:
        return 'YELLOW WATCH';
      case AlertSeverity.warning:
        return 'ORANGE WARNING';
      case AlertSeverity.severe:
        return 'RED SEVERE ALERT';
      case AlertSeverity.extreme:
        return 'EXTREME EMERGENCY';
    }
  }
}

class SevereAlert {
  final String id;
  final String headline;
  final String description;
  final AlertSeverity severity;
  final String category;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final List<String> affectedAreas;
  final String? instructions;
  final String source;

  SevereAlert({
    required this.id,
    required this.headline,
    required this.description,
    required this.severity,
    required this.category,
    required this.issuedAt,
    this.expiresAt,
    this.affectedAreas = const [],
    this.instructions,
    this.source = 'India Meteorological Department',
  });

  factory SevereAlert.fromJson(Map<String, dynamic> json) {
    AlertSeverity parseSeverity(String? sev) {
      switch (sev?.toLowerCase()) {
        case 'info':
          return AlertSeverity.info;
        case 'warning':
          return AlertSeverity.warning;
        case 'severe':
          return AlertSeverity.severe;
        case 'extreme':
          return AlertSeverity.extreme;
        default:
          return AlertSeverity.warning;
      }
    }

    return SevereAlert(
      id: json['id'] ?? '',
      headline: json['headline'] ?? 'Weather Alert',
      description: json['description'] ?? '',
      severity: parseSeverity(json['severity']),
      category: json['category'] ?? 'General Advisory',
      issuedAt: DateTime.tryParse(json['issued_at'] ?? '') ?? DateTime.now(),
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at']) : null,
      affectedAreas: (json['affected_areas'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      instructions: json['instructions'],
      source: json['source'] ?? 'India Meteorological Department (IMD)',
    );
  }
}
