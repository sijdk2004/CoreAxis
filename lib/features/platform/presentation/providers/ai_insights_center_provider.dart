import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/ai_insights_center_model.dart';

final aiInsightsCenterProvider = NotifierProvider<AiInsightsCenterNotifier, AiInsightsCenterState>(() {
  return AiInsightsCenterNotifier();
});

class AiInsightsCenterNotifier extends Notifier<AiInsightsCenterState> {
  @override
  AiInsightsCenterState build() {
    Future.microtask(() => _loadData());
    return AiInsightsCenterState(isLoading: true);
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));

    state = state.copyWith(
      isLoading: false,
      insights: [
        AiInsight(
          id: 'ins-1',
          title: 'Workflow approval time increased by 24%',
          description: 'The average time to approve Purchase Orders has increased from 2.1 days to 2.6 days over the last two weeks.',
          category: InsightCategory.workflow,
          priority: InsightPriority.high,
          impact: 'Delays in procurement and potential vendor penalties.',
          confidence: 92.5,
          recommendation: 'Re-route PO approvals over \$5,000 to the secondary finance approver automatically.',
          date: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AiInsight(
          id: 'ins-2',
          title: 'Unused roles detected',
          description: 'Found 4 custom RBAC roles that have not been assigned to any active user in the past 12 months.',
          category: InsightCategory.security,
          priority: InsightPriority.medium,
          impact: 'Increased security surface area and admin overhead.',
          confidence: 99.9,
          recommendation: 'Archive or delete the following roles: External Vendor (Legacy), Intern Q3, Temp Audit, Sales VP.',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        AiInsight(
          id: 'ins-3',
          title: 'Storage usage growing rapidly',
          description: 'Document storage usage for Organization "Acme Corp" has spiked by 400GB in the last 48 hours.',
          category: InsightCategory.operations,
          priority: InsightPriority.critical,
          impact: 'Potential storage quota breach resulting in extra billing charges.',
          confidence: 88.0,
          recommendation: 'Run deduplication script and enforce auto-archival for files older than 5 years in Acme Corp.',
          date: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        AiInsight(
          id: 'ins-4',
          title: 'Inactive organizations identified',
          description: 'Organization "Stellar Legacy" has had zero user logins and zero API calls in the last 90 days.',
          category: InsightCategory.finance,
          priority: InsightPriority.low,
          impact: 'Wasted licensing costs for inactive tenant.',
          confidence: 95.0,
          recommendation: 'Initiate offboarding protocol and suspend billing for Stellar Legacy.',
          date: DateTime.now().subtract(const Duration(days: 3)),
        ),
        AiInsight(
          id: 'ins-5',
          title: 'Approval bottlenecks detected',
          description: 'User "Jane Doe (CFO)" currently has 145 pending approvals, which is 3x higher than the company average.',
          category: InsightCategory.workflow,
          priority: InsightPriority.high,
          impact: 'Significant delay in expense processing and budget allocations.',
          confidence: 94.2,
          recommendation: 'Enable auto-approval for expenses under \$100 or delegate approvals to the VP of Finance temporarily.',
          date: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        AiInsight(
          id: 'ins-6',
          title: 'Anomalous login activity',
          description: 'Multiple failed login attempts detected from unrecognized IPs attempting to access Admin accounts.',
          category: InsightCategory.security,
          priority: InsightPriority.critical,
          impact: 'High risk of account compromise.',
          confidence: 89.5,
          recommendation: 'Force password resets for affected accounts and enforce strict geo-blocking for admin logins.',
          date: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
    );
  }

  void updateFilters({String? priority, String? category, String? date, String? search}) {
    state = state.copyWith(
      selectedPriority: priority,
      selectedCategory: category,
      selectedDate: date,
      searchQuery: search,
    );
  }

  void dismissInsight(String id) {
    final updatedList = state.insights.map((insight) {
      if (insight.id == id) {
        return insight.copyWith(isDismissed: true);
      }
      return insight;
    }).toList();
    state = state.copyWith(insights: updatedList);
  }

  void applyRecommendation(String id) {
    // In a real app, this would trigger an API call. For now, just dismiss it.
    dismissInsight(id);
  }
}
