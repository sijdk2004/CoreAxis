import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/ai_predictions_model.dart';
import 'dart:math';

final aiPredictionsProvider = NotifierProvider<AiPredictionsNotifier, AiPredictionsState>(() {
  return AiPredictionsNotifier();
});

class AiPredictionsNotifier extends Notifier<AiPredictionsState> {
  @override
  AiPredictionsState build() {
    Future.microtask(() => _loadData());
    return AiPredictionsState(isLoading: true);
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 700));

    state = state.copyWith(
      isLoading: false,
      metrics: [
        PredictionMetric(title: 'Tenant Growth', value: '450', trend: '+18%', isPositive: true, expectedTimeframe: 'Next 30 Days'),
        PredictionMetric(title: 'Storage Growth', value: '12.5 TB', trend: '+22%', isPositive: false, expectedTimeframe: 'By End of Q3'),
        PredictionMetric(title: 'User Growth', value: '14,200', trend: '+5%', isPositive: true, expectedTimeframe: 'Next 30 Days'),
        PredictionMetric(title: 'Revenue Forecast', value: '\$2.4M', trend: '+12%', isPositive: true, expectedTimeframe: 'Next Quarter'),
        PredictionMetric(title: 'Workflow Load', value: '85k', trend: '+8%', isPositive: false, expectedTimeframe: 'Next 7 Days'),
        PredictionMetric(title: 'Approval Delays', value: '3.2 Days', trend: '+15%', isPositive: false, expectedTimeframe: 'Next 14 Days'),
      ],
      forecastTrend: _generateTrendData(),
      riskAlerts: [
        RiskAlert(
          id: 'risk-1',
          title: 'Storage Capacity Limit',
          description: 'Storage will exceed 80% next month at current growth rates.',
          severity: 'High',
          probability: 92.5,
        ),
        RiskAlert(
          id: 'risk-2',
          title: 'Approval Backlog',
          description: 'Approval backlog may increase due to upcoming holidays.',
          severity: 'Medium',
          probability: 78.0,
        ),
        RiskAlert(
          id: 'risk-3',
          title: 'API Rate Limits',
          description: 'Tenant Acme Corp is projected to hit API limits within 5 days.',
          severity: 'Critical',
          probability: 98.2,
        ),
      ],
      recommendations: [
        'Provision additional 5TB of cloud storage for EU-West region.',
        'Enable auto-approvals for expenses under \$50 temporarily.',
        'Upgrade Acme Corp to the Enterprise Tier to prevent API throttling.',
        'Launch targeted onboarding campaign for predicted inactive users.',
      ],
    );
  }
  
  List<ForecastDataPoint> _generateTrendData() {
    final now = DateTime.now();
    List<ForecastDataPoint> points = [];
    
    // 3 months historical, 3 months predicted
    for (int i = -3; i <= 3; i++) {
      final date = DateTime(now.year, now.month + i, 1);
      final monthName = _getMonthName(date.month);
      
      double historical = 0;
      double predicted = 0;
      double lower = 0;
      double upper = 0;
      
      if (i < 0) {
        historical = 1000.0 + (i + 4) * 200 + Random().nextDouble() * 100;
        predicted = historical; 
      } else if (i == 0) {
        historical = 1600.0 + Random().nextDouble() * 50;
        predicted = historical;
      } else {
        historical = 0; // Future
        predicted = 1600.0 + (i * 250);
        lower = predicted - (i * 100);
        upper = predicted + (i * 150);
      }
      
      points.add(ForecastDataPoint(
        date: monthName,
        historicalValue: historical,
        predictedValue: predicted,
        lowerBound: lower,
        upperBound: upper,
      ));
    }
    return points;
  }
  
  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1) % 12];
  }

  void updateTimeframe(String timeframe) {
    state = state.copyWith(timeframeFilter: timeframe, isLoading: true);
    _loadData();
  }
}
