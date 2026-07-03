import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/ai_workflow_assistant_model.dart';

final aiWorkflowAssistantProvider = NotifierProvider<AiWorkflowAssistantNotifier, AiWorkflowAssistantState>(() {
  return AiWorkflowAssistantNotifier();
});

class AiWorkflowAssistantNotifier extends Notifier<AiWorkflowAssistantState> {
  @override
  AiWorkflowAssistantState build() {
    return AiWorkflowAssistantState();
  }

  void updatePrompt(String prompt) {
    state = state.copyWith(currentPrompt: prompt);
  }

  Future<void> generateWorkflow() async {
    if (state.currentPrompt.trim().isEmpty) return;

    state = state.copyWith(isGenerating: true, nodes: [], generatedDescription: null);

    // Mock generation delay
    await Future.delayed(const Duration(seconds: 2));

    state = state.copyWith(
      isGenerating: false,
      generatedDescription: 'Here is a suggested ${state.currentPrompt.toLowerCase()} workflow based on best practices. It includes multi-level approval and final notification.',
      nodes: [
        WorkflowNode(id: '1', title: 'Start Workflow', role: 'System', type: 'start'),
        WorkflowNode(id: '2', title: 'Initial Review', role: 'Sales Manager', type: 'approval'),
        WorkflowNode(id: '3', title: 'Financial Audit', role: 'Finance Manager', type: 'approval'),
        WorkflowNode(id: '4', title: 'Executive Sign-off', role: 'Director', type: 'approval'),
        WorkflowNode(id: '5', title: 'Notify Stakeholders', role: 'System', type: 'notification'),
        WorkflowNode(id: '6', title: 'Completed', role: 'System', type: 'end'),
      ],
    );
  }

  Future<void> improveWorkflow() async {
    if (state.nodes.isEmpty) return;
    state = state.copyWith(isGenerating: true);
    await Future.delayed(const Duration(seconds: 1));
    
    final improvedNodes = List<WorkflowNode>.from(state.nodes);
    // Insert a risk check step before finance
    if (improvedNodes.length > 2) {
      improvedNodes.insert(2, WorkflowNode(id: '2a', title: 'Risk Assessment (AI)', role: 'AI Agent', type: 'automated'));
    }
    
    state = state.copyWith(
      isGenerating: false,
      generatedDescription: 'I added an automated AI Risk Assessment step to ensure compliance before financial review.',
      nodes: improvedNodes,
    );
  }

  Future<void> simplifyWorkflow() async {
    if (state.nodes.isEmpty) return;
    state = state.copyWith(isGenerating: true);
    await Future.delayed(const Duration(seconds: 1));
    
    state = state.copyWith(
      isGenerating: false,
      generatedDescription: 'I simplified the workflow by combining the executive and finance sign-offs.',
      nodes: [
        WorkflowNode(id: '1', title: 'Start', role: 'System', type: 'start'),
        WorkflowNode(id: '2', title: 'Manager Approval', role: 'Sales Manager', type: 'approval'),
        WorkflowNode(id: '3', title: 'Final Sign-off', role: 'Director / Finance', type: 'approval'),
        WorkflowNode(id: '4', title: 'Completed', role: 'System', type: 'end'),
      ],
    );
  }
}
