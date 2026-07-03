import 'package:flutter/foundation.dart';

@immutable
class KpiMetric {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;

  const KpiMetric({
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositive,
  });
}

@immutable
class PlatformHomeModel {
  final String currentUser;
  final String currentTenant;
  final String platformHealthStatus; // e.g. "Operational", "Degraded"
  final List<KpiMetric> kpis;
  final List<String> recentActivities;
  final List<String> favoriteModules;
  final List<String> announcements;
  final String systemVersion;

  const PlatformHomeModel({
    required this.currentUser,
    required this.currentTenant,
    required this.platformHealthStatus,
    required this.kpis,
    required this.recentActivities,
    required this.favoriteModules,
    required this.announcements,
    required this.systemVersion,
  });

  PlatformHomeModel copyWith({
    String? currentUser,
    String? currentTenant,
    String? platformHealthStatus,
    List<KpiMetric>? kpis,
    List<String>? recentActivities,
    List<String>? favoriteModules,
    List<String>? announcements,
    String? systemVersion,
  }) {
    return PlatformHomeModel(
      currentUser: currentUser ?? this.currentUser,
      currentTenant: currentTenant ?? this.currentTenant,
      platformHealthStatus: platformHealthStatus ?? this.platformHealthStatus,
      kpis: kpis ?? this.kpis,
      recentActivities: recentActivities ?? this.recentActivities,
      favoriteModules: favoriteModules ?? this.favoriteModules,
      announcements: announcements ?? this.announcements,
      systemVersion: systemVersion ?? this.systemVersion,
    );
  }
}
