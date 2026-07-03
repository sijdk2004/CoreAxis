import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/security_events_audit_model.dart';

final securityEventsAuditProvider = AsyncNotifierProvider<SecurityEventsAuditNotifier, SecurityEventsAuditModel>(() {
  return SecurityEventsAuditNotifier();
});

class SecurityEventsAuditNotifier extends AsyncNotifier<SecurityEventsAuditModel> {
  @override
  FutureOr<SecurityEventsAuditModel> build() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return _generateMockData();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 800));
      return _generateMockData();
    });
  }

  SecurityEventsAuditModel _generateMockData() {
    return SecurityEventsAuditModel(
      successfulLogins: 5432,
      failedLogins: 124,
      lockedAccounts: 7,
      passwordChanges: 89,
      mfaEvents: 3450,
      activeSessions: 412,
      loginTrend: const [
        ChartDataPoint('08:00', 50),
        ChartDataPoint('10:00', 450),
        ChartDataPoint('12:00', 300),
        ChartDataPoint('14:00', 600),
        ChartDataPoint('16:00', 200),
        ChartDataPoint('18:00', 80),
      ],
      failedLoginTrend: const [
        ChartDataPoint('08:00', 5),
        ChartDataPoint('10:00', 12),
        ChartDataPoint('12:00', 8),
        ChartDataPoint('14:00', 15),
        ChartDataPoint('16:00', 3),
        ChartDataPoint('18:00', 2),
      ],
      riskDistribution: const [
        CategoryDataPoint('Low', 85, '#10b981'), // green
        CategoryDataPoint('Medium', 10, '#f59e0b'), // amber
        CategoryDataPoint('High', 4, '#f97316'), // orange
        CategoryDataPoint('Critical', 1, '#ef4444'), // red
      ],
      suspiciousActivities: const [
        SuspiciousActivity(
          title: 'Multiple Failed Logins',
          description: '5 failed login attempts for user admin.sys from IP 192.168.1.50',
          timeAgo: '10 mins ago',
          severity: 'High',
        ),
        SuspiciousActivity(
          title: 'Unusual Login Location',
          description: 'Login from new country (Ukraine) for user john.doe',
          timeAgo: '1 hour ago',
          severity: 'Critical',
        ),
      ],
      recentSessions: const [
        RecentSession(user: 'jane.smith', ipAddress: '10.0.0.12', duration: '2h 15m', isActive: true),
        RecentSession(user: 'mike.t', ipAddress: '192.168.1.100', duration: '45m', isActive: true),
        RecentSession(user: 'sarah.c', ipAddress: '10.0.0.45', duration: '4h 30m', isActive: false),
      ],
      securityAlerts: const [
        SecurityAlert(message: 'MFA setup pending for 12 new users.', type: 'Warning'),
        SecurityAlert(message: 'System firewall rules updated successfully.', type: 'Info'),
        SecurityAlert(message: 'Database backup completed.', type: 'Info'),
      ],
      tableRows: const [
        SecurityEventRow(
          timestamp: '2023-10-27 14:30:12',
          userId: 'USR-101',
          user: 'john.doe',
          ipAddress: '192.168.1.5',
          browser: 'Chrome 118.0',
          os: 'Windows 11',
          location: 'New York, US',
          device: 'Desktop',
          eventType: 'Login',
          result: 'Success',
          riskLevel: 'Low',
        ),
        SecurityEventRow(
          timestamp: '2023-10-27 14:15:00',
          userId: 'USR-106',
          user: 'admin.sys',
          ipAddress: '45.22.11.9',
          browser: 'Firefox 119.0',
          os: 'macOS 14.1',
          location: 'London, UK',
          device: 'Laptop',
          eventType: 'Login',
          result: 'Failure',
          riskLevel: 'High',
        ),
        SecurityEventRow(
          timestamp: '2023-10-27 13:45:22',
          userId: 'USR-102',
          user: 'jane.smith',
          ipAddress: '10.0.0.12',
          browser: 'Safari 17.0',
          os: 'iOS 17.1',
          location: 'San Francisco, US',
          device: 'Mobile',
          eventType: 'MFA Prompt',
          result: 'Success',
          riskLevel: 'Low',
        ),
        SecurityEventRow(
          timestamp: '2023-10-27 12:30:45',
          userId: 'USR-103',
          user: 'system.admin',
          ipAddress: '192.168.1.10',
          browser: 'Edge 118.0',
          os: 'Windows 10',
          location: 'Chicago, US',
          device: 'Desktop',
          eventType: 'Password Change',
          result: 'Success',
          riskLevel: 'Medium',
        ),
        SecurityEventRow(
          timestamp: '2023-10-27 11:05:10',
          userId: 'USR-104',
          user: 'sarah.c',
          ipAddress: 'Unknown',
          browser: 'Unknown',
          os: 'Linux',
          location: 'Kyiv, UA',
          device: 'Server',
          eventType: 'API Access',
          result: 'Blocked',
          riskLevel: 'Critical',
        ),
      ],
    );
  }
}
