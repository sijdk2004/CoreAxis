class AnalyticsKpis {
  final double deliverySuccessRate;
  final Duration averageDeliveryTime;
  final double openRate;
  final double clickRate;
  final double failureRate;
  final double retryRate;

  AnalyticsKpis({
    required this.deliverySuccessRate,
    required this.averageDeliveryTime,
    required this.openRate,
    required this.clickRate,
    required this.failureRate,
    required this.retryRate,
  });
}

class AiRecommendation {
  final String title;
  final String description;
  final String impact;

  AiRecommendation({
    required this.title,
    required this.description,
    required this.impact,
  });
}

class TemplateUsageStat {
  final String name;
  final int count;
  final double openRate;

  TemplateUsageStat({
    required this.name,
    required this.count,
    required this.openRate,
  });
}

class DailyTrend {
  final DateTime date;
  final int volume;
  final double successRate;

  DailyTrend({
    required this.date,
    required this.volume,
    required this.successRate,
  });
}
