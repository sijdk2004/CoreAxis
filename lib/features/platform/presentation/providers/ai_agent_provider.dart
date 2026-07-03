import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_agent_model.dart';

class AiAgentState {
  final List<AiAgent> agents;
  final String searchQuery;

  const AiAgentState({
    this.agents = const [],
    this.searchQuery = '',
  });

  AiAgentState copyWith({
    List<AiAgent>? agents,
    String? searchQuery,
  }) {
    return AiAgentState(
      agents: agents ?? this.agents,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<AiAgent> get filteredAgents {
    if (searchQuery.isEmpty) return agents;
    final query = searchQuery.toLowerCase();
    return agents.where((a) => 
      a.name.toLowerCase().contains(query) || 
      a.description.toLowerCase().contains(query)
    ).toList();
  }
}

class AiAgentNotifier extends Notifier<AiAgentState> {
  @override
  AiAgentState build() {
    return AiAgentState(
      agents: _generateMockAgents(),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void duplicateAgent(String id) {
    final agent = state.agents.firstWhere((a) => a.id == id);
    final newAgent = agent.copyWith(
      id: 'a_${DateTime.now().millisecondsSinceEpoch}',
      name: '${agent.name} (Copy)',
      status: 'Inactive',
    );
    state = state.copyWith(agents: [...state.agents, newAgent]);
  }

  void toggleAgentStatus(String id) {
    final updatedAgents = state.agents.map((a) {
      if (a.id == id) {
        return a.copyWith(status: a.status == 'Active' ? 'Inactive' : 'Active');
      }
      return a;
    }).toList();
    state = state.copyWith(agents: updatedAgents);
  }

  List<AiAgent> _generateMockAgents() {
    return [
      AiAgent(
        id: 'a1',
        name: 'Executive Advisor',
        description: 'Provides high-level strategic insights, market analysis, and executive summaries based on cross-departmental data.',
        status: 'Active',
        capabilities: ['Strategic Planning', 'Market Analysis', 'Risk Assessment'],
        lastUsed: DateTime.now().subtract(const Duration(minutes: 15)),
        icon: 'briefcase',
      ),
      AiAgent(
        id: 'a2',
        name: 'Workflow Expert',
        description: 'Analyzes business processes, identifies bottlenecks, and suggests automation improvements for operational efficiency.',
        status: 'Active',
        capabilities: ['Process Optimization', 'Automation Routing', 'Bottleneck Analysis'],
        lastUsed: DateTime.now().subtract(const Duration(hours: 2)),
        icon: 'git-branch',
      ),
      AiAgent(
        id: 'a3',
        name: 'Reporting Assistant',
        description: 'Generates custom charts, compiles regular reports, and highlights key performance indicators.',
        status: 'Active',
        capabilities: ['Data Visualization', 'Automated Reporting', 'Trend Spotting'],
        lastUsed: DateTime.now().subtract(const Duration(hours: 5)),
        icon: 'bar-chart-2',
      ),
      AiAgent(
        id: 'a4',
        name: 'Finance Analyst',
        description: 'Monitors cash flow, predicts financial trends, and assists in budget planning and variance analysis.',
        status: 'Learning',
        capabilities: ['Budget Forecasting', 'Expense Tracking', 'Variance Analysis'],
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
        icon: 'dollar-sign',
      ),
      AiAgent(
        id: 'a5',
        name: 'HR Assistant',
        description: 'Helps with employee onboarding, answers policy questions, and assists in performance review summaries.',
        status: 'Active',
        capabilities: ['Onboarding Support', 'Policy Q&A', 'Performance Summaries'],
        lastUsed: DateTime.now().subtract(const Duration(minutes: 45)),
        icon: 'users',
      ),
      AiAgent(
        id: 'a6',
        name: 'Operations Advisor',
        description: 'Optimizes supply chain, tracks inventory levels, and predicts operational resource requirements.',
        status: 'Inactive',
        capabilities: ['Supply Chain', 'Inventory Forecasting', 'Resource Allocation'],
        lastUsed: DateTime.now().subtract(const Duration(days: 4)),
        icon: 'settings',
      ),
      AiAgent(
        id: 'a7',
        name: 'Document Assistant',
        description: 'Extracts data from unstructured documents, summarizes long texts, and helps draft standard contracts.',
        status: 'Active',
        capabilities: ['OCR Data Extraction', 'Summarization', 'Drafting'],
        lastUsed: DateTime.now().subtract(const Duration(hours: 1)),
        icon: 'file-text',
      ),
      AiAgent(
        id: 'a8',
        name: 'Security Advisor',
        description: 'Monitors access logs, identifies anomalous user behavior, and ensures compliance with security policies.',
        status: 'Active',
        capabilities: ['Anomaly Detection', 'Compliance Checking', 'Access Review'],
        lastUsed: DateTime.now().subtract(const Duration(minutes: 5)),
        icon: 'shield',
      ),
    ];
  }
}

final aiAgentProvider = NotifierProvider<AiAgentNotifier, AiAgentState>(() {
  return AiAgentNotifier();
});
