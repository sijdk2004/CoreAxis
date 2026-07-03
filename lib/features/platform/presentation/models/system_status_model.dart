import 'package:flutter/material.dart';

enum ServiceStatus {
  healthy,
  degraded,
  down,
  maintenance,
}

class SystemServiceModel {
  final String id;
  final String name;
  final ServiceStatus status;
  final String description;
  final IconData icon;
  final String uptime;
  final String latency;

  const SystemServiceModel({
    required this.id,
    required this.name,
    required this.status,
    required this.description,
    required this.icon,
    required this.uptime,
    required this.latency,
  });
}

class SystemMetricsModel {
  final double cpuUsage;
  final double memoryUsage;
  final double activeConnections;
  final double requestRate;
  final double errorRate;

  const SystemMetricsModel({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.activeConnections,
    required this.requestRate,
    required this.errorRate,
  });
}

class ChartDataPoint {
  final DateTime timestamp;
  final double value;

  const ChartDataPoint(this.timestamp, this.value);
}
