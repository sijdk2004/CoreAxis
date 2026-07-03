import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

enum CompanySize {
  small,
  medium,
  enterprise,
}

extension CompanySizeExt on CompanySize {
  String get label {
    switch (this) {
      case CompanySize.small:
        return 'Small Company';
      case CompanySize.medium:
        return 'Medium Company';
      case CompanySize.enterprise:
        return 'Enterprise';
    }
  }

  String get description {
    switch (this) {
      case CompanySize.small:
        return 'Up to 50 employees, basic workflows.';
      case CompanySize.medium:
        return '50-500 employees, advanced reporting.';
      case CompanySize.enterprise:
        return '500+ employees, AI and complex structures.';
    }
  }
}

final availableEntities = [
  'Users',
  'Organizations',
  'Products',
  'Workflows',
  'Reports',
  'Documents',
  'Notifications',
  'AI History',
];

class DemoDataGeneratorState {
  final CompanySize companySize;
  final Set<String> selectedEntities;
  final bool isGenerating;
  final double generationProgress;
  final bool generationComplete;

  const DemoDataGeneratorState({
    required this.companySize,
    required this.selectedEntities,
    required this.isGenerating,
    required this.generationProgress,
    required this.generationComplete,
  });

  DemoDataGeneratorState copyWith({
    CompanySize? companySize,
    Set<String>? selectedEntities,
    bool? isGenerating,
    double? generationProgress,
    bool? generationComplete,
  }) {
    return DemoDataGeneratorState(
      companySize: companySize ?? this.companySize,
      selectedEntities: selectedEntities ?? this.selectedEntities,
      isGenerating: isGenerating ?? this.isGenerating,
      generationProgress: generationProgress ?? this.generationProgress,
      generationComplete: generationComplete ?? this.generationComplete,
    );
  }
}

class DemoDataGeneratorNotifier extends Notifier<DemoDataGeneratorState> {
  @override
  DemoDataGeneratorState build() {
    return DemoDataGeneratorState(
      companySize: CompanySize.medium,
      selectedEntities: Set.from(availableEntities),
      isGenerating: false,
      generationProgress: 0.0,
      generationComplete: false,
    );
  }

  void setCompanySize(CompanySize size) {
    if (state.isGenerating) return;
    state = state.copyWith(
      companySize: size,
      generationComplete: false,
      generationProgress: 0.0,
    );
  }

  void toggleEntity(String entity) {
    if (state.isGenerating) return;
    
    final newSelected = Set<String>.from(state.selectedEntities);
    if (newSelected.contains(entity)) {
      newSelected.remove(entity);
    } else {
      newSelected.add(entity);
    }
    
    state = state.copyWith(
      selectedEntities: newSelected,
      generationComplete: false,
      generationProgress: 0.0,
    );
  }

  void toggleAll(bool? selectAll) {
    if (state.isGenerating) return;

    if (selectAll == true) {
      state = state.copyWith(
        selectedEntities: Set.from(availableEntities),
        generationComplete: false,
        generationProgress: 0.0,
      );
    } else {
      state = state.copyWith(
        selectedEntities: {},
        generationComplete: false,
        generationProgress: 0.0,
      );
    }
  }

  void reset() {
    if (state.isGenerating) return;
    state = DemoDataGeneratorState(
      companySize: CompanySize.medium,
      selectedEntities: Set.from(availableEntities),
      isGenerating: false,
      generationProgress: 0.0,
      generationComplete: false,
    );
  }

  Future<void> generate() async {
    if (state.isGenerating || state.selectedEntities.isEmpty) return;

    state = state.copyWith(
      isGenerating: true,
      generationProgress: 0.0,
      generationComplete: false,
    );

    // Mock generation process
    final totalSteps = 20;
    for (int i = 1; i <= totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!state.isGenerating) break; // Check if cancelled somehow (though we don't have a cancel button yet)
      state = state.copyWith(generationProgress: i / totalSteps);
    }

    state = state.copyWith(
      isGenerating: false,
      generationProgress: 1.0,
      generationComplete: true,
    );
  }
}

final demoDataGeneratorProvider = NotifierProvider<DemoDataGeneratorNotifier, DemoDataGeneratorState>(
  DemoDataGeneratorNotifier.new,
);
