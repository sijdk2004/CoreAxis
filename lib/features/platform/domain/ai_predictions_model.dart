class PredictionMetric {
  final String title;
  final String value;
  final String trend; // e.g., '+18%', '-5%'
  final bool isPositive;
  final String expectedTimeframe;

  PredictionMetric({
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositive,
    required this.expectedTimeframe,
  });
}

class ForecastDataPoint {
  final String date;
  final double historicalValue;
  final double predictedValue;
  final double lowerBound;
  final double upperBound;

  ForecastDataPoint({
    required this.date,
    required this.historicalValue,
    required this.predictedValue,
    required this.lowerBound,
    required this.upperBound,
  });
}

class RiskAlert {
  final String id;
  final String title;
  final String description;
  final String severity; // Low, Medium, High, Critical
  final double probability;

  RiskAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.probability,
  });
}

class AiPredictionsState {
  final bool isLoading;
  final List<PredictionMetric> metrics;
  final List<ForecastDataPoint> forecastTrend;
  final List<RiskAlert> riskAlerts;
  final List<String> recommendations;
  final String timeframeFilter;
  
  AiPredictionsState({
    this.isLoading = false,
    this.metrics = const [],
    this.forecastTrend = const [],
    this.riskAlerts = const [],
    this.recommendations = const [],
    this.timeframeFilter = 'Next 30 Days',
  });

  AiPredictionsState copyWith({
    bool? isLoading,
    List<PredictionMetric>? metrics,
    List<ForecastDataPoint>? forecastTrend,
    List<RiskAlert>? riskAlerts,
    List<String>? recommendations,
    String? timeframeFilter,
  }) {
    return AiPredictionsState(
      isLoading: isLoading ?? this.isLoading,
      metrics: metrics ?? this.metrics,
      forecastTrend: forecastTrend ?? this.forecastTrend,
      riskAlerts: riskAlerts ?? this.riskAlerts,
      recommendations: recommendations ?? this.recommendations,
      timeframeFilter: timeframeFilter ?? this.timeframeFilter,
    );
  }
}
