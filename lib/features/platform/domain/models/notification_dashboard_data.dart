class NotificationDashboardData {
  final Map<String, String> kpis;
  final List<ChartDataPoint> trendData;
  final List<CategoryDataPoint> channelDistribution;
  final List<CategoryDataPoint> successRate;
  final List<CategoryDataPoint> volumeByModule;
  final List<NotificationItem> recentNotifications;
  final List<NotificationItem> pendingQueue;
  final List<NotificationItem> failedDeliveries;
  final List<NotificationItem> upcomingScheduled;
  final List<CategoryDataPoint> topTemplates;

  NotificationDashboardData({
    required this.kpis,
    required this.trendData,
    required this.channelDistribution,
    required this.successRate,
    required this.volumeByModule,
    required this.recentNotifications,
    required this.pendingQueue,
    required this.failedDeliveries,
    required this.upcomingScheduled,
    required this.topTemplates,
  });
}

class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint(this.label, this.value);
}

class CategoryDataPoint {
  final String category;
  final double value;
  final String? colorHex;

  CategoryDataPoint(this.category, this.value, [this.colorHex]);
}

class NotificationItem {
  final String id;
  final String subject;
  final String recipient;
  final String channel;
  final String module;
  final String status;
  final DateTime timestamp;

  NotificationItem({
    required this.id,
    required this.subject,
    required this.recipient,
    required this.channel,
    required this.module,
    required this.status,
    required this.timestamp,
  });
}
