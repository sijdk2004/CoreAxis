import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_automation_model.dart';

class AIAutomationState {
  final List<AutomationNode> nodes;
  final List<AiBlock> availableBlocks;
  final bool isSaving;
  final bool isPreviewing;

  const AIAutomationState({
    this.nodes = const [],
    this.availableBlocks = const [],
    this.isSaving = false,
    this.isPreviewing = false,
  });

  AIAutomationState copyWith({
    List<AutomationNode>? nodes,
    List<AiBlock>? availableBlocks,
    bool? isSaving,
    bool? isPreviewing,
  }) {
    return AIAutomationState(
      nodes: nodes ?? this.nodes,
      availableBlocks: availableBlocks ?? this.availableBlocks,
      isSaving: isSaving ?? this.isSaving,
      isPreviewing: isPreviewing ?? this.isPreviewing,
    );
  }
}

class AIAutomationNotifier extends Notifier<AIAutomationState> {
  @override
  AIAutomationState build() {
    return AIAutomationState(
      availableBlocks: _generateMockBlocks(),
      nodes: _generateInitialNodes(),
    );
  }

  void addNode(AutomationNode node) {
    state = state.copyWith(nodes: [...state.nodes, node]);
  }

  void removeNode(String id) {
    state = state.copyWith(
      nodes: state.nodes.where((n) => n.id != id).toList(),
    );
  }

  void reorderNodes(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final nodes = List<AutomationNode>.from(state.nodes);
    final item = nodes.removeAt(oldIndex);
    nodes.insert(newIndex, item);
    state = state.copyWith(nodes: nodes);
  }

  void saveFlow() {
    state = state.copyWith(isSaving: true);
    Future.delayed(const Duration(seconds: 1), () {
      state = state.copyWith(isSaving: false);
    });
  }

  void togglePreview() {
    state = state.copyWith(isPreviewing: !state.isPreviewing);
  }

  void loadTemplate() {
    state = state.copyWith(nodes: _generateInitialNodes());
  }

  List<AiBlock> _generateMockBlocks() {
    return const [
      AiBlock(id: 'b1', title: 'Summarize', icon: 'file-text', description: 'Condense long text into a summary.'),
      AiBlock(id: 'b2', title: 'Classify', icon: 'tag', description: 'Categorize inputs based on predefined labels.'),
      AiBlock(id: 'b3', title: 'Translate', icon: 'globe', description: 'Convert text between languages.'),
      AiBlock(id: 'b4', title: 'Predict', icon: 'trending-up', description: 'Forecast future values based on trends.'),
      AiBlock(id: 'b5', title: 'Extract', icon: 'scissors', description: 'Pull specific entities from raw text.'),
      AiBlock(id: 'b6', title: 'Generate', icon: 'pen-tool', description: 'Create new content from a prompt.'),
      AiBlock(id: 'b7', title: 'Compare', icon: 'git-compare', description: 'Find similarities or differences between inputs.'),
      AiBlock(id: 'b8', title: 'Recommend', icon: 'thumbs-up', description: 'Suggest next best actions or items.'),
    ];
  }

  List<AutomationNode> _generateInitialNodes() {
    return const [
      AutomationNode(
        id: 'n1',
        title: 'Email Received',
        type: 'trigger',
        icon: 'mail',
        description: 'Triggers when a new customer inquiry arrives.',
      ),
      AutomationNode(
        id: 'n2',
        title: 'Classify Intent',
        type: 'ai_analysis',
        icon: 'tag',
        description: 'Categorizes email as Support, Sales, or General.',
      ),
      AutomationNode(
        id: 'n3',
        title: 'Route to Department',
        type: 'decision',
        icon: 'git-branch',
        description: 'If Support -> Support Queue. If Sales -> Sales Team.',
      ),
      AutomationNode(
        id: 'n4',
        title: 'Create Ticket',
        type: 'workflow',
        icon: 'check-square',
        description: 'Creates a ticket in the ERP service module.',
      ),
      AutomationNode(
        id: 'n5',
        title: 'Notify Agent',
        type: 'notification',
        icon: 'bell',
        description: 'Sends a Slack alert to the assigned agent.',
      ),
      AutomationNode(
        id: 'n6',
        title: 'End Flow',
        type: 'completion',
        icon: 'flag',
        description: 'Marks the automation run as successful.',
      ),
    ];
  }
}

final aiAutomationProvider = NotifierProvider<AIAutomationNotifier, AIAutomationState>(() {
  return AIAutomationNotifier();
});
