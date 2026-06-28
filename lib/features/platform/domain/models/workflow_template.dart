class WorkflowTemplate {
  final String id;
  final String name;
  final String category;
  final int steps;
  final String complexity;
  final String estimatedSetupTime;
  final bool isFavorite;

  const WorkflowTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.steps,
    required this.complexity,
    required this.estimatedSetupTime,
    this.isFavorite = false,
  });

  WorkflowTemplate copyWith({
    String? id,
    String? name,
    String? category,
    int? steps,
    String? complexity,
    String? estimatedSetupTime,
    bool? isFavorite,
  }) {
    return WorkflowTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      steps: steps ?? this.steps,
      complexity: complexity ?? this.complexity,
      estimatedSetupTime: estimatedSetupTime ?? this.estimatedSetupTime,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
