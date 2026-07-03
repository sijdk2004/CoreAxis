import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_dashboard_data.dart';
import 'dart:math';

enum DashboardState { loading, loaded, error, empty }

class NotificationDashboardState {
  final NotificationDashboardData? data;
  final DashboardState status;
  final String timeFilter;
  final String channelFilter;
  final String priorityFilter;
  final String moduleFilter;

  NotificationDashboardState({
    this.data,
    this.status = DashboardState.loading,
    this.timeFilter = 'Today',
    this.channelFilter = 'All',
    this.priorityFilter = 'All',
    this.moduleFilter = 'All',
  });

  NotificationDashboardState copyWith({
    NotificationDashboardData? data,
    DashboardState? status,
    String? timeFilter,
    String? channelFilter,
    String? priorityFilter,
    String? moduleFilter,
  }) {
    return NotificationDashboardState(
      data: data ?? this.data,
      status: status ?? this.status,
      timeFilter: timeFilter ?? this.timeFilter,
      channelFilter: channelFilter ?? this.channelFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      moduleFilter: moduleFilter ?? this.moduleFilter,
    );
  }
}

class NotificationDashboardNotifier extends Notifier<NotificationDashboardState> {
  @override
  NotificationDashboardState build() {
    Future.microtask(() => _loadData());
    return NotificationDashboardState();
  }

  Future<void> _loadData() async {
    state = state.copyWith(status: DashboardState.loading);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Simulate error state randomly (1 in 10 chance for realism, but we'll disable it for demo unless explicitly requested. Let's just load it reliably.)
    try {
      final mockData = _generateMockData(
        state.timeFilter, 
        state.channelFilter, 
        state.priorityFilter, 
        state.moduleFilter
      );
      
      // Empty state condition (e.g. if everything is filtered out)
      if (mockData.recentNotifications.isEmpty && mockData.pendingQueue.isEmpty) {
        state = state.copyWith(data: mockData, status: DashboardState.empty);
      } else {
        state = state.copyWith(data: mockData, status: DashboardState.loaded);
      }
    } catch (e) {
      state = state.copyWith(status: DashboardState.error);
    }
  }

  void updateFilters({
    String? timeFilter,
    String? channelFilter,
    String? priorityFilter,
    String? moduleFilter,
  }) {
    state = state.copyWith(
      timeFilter: timeFilter ?? state.timeFilter,
      channelFilter: channelFilter ?? state.channelFilter,
      priorityFilter: priorityFilter ?? state.priorityFilter,
      moduleFilter: moduleFilter ?? state.moduleFilter,
    );
    _loadData();
  }

  void retryFailed(String id) {
    if (state.data == null) return;
    
    // Mock retry: remove from failed, add to pending
    final failedItem = state.data!.failedDeliveries.firstWhere((e) => e.id == id);
    final newFailed = state.data!.failedDeliveries.where((e) => e.id != id).toList();
    final newPending = [
      NotificationItem(
        id: failedItem.id,
        subject: failedItem.subject,
        recipient: failedItem.recipient,
        channel: failedItem.channel,
        module: failedItem.module,
        status: 'Pending (Retry)',
        timestamp: DateTime.now(),
      ),
      ...state.data!.pendingQueue,
    ];

    state = state.copyWith(
      data: NotificationDashboardData(
        kpis: state.data!.kpis,
        trendData: state.data!.trendData,
        channelDistribution: state.data!.channelDistribution,
        successRate: state.data!.successRate,
        volumeByModule: state.data!.volumeByModule,
        recentNotifications: state.data!.recentNotifications,
        pendingQueue: newPending,
        failedDeliveries: newFailed,
        upcomingScheduled: state.data!.upcomingScheduled,
        topTemplates: state.data!.topTemplates,
      ),
    );
  }

  NotificationDashboardData _generateMockData(String time, String channel, String priority, String module) {
    final rand = Random();
    
    // Base multiplier based on time filter
    double timeMultiplier = 1.0;
    if (time == 'This Week') timeMultiplier = 7.0;
    if (time == 'This Month') timeMultiplier = 30.0;

    // Further adjust based on module/channel filters
    if (channel != 'All') timeMultiplier *= 0.4;
    if (module != 'All') timeMultiplier *= 0.3;
    if (priority == 'High') timeMultiplier *= 0.2;

    int totalSent = (15240 * timeMultiplier).toInt();
    int pending = (342 * (timeMultiplier > 1 ? timeMultiplier / 3 : 1)).toInt();
    int failed = (128 * timeMultiplier).toInt();
    double successRateVal = 99.1 - (rand.nextDouble() * 0.5);

    int emailSent = (totalSent * 0.6).toInt();
    int smsSent = (totalSent * 0.2).toInt();
    int whatsappSent = (totalSent * 0.15).toInt();
    int pushSent = totalSent - emailSent - smsSent - whatsappSent;

    List<ChartDataPoint> trendData = [];
    if (time == 'Today') {
      for (int i = 0; i < 24; i += 2) {
        trendData.add(ChartDataPoint('$i:00', rand.nextDouble() * 1000));
      }
    } else if (time == 'This Week') {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (var d in days) trendData.add(ChartDataPoint(d, rand.nextDouble() * 5000));
    } else {
      for (int i = 1; i <= 30; i += 3) trendData.add(ChartDataPoint('Day $i', rand.nextDouble() * 5000));
    }

    return NotificationDashboardData(
      kpis: {
        'Notifications Sent': '$totalSent',
        'Pending Notifications': '$pending',
        'Failed Deliveries': '$failed',
        'Delivery Success Rate': '${successRateVal.toStringAsFixed(2)}%',
        'Email Sent': '$emailSent',
        'SMS Sent': '$smsSent',
        'WhatsApp Sent': '$whatsappSent',
        'Push Sent': '$pushSent',
      },
      trendData: trendData,
      channelDistribution: [
        CategoryDataPoint('Email', emailSent.toDouble(), '#2196F3'),
        CategoryDataPoint('SMS', smsSent.toDouble(), '#4CAF50'),
        CategoryDataPoint('WhatsApp', whatsappSent.toDouble(), '#25D366'),
        CategoryDataPoint('Push', pushSent.toDouble(), '#9C27B0'),
      ],
      successRate: [
        CategoryDataPoint('Delivered', successRateVal, '#4CAF50'),
        CategoryDataPoint('Failed/Bounced', 100 - successRateVal, '#F44336'),
      ],
      volumeByModule: [
        CategoryDataPoint('Approvals', 4500 * timeMultiplier),
        CategoryDataPoint('Sales', 3200 * timeMultiplier),
        CategoryDataPoint('HR', 2800 * timeMultiplier),
        CategoryDataPoint('Finance', 2100 * timeMultiplier),
        CategoryDataPoint('Inventory', 1500 * timeMultiplier),
      ],
      recentNotifications: List.generate(5, (index) => NotificationItem(
        id: 'NOT-${1000 + index}',
        subject: 'PO-2023-${rand.nextInt(9000)+1000} Approval Required',
        recipient: 'john.doe@example.com',
        channel: 'Email',
        module: 'Approvals',
        status: 'Delivered',
        timestamp: DateTime.now().subtract(Duration(minutes: rand.nextInt(60))),
      )),
      pendingQueue: List.generate(4, (index) => NotificationItem(
        id: 'NOT-${2000 + index}',
        subject: 'System Maintenance Alert',
        recipient: '+1234567890',
        channel: 'SMS',
        module: 'System',
        status: 'Pending',
        timestamp: DateTime.now().subtract(Duration(minutes: rand.nextInt(10))),
      )),
      failedDeliveries: List.generate(3, (index) => NotificationItem(
        id: 'NOT-${3000 + index}',
        subject: 'Invoice Overdue Reminder',
        recipient: 'invalid_email@domain.com',
        channel: 'Email',
        module: 'Finance',
        status: 'Bounced',
        timestamp: DateTime.now().subtract(Duration(hours: rand.nextInt(24))),
      )),
      upcomingScheduled: List.generate(4, (index) => NotificationItem(
        id: 'NOT-${4000 + index}',
        subject: 'Weekly Team Sync',
        recipient: 'engineering_team',
        channel: 'Push',
        module: 'HR',
        status: 'Scheduled',
        timestamp: DateTime.now().add(Duration(hours: 1 + rand.nextInt(48))),
      )),
      topTemplates: [
        CategoryDataPoint('Approval Request Standard', 4500 * timeMultiplier),
        CategoryDataPoint('Password Reset', 3200 * timeMultiplier),
        CategoryDataPoint('Daily Digest', 2800 * timeMultiplier),
        CategoryDataPoint('Invoice Due', 2100 * timeMultiplier),
        CategoryDataPoint('Welcome Email', 1500 * timeMultiplier),
      ],
    );
  }
}

final notificationDashboardProvider = NotifierProvider<NotificationDashboardNotifier, NotificationDashboardState>(() {
  return NotificationDashboardNotifier();
});
