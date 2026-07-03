import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../models/ai_report_model.dart';

class AIReportState {
  final bool isGenerating;
  final AIReport? currentReport;
  final String? error;
  final List<String> history;

  const AIReportState({
    this.isGenerating = false,
    this.currentReport,
    this.error,
    this.history = const [],
  });

  AIReportState copyWith({
    bool? isGenerating,
    AIReport? currentReport,
    String? error,
    List<String>? history,
  }) {
    return AIReportState(
      isGenerating: isGenerating ?? this.isGenerating,
      currentReport: currentReport ?? this.currentReport,
      error: error,
      history: history ?? this.history,
    );
  }
}

class AIReportNotifier extends Notifier<AIReportState> {
  @override
  AIReportState build() {
    return const AIReportState(
      history: [
        'Create monthly tenant report',
        'Generate user activity report',
        'Show workflow analytics',
        'Display approval statistics',
      ]
    );
  }

  Future<void> generateReport(String prompt) async {
    state = state.copyWith(isGenerating: true, error: null);
    
    // Add to history
    final newHistory = [prompt, ...state.history.where((p) => p != prompt)].take(10).toList();
    state = state.copyWith(history: newHistory);

    // Simulate network delay for AI generation
    await Future.delayed(const Duration(seconds: 2));

    try {
      final report = _mockGenerateReport(prompt);
      state = state.copyWith(
        isGenerating: false,
        currentReport: report,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate report. Please try again.',
      );
    }
  }
  
  void clearReport() {
    state = state.copyWith(currentReport: null, isGenerating: false, error: null);
  }

  AIReport _mockGenerateReport(String prompt) {
    final random = Random();
    final lowerPrompt = prompt.toLowerCase();
    
    String title = 'Generated Report';
    if (lowerPrompt.contains('tenant')) title = 'Monthly Tenant Report';
    if (lowerPrompt.contains('user')) title = 'User Activity Report';
    if (lowerPrompt.contains('workflow')) title = 'Workflow Analytics';
    if (lowerPrompt.contains('approval')) title = 'Approval Statistics';

    return AIReport(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      prompt: prompt,
      generatedAt: DateTime.now(),
      sections: [
        // KPI Section
        AIReportSection(
          title: 'Executive Summary',
          type: 'kpi',
          kpis: [
            AIReportKpi(
              label: 'Total Items',
              value: '${1000 + random.nextInt(9000)}',
              trend: '+${random.nextInt(15)}%',
              isPositive: true,
            ),
            AIReportKpi(
              label: 'Active Users',
              value: '${500 + random.nextInt(500)}',
              trend: '+${random.nextInt(8)}%',
              isPositive: true,
            ),
            AIReportKpi(
              label: 'Issues Found',
              value: '${random.nextInt(50)}',
              trend: '-${random.nextInt(5)}%',
              isPositive: true,
            ),
            AIReportKpi(
              label: 'Completion Rate',
              value: '${85 + random.nextInt(15)}%',
              trend: '+${random.nextInt(3)}%',
              isPositive: true,
            ),
          ],
        ),
        
        // Chart Section
        AIReportSection(
          title: 'Trend Analysis',
          type: 'chart',
          chartType: 'bar',
          chartData: [
            AIReportChartData(label: 'Jan', value: random.nextDouble() * 100),
            AIReportChartData(label: 'Feb', value: random.nextDouble() * 100),
            AIReportChartData(label: 'Mar', value: random.nextDouble() * 100),
            AIReportChartData(label: 'Apr', value: random.nextDouble() * 100),
            AIReportChartData(label: 'May', value: random.nextDouble() * 100),
            AIReportChartData(label: 'Jun', value: random.nextDouble() * 100),
          ],
        ),
        
        // Table Section
        AIReportSection(
          title: 'Detailed Breakdown',
          type: 'table',
          tableColumns: const [
            AIReportTableColumn(label: 'ID', key: 'id'),
            AIReportTableColumn(label: 'Category', key: 'category'),
            AIReportTableColumn(label: 'Status', key: 'status'),
            AIReportTableColumn(label: 'Score', key: 'score'),
          ],
          tableData: List.generate(5, (index) => {
            'id': 'ITEM-${1000 + index}',
            'category': ['Operations', 'Finance', 'HR', 'IT'][random.nextInt(4)],
            'status': ['Completed', 'Pending', 'In Progress'][random.nextInt(3)],
            'score': '${70 + random.nextInt(30)}',
          }),
        ),
      ],
    );
  }
}

final aiReportProvider = NotifierProvider<AIReportNotifier, AIReportState>(() {
  return AIReportNotifier();
});
