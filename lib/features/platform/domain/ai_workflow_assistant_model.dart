class WorkflowNode {
  final String id;
  final String title;
  final String role;
  final String type; // e.g., 'start', 'approval', 'notification', 'end'

  WorkflowNode({
    required this.id,
    required this.title,
    required this.role,
    required this.type,
  });
}

class AiWorkflowAssistantState {
  final bool isGenerating;
  final String currentPrompt;
  final List<WorkflowNode> nodes;
  final String? generatedDescription;
  
  AiWorkflowAssistantState({
    this.isGenerating = false,
    this.currentPrompt = '',
    this.nodes = const [],
    this.generatedDescription,
  });

  AiWorkflowAssistantState copyWith({
    bool? isGenerating,
    String? currentPrompt,
    List<WorkflowNode>? nodes,
    String? generatedDescription,
  }) {
    return AiWorkflowAssistantState(
      isGenerating: isGenerating ?? this.isGenerating,
      currentPrompt: currentPrompt ?? this.currentPrompt,
      nodes: nodes ?? this.nodes,
      generatedDescription: generatedDescription ?? this.generatedDescription,
    );
  }
}
