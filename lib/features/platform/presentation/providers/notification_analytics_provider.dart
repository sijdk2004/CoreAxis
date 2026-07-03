import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_analytics_model.dart';
import 'dart:math';

class NotificationAnalyticsState {
  final AnalyticsKpis kpis;
  final List<AiRecommendation> recommendations;
  final List<TemplateUsageStat> topTemplates;
  final List<DailyTrend> dailyTrends;
  final Map<String, double> channelPerformance;
  final String dateRange;
  
  // mock 7 days x 24 hours heatmap data
  final List<List<double>> deliveryHeatmap;

  NotificationAnalyticsState({
    required this.kpis,
    required this.recommendations,
    required this.topTemplates,
    required this.dailyTrends,
    required this.channelPerformance,
    this.dateRange = 'Last 7 Days',
    required this.deliveryHeatmap,
  });

  NotificationAnalyticsState copyWith({
    AnalyticsKpis? kpis,
    List<AiRecommendation>? recommendations,
    List<TemplateUsageStat>? topTemplates,
    List<DailyTrend>? dailyTrends,
    Map<String, double>? channelPerformance,
    String? dateRange,
    List<List<double>>? deliveryHeatmap,
  }) {
    return NotificationAnalyticsState(
      kpis: kpis ?? this.kpis,
      recommendations: recommendations ?? this.recommendations,
      topTemplates: topTemplates ?? this.topTemplates,
      dailyTrends: dailyTrends ?? this.dailyTrends,
      channelPerformance: channelPerformance ?? this.channelPerformance,
      dateRange: dateRange ?? this.dateRange,
      deliveryHeatmap: deliveryHeatmap ?? this.deliveryHeatmap,
    );
  }
}

class NotificationAnalyticsNotifier extends Notifier<NotificationAnalyticsState> {
  @override
  NotificationAnalyticsState build() {
    return _generateMockData('Last 7 Days');
  }

  void setDateRange(String range) {
    state = _generateMockData(range);
  }

  NotificationAnalyticsState _generateMockData(String range) {
    final r = Random();
    
    // Generate heatmap 7x24
    final heatmap = List.generate(7, (day) => List.generate(24, (hour) {
      // higher activity during 9-17 hours
      if (hour >= 9 && hour <= 17) {
        return 0.5 + (r.nextDouble() * 0.5);
      }
      return r.nextDouble() * 0.3;
    }));

    final dailyTrends = List.generate(7, (index) {
      return DailyTrend(
        date: DateTime.now().subtract(Duration(days: 6 - index)),
        volume: 5000 + r.nextInt(10000),
        successRate: 0.90 + (r.nextDouble() * 0.09),
      );
    });

    return NotificationAnalyticsState(
      dateRange: range,
      kpis: AnalyticsKpis(
        deliverySuccessRate: 0.982,
        averageDeliveryTime: const Duration(milliseconds: 850),
        openRate: 0.65,
        clickRate: 0.12,
        failureRate: 0.018,
        retryRate: 0.045,
      ),
      recommendations: [
        AiRecommendation(
          title: 'Optimize Email Delivery Time',
          description: 'Sending marketing emails between 10:00 AM and 11:00 AM on Tuesdays increases open rates by 12%.',
          impact: 'High',
        ),
        AiRecommendation(
          title: 'SMS Channel Fallback',
          description: 'Enable SMS fallback for critical push notifications to reduce failure rates.',
          impact: 'Medium',
        ),
        AiRecommendation(
          title: 'Template Refresh Needed',
          description: '"Welcome Series" template engagement has dropped 5% this month.',
          impact: 'Low',
        ),
      ],
      topTemplates: [
        TemplateUsageStat(name: 'Invoice Generated', count: 12500, openRate: 0.85),
        TemplateUsageStat(name: 'Password Reset', count: 8300, openRate: 0.95),
        TemplateUsageStat(name: 'Weekly Digest', count: 4200, openRate: 0.45),
        TemplateUsageStat(name: 'Marketing Promo', count: 15000, openRate: 0.22),
      ],
      dailyTrends: dailyTrends,
      channelPerformance: {
        'Email': 55.0,
        'Push': 25.0,
        'SMS': 15.0,
        'In-App': 5.0,
      },
      deliveryHeatmap: heatmap,
    );
  }
}

final notificationAnalyticsProvider = NotifierProvider<NotificationAnalyticsNotifier, NotificationAnalyticsState>(() {
  return NotificationAnalyticsNotifier();
});
