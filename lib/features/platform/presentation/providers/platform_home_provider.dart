import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/platform_home_model.dart';

class PlatformHomeNotifier extends Notifier<PlatformHomeModel> {
  @override
  PlatformHomeModel build() {
    return const PlatformHomeModel(
      currentUser: 'System Admin',
      currentTenant: 'Global Operations',
      platformHealthStatus: 'All Systems Operational',
      systemVersion: 'v2.4.1-enterprise',
      kpis: [
        KpiMetric(title: 'Organizations', value: '42', trend: '+3 this month', isPositive: true),
        KpiMetric(title: 'Users', value: '1,248', trend: '+12% active', isPositive: true),
        KpiMetric(title: 'Active Workflows', value: '856', trend: 'Optimal', isPositive: true),
        KpiMetric(title: 'Documents', value: '24.5k', trend: '+2k new', isPositive: true),
        KpiMetric(title: 'Reports Generated', value: '3,102', trend: '+15%', isPositive: true),
        KpiMetric(title: 'AI Usage', value: '8.2M tokens', trend: 'Under limit', isPositive: true),
        KpiMetric(title: 'Storage', value: '4.2 TB', trend: '68% capacity', isPositive: false),
        KpiMetric(title: 'Notifications', value: '124', trend: 'Pending', isPositive: false),
      ],
      recentActivities: [
        'New Tenant "Acme Corp" provisioned successfully.',
        'Workflow "Invoice Approval" updated by Jane Doe.',
        'System backup completed at 02:00 AM UTC.',
        'AI Model "GPT-4 Turbo" selected as default for all tenants.',
      ],
      favoriteModules: [
        'User Management',
        'AI Assistant',
        'Workflow Designer',
        'Audit Logs',
      ],
      announcements: [
        'Scheduled Maintenance: Platform will be unavailable on Sunday 2AM-4AM.',
        'New Feature: AI Report Generator is now in public beta.',
      ],
    );
  }
}

final platformHomeProvider = NotifierProvider<PlatformHomeNotifier, PlatformHomeModel>(() {
  return PlatformHomeNotifier();
});
