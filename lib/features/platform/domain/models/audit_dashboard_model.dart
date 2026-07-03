import 'package:flutter/foundation.dart';

class AuditDashboardModel {
  final Map<String, String> kpis;
  final List<ChartDataPoint> auditEventsTrend;
  final List<ChartDataPoint> eventsByModule;
  final List<PieChartDataPoint> securityEvents;
  final List<ChartDataPoint> userActivityTrend;
  
  final List<AuditLogItem> recentAuditEvents;
  final List<AuditLogItem> criticalEvents;
  final List<ActiveUserItem> mostActiveUsers;
  final List<LoginItem> recentLogins;
  final List<ModuleActivityItem> moduleActivity;

  const AuditDashboardModel({
    required this.kpis,
    required this.auditEventsTrend,
    required this.eventsByModule,
    required this.securityEvents,
    required this.userActivityTrend,
    required this.recentAuditEvents,
    required this.criticalEvents,
    required this.mostActiveUsers,
    required this.recentLogins,
    required this.moduleActivity,
  });
}

class ChartDataPoint {
  final String label;
  final double value;
  const ChartDataPoint(this.label, this.value);
}

class PieChartDataPoint {
  final String category;
  final double percentage;
  const PieChartDataPoint(this.category, this.percentage);
}

class AuditLogItem {
  final String id;
  final String action;
  final String user;
  final String module;
  final String timestamp;
  final String severity; // 'info', 'warning', 'critical'
  const AuditLogItem(this.id, this.action, this.user, this.module, this.timestamp, this.severity);
}

class ActiveUserItem {
  final String username;
  final String role;
  final String eventCount;
  const ActiveUserItem(this.username, this.role, this.eventCount);
}

class LoginItem {
  final String username;
  final String status;
  final String ipAddress;
  final String timestamp;
  const LoginItem(this.username, this.status, this.ipAddress, this.timestamp);
}

class ModuleActivityItem {
  final String module;
  final String eventCount;
  final String trend; // e.g., '+12%'
  const ModuleActivityItem(this.module, this.eventCount, this.trend);
}

// Mock Data Generator
AuditDashboardModel generateMockAuditDashboard() {
  return AuditDashboardModel(
    kpis: {
      'Total Audit Events': '245.8K',
      'Today\'s Events': '1,245',
      'Security Events': '42',
      'Failed Login Attempts': '18',
      'Data Changes': '854',
      'Workflow Activities': '124',
      'Approval Activities': '56',
      'Document Activities': '890',
    },
    auditEventsTrend: [
      const ChartDataPoint('Mon', 1200),
      const ChartDataPoint('Tue', 1500),
      const ChartDataPoint('Wed', 1100),
      const ChartDataPoint('Thu', 2100),
      const ChartDataPoint('Fri', 1900),
      const ChartDataPoint('Sat', 800),
      const ChartDataPoint('Sun', 650),
    ],
    eventsByModule: [
      const ChartDataPoint('Documents', 890),
      const ChartDataPoint('Workflows', 124),
      const ChartDataPoint('Users', 450),
      const ChartDataPoint('Settings', 85),
      const ChartDataPoint('RBAC', 110),
    ],
    securityEvents: [
      const PieChartDataPoint('Failed Logins', 45),
      const PieChartDataPoint('Role Changes', 25),
      const PieChartDataPoint('Data Exports', 20),
      const PieChartDataPoint('Other', 10),
    ],
    userActivityTrend: [
      const ChartDataPoint('00:00', 120),
      const ChartDataPoint('04:00', 80),
      const ChartDataPoint('08:00', 800),
      const ChartDataPoint('12:00', 1400),
      const ChartDataPoint('16:00', 1100),
      const ChartDataPoint('20:00', 400),
    ],
    recentAuditEvents: [
      const AuditLogItem('EVT-101', 'Updated Document Permissions', 'john.doe', 'Documents', '2 mins ago', 'info'),
      const AuditLogItem('EVT-102', 'Approved Workflow W-992', 'jane.smith', 'Approvals', '5 mins ago', 'info'),
      const AuditLogItem('EVT-103', 'Deleted User Account', 'admin.sys', 'Users', '12 mins ago', 'warning'),
      const AuditLogItem('EVT-104', 'Exported All Organization Data', 'sarah.c', 'Organizations', '18 mins ago', 'warning'),
      const AuditLogItem('EVT-105', 'Created New Tenant', 'admin.sys', 'Tenants', '22 mins ago', 'info'),
    ],
    criticalEvents: [
      const AuditLogItem('SEC-901', 'Multiple Failed Logins', 'unknown', 'Auth', '1 hour ago', 'critical'),
      const AuditLogItem('SEC-902', 'Privilege Escalation Attempt', 'guest.user', 'RBAC', '3 hours ago', 'critical'),
      const AuditLogItem('SEC-903', 'Mass Data Deletion', 'mark.b', 'Documents', '1 day ago', 'critical'),
    ],
    mostActiveUsers: [
      const ActiveUserItem('john.doe', 'Manager', '342 events'),
      const ActiveUserItem('sarah.c', 'Admin', '289 events'),
      const ActiveUserItem('mike.t', 'Analyst', '198 events'),
      const ActiveUserItem('jane.smith', 'Director', '156 events'),
    ],
    recentLogins: [
      const LoginItem('john.doe', 'Success', '192.168.1.45', '10 mins ago'),
      const LoginItem('unknown', 'Failed', '203.0.113.42', '1 hour ago'),
      const LoginItem('sarah.c', 'Success', '10.0.0.12', '2 hours ago'),
      const LoginItem('mike.t', 'Success', '192.168.1.104', '3 hours ago'),
    ],
    moduleActivity: [
      const ModuleActivityItem('Documents', '890 events', '+12%'),
      const ModuleActivityItem('Users', '450 events', '-5%'),
      const ModuleActivityItem('Workflows', '124 events', '+2%'),
      const ModuleActivityItem('RBAC', '110 events', '+18%'),
    ],
  );
}
