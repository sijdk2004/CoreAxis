import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/demo_story_step_model.dart';

class DemoStoryState {
  final int currentStepIndex;
  final List<DemoStoryStepModel> steps;
  
  const DemoStoryState({
    required this.currentStepIndex,
    required this.steps,
  });

  DemoStoryState copyWith({
    int? currentStepIndex,
    List<DemoStoryStepModel>? steps,
  }) {
    return DemoStoryState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      steps: steps ?? this.steps,
    );
  }

  double get progress {
    if (steps.isEmpty) return 0;
    final completedCount = steps.where((s) => s.isCompleted).length;
    return completedCount / steps.length;
  }
}

final demoStoryProvider = NotifierProvider<DemoStoryNotifier, DemoStoryState>(() {
  return DemoStoryNotifier();
});

class DemoStoryNotifier extends Notifier<DemoStoryState> {
  @override
  DemoStoryState build() {
    return DemoStoryState(
      currentStepIndex: 0,
      steps: _initialSteps,
    );
  }

  void nextStep() {
    if (state.currentStepIndex < state.steps.length - 1) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
    }
  }

  void previousStep() {
    if (state.currentStepIndex > 0) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
    }
  }

  void setStep(int index) {
    if (index >= 0 && index < state.steps.length) {
      state = state.copyWith(currentStepIndex: index);
    }
  }

  void markComplete(bool isCompleted) {
    final newSteps = List<DemoStoryStepModel>.from(state.steps);
    newSteps[state.currentStepIndex] = newSteps[state.currentStepIndex].copyWith(isCompleted: isCompleted);
    state = state.copyWith(steps: newSteps);
  }

  static const List<DemoStoryStepModel> _initialSteps = [
    DemoStoryStepModel(
      id: 'step_1',
      title: '1. Platform Overview',
      description: 'Introduce the core vision of the CoreAxis ERP Platform.',
      talkingPoints: [
        'Welcome the stakeholders.',
        'Highlight the micro-frontend architecture.',
        'Emphasize the scalable ecosystem for multiple business units.',
      ],
      expectedDuration: '2 mins',
      targetRoute: '/platform/home',
      notes: 'Make sure to smile! Keep it high-level.',
      tips: 'If they ask about deployment, mention our multi-tenant capabilities.',
    ),
    DemoStoryStepModel(
      id: 'step_2',
      title: '2. Platform Administration',
      description: 'Showcase the RBAC and Tenant management capabilities.',
      talkingPoints: [
        'Demonstrate how easy it is to add a new organization.',
        'Show the robust Permissions Matrix.',
        'Highlight the User Role Assignment UI.',
      ],
      expectedDuration: '3 mins',
      targetRoute: '/platform/rbac/matrix',
      notes: 'Focus on the "Permission Simulator" as a key differentiator.',
      tips: 'Don\'t get bogged down in creating a user from scratch, just show the list.',
    ),
    DemoStoryStepModel(
      id: 'step_3',
      title: '3. Automation',
      description: 'Reveal the power of the Workflow and Approval Engines.',
      talkingPoints: [
        'Open the Workflows Dashboard.',
        'Show the visual Workflow Designer (if mock is available).',
        'Demonstrate the seamless Approval Chains.',
      ],
      expectedDuration: '4 mins',
      targetRoute: '/platform/workflows',
      notes: 'This is usually where technical stakeholders lean in.',
      tips: 'Mention that workflows can trigger external webhooks.',
    ),
    DemoStoryStepModel(
      id: 'step_4',
      title: '4. Platform Services',
      description: 'Briefly touch upon Documents and Notifications.',
      talkingPoints: [
        'Show the Document Repository.',
        'Highlight granular document permissions.',
        'Show the Notification Broadcast Center.',
      ],
      expectedDuration: '3 mins',
      targetRoute: '/platform/documents',
      notes: 'Keep this brisk.',
      tips: 'Notification analytics always play well with marketing teams.',
    ),
    DemoStoryStepModel(
      id: 'step_5',
      title: '5. AI Workspace',
      description: 'Demonstrate our AI Assistant capabilities.',
      talkingPoints: [
        'Introduce the AI Knowledge Base.',
        'Show how prompts can generate insights.',
        'Discuss context-aware assistance.',
      ],
      expectedDuration: '4 mins',
      targetRoute: '/platform/ai',
      notes: 'Ensure the mock AI responses load quickly.',
      tips: 'Use the "Summarize Sales" mock prompt as an example.',
    ),
    DemoStoryStepModel(
      id: 'step_6',
      title: '6. Industry Marketplace',
      description: 'Show the extensibility of the platform.',
      talkingPoints: [
        'Open the Module Catalog.',
        'Highlight that modules are essentially plugins.',
        'Show the variety of available industries.',
      ],
      expectedDuration: '2 mins',
      targetRoute: '/platform/modules',
      notes: 'This proves we are not just a single-vertical tool.',
      tips: 'Hover over the FurniFlow module to transition to the next step.',
    ),
    DemoStoryStepModel(
      id: 'step_7',
      title: '7. Launch FurniFlow',
      description: 'Transition from Platform to a specific Industry app.',
      talkingPoints: [
        'Click into the FurniFlow application.',
        'Notice how the core sidebar adapts while keeping the shell consistent.',
        'We are now in the Furniture ERP context.',
      ],
      expectedDuration: '1 min',
      targetRoute: '/furniflow/dashboard',
      notes: 'Dramatic pause as the context switches.',
      tips: 'Remind them that all platform services (auth, notifications) are still active here.',
    ),
    DemoStoryStepModel(
      id: 'step_8',
      title: '8. Furniture ERP Journey',
      description: 'Deep dive into a specific business vertical.',
      talkingPoints: [
        'Show the Inventory tables (filtering, sorting).',
        'Show a Product detail page.',
        'Demonstrate Order fulfillment.',
      ],
      expectedDuration: '5 mins',
      targetRoute: '/furniflow/inventory',
      notes: 'Use the mock data to tell a story about "Product X".',
      tips: 'Point out the complex data table controls.',
    ),
    DemoStoryStepModel(
      id: 'step_9',
      title: '9. Business Reports',
      description: 'Show data aggregation and analytics.',
      talkingPoints: [
        'Navigate to the Reporting dashboard.',
        'Highlight the interactive charts.',
        'Show export capabilities (mock).',
      ],
      expectedDuration: '3 mins',
      targetRoute: '/furniflow/reports',
      notes: 'Executives love dashboards. Linger here.',
      tips: 'Mention real-time data streaming capabilities.',
    ),
    DemoStoryStepModel(
      id: 'step_10',
      title: '10. Executive Summary',
      description: 'Wrap up the presentation and open for Q&A.',
      talkingPoints: [
        'Recap the journey: Platform -> Services -> Specific App -> Insights.',
        'Reiterate the value of a unified ecosystem.',
        'Open the floor for questions.',
      ],
      expectedDuration: '2 mins',
      targetRoute: '/platform/home',
      notes: 'End on the Platform Home to bring it full circle.',
      tips: 'Leave the screen on the Dashboard during Q&A.',
    ),
  ];
}
