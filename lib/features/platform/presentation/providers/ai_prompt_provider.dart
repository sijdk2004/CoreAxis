import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_prompt_model.dart';

class AIPromptState {
  final String searchQuery;
  final String? selectedCategory;
  final List<AIPrompt> prompts;
  final List<String> categories;
  final AIPrompt? executingPrompt;
  final String? executionResult;
  final bool isExecuting;

  const AIPromptState({
    this.searchQuery = '',
    this.selectedCategory,
    this.prompts = const [],
    this.categories = const [],
    this.executingPrompt,
    this.executionResult,
    this.isExecuting = false,
  });

  AIPromptState copyWith({
    String? searchQuery,
    String? selectedCategory,
    List<AIPrompt>? prompts,
    List<String>? categories,
    AIPrompt? executingPrompt,
    String? executionResult,
    bool? isExecuting,
  }) {
    return AIPromptState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      prompts: prompts ?? this.prompts,
      categories: categories ?? this.categories,
      executingPrompt: executingPrompt ?? this.executingPrompt,
      executionResult: executionResult ?? this.executionResult,
      isExecuting: isExecuting ?? this.isExecuting,
    );
  }

  List<AIPrompt> get filteredPrompts {
    var filtered = prompts;
    if (selectedCategory != null && selectedCategory != 'All') {
      if (selectedCategory == 'Favorites') {
        filtered = filtered.where((p) => p.isFavorite).toList();
      } else {
        filtered = filtered.where((p) => p.category == selectedCategory).toList();
      }
    }
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((p) => 
        p.title.toLowerCase().contains(query) || 
        p.promptText.toLowerCase().contains(query) ||
        p.description.toLowerCase().contains(query)
      ).toList();
    }
    return filtered;
  }
}

class AIPromptNotifier extends Notifier<AIPromptState> {
  @override
  AIPromptState build() {
    return AIPromptState(
      categories: const ['All', 'Favorites', 'Executive', 'Operations', 'Finance', 'Workflow', 'Reports', 'Security'],
      prompts: _generateMockPrompts(),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void toggleFavorite(String promptId) {
    final updatedPrompts = state.prompts.map((p) {
      if (p.id == promptId) {
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();
    state = state.copyWith(prompts: updatedPrompts);
  }

  Future<void> runPrompt(AIPrompt prompt) async {
    // Clear previous execution state
    state = state.copyWith(
      executingPrompt: prompt,
      isExecuting: true,
      executionResult: null,
    );
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Update with mock result
    String result = _getMockResultForPrompt(prompt.title);
    
    // Increment usage count
    final updatedPrompts = state.prompts.map((p) {
      if (p.id == prompt.id) {
        return p.copyWith(usageCount: p.usageCount + 1);
      }
      return p;
    }).toList();

    state = state.copyWith(
      isExecuting: false,
      executionResult: result,
      prompts: updatedPrompts,
    );
  }

  void clearExecution() {
    state = AIPromptState(
      searchQuery: state.searchQuery,
      selectedCategory: state.selectedCategory,
      prompts: state.prompts,
      categories: state.categories,
      executingPrompt: null,
      executionResult: null,
      isExecuting: false,
    );
  }

  String _getMockResultForPrompt(String title) {
    switch (title) {
      case 'Summarize tenant activity':
        return 'Tenant Activity Summary (Last 7 Days):\n\n- Active users increased by 12%\n- 45 new workflows created\n- Peak usage time: 10:00 AM - 2:00 PM EST\n- Most used module: Inventory Management';
      case 'Analyze workflow bottlenecks':
        return 'Workflow Bottleneck Analysis:\n\n- Purchase Order Approval workflow has an average delay of 4.2 days.\n- Step "Finance Review" is causing 78% of the delays.\n- Recommendation: Add a secondary approver or automate standard POs under \$1000.';
      case 'Generate executive report':
        return 'Executive Report - Q3 Performance:\n\nRevenue: \$1.2M (+5% YoY)\nExpenses: \$850K (-2% YoY)\nNet Profit Margin: 29%\nKey Achievement: Successfully onboarded 3 new enterprise clients.';
      case 'Find inactive users':
        return 'Found 14 inactive users who haven\'t logged in for the past 60 days.\nTop 3:\n1. jsmith@acme.com (Last login: 65 days ago)\n2. rroe@acme.com (Last login: 72 days ago)\n3. jdoe@acme.com (Last login: 90 days ago)\n\nAction: Automated reminder email drafted.';
      case 'Create approval workflow':
        return 'Approval Workflow Drafted:\n\n1. Submission -> 2. Manager Review (SLA: 24h) -> 3. VP Approval (SLA: 48h) -> 4. Final Notification.\n\nStatus: Ready for deployment.';
      default:
        return 'Analysis complete. The requested data has been processed successfully and no anomalies were found.';
    }
  }

  List<AIPrompt> _generateMockPrompts() {
    return const [
      AIPrompt(
        id: 'p1',
        title: 'Summarize tenant activity',
        category: 'Operations',
        description: 'Generates a quick summary of user activity and system usage across the current tenant.',
        promptText: 'Analyze the system logs and provide a concise summary of tenant activity over the past 7 days, highlighting user engagement and peak usage times.',
        isFavorite: true,
        usageCount: 145,
      ),
      AIPrompt(
        id: 'p2',
        title: 'Analyze workflow bottlenecks',
        category: 'Workflow',
        description: 'Identifies steps in active workflows that are causing delays.',
        promptText: 'Review all active approval workflows and identify steps where requests are pending for more than 48 hours. Suggest automation or routing improvements.',
        usageCount: 89,
      ),
      AIPrompt(
        id: 'p3',
        title: 'Generate executive report',
        category: 'Executive',
        description: 'Creates a high-level summary of financial and operational KPIs.',
        promptText: 'Generate an executive summary report for the current quarter comparing revenue, expenses, and net profit margins against the same period last year.',
        isFavorite: true,
        usageCount: 312,
      ),
      AIPrompt(
        id: 'p4',
        title: 'Find inactive users',
        category: 'Security',
        description: 'Lists users who have not accessed the system recently.',
        promptText: 'Query the user database for accounts that have not logged in for over 60 days and draft an email reminder for account deactivation.',
        usageCount: 42,
      ),
      AIPrompt(
        id: 'p5',
        title: 'Create approval workflow',
        category: 'Workflow',
        description: 'Drafts a standard multi-tier approval workflow.',
        promptText: 'Draft a standard 3-tier approval workflow for capital expenditures including Manager, Director, and VP levels with SLAs for each step.',
        usageCount: 67,
      ),
      AIPrompt(
        id: 'p6',
        title: 'Quarterly financial analysis',
        category: 'Finance',
        description: 'Deep dive into quarterly financial metrics and variances.',
        promptText: 'Perform a detailed variance analysis on the Q2 financials, focusing on departments that exceeded their budget by more than 10%.',
        usageCount: 156,
      ),
      AIPrompt(
        id: 'p7',
        title: 'Monthly sales report',
        category: 'Reports',
        description: 'Summarizes sales performance by region and product line.',
        promptText: 'Generate a comprehensive monthly sales report broken down by region and top 5 product categories, including month-over-month growth rates.',
        usageCount: 201,
      ),
    ];
  }
}

final aiPromptProvider = NotifierProvider<AIPromptNotifier, AIPromptState>(() {
  return AIPromptNotifier();
});
