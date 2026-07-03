class DemoStoryStepModel {
  final String id;
  final String title;
  final String description;
  final List<String> talkingPoints;
  final String expectedDuration;
  final String targetRoute;
  final String notes;
  final String tips;
  final bool isCompleted;

  const DemoStoryStepModel({
    required this.id,
    required this.title,
    required this.description,
    required this.talkingPoints,
    required this.expectedDuration,
    required this.targetRoute,
    required this.notes,
    required this.tips,
    this.isCompleted = false,
  });

  DemoStoryStepModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? talkingPoints,
    String? expectedDuration,
    String? targetRoute,
    String? notes,
    String? tips,
    bool? isCompleted,
  }) {
    return DemoStoryStepModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      talkingPoints: talkingPoints ?? this.talkingPoints,
      expectedDuration: expectedDuration ?? this.expectedDuration,
      targetRoute: targetRoute ?? this.targetRoute,
      notes: notes ?? this.notes,
      tips: tips ?? this.tips,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
