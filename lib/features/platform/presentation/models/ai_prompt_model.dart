import 'package:flutter/foundation.dart';

@immutable
class AIPrompt {
  final String id;
  final String title;
  final String category;
  final String promptText;
  final String description;
  final bool isFavorite;
  final int usageCount;

  const AIPrompt({
    required this.id,
    required this.title,
    required this.category,
    required this.promptText,
    required this.description,
    this.isFavorite = false,
    this.usageCount = 0,
  });

  AIPrompt copyWith({
    String? id,
    String? title,
    String? category,
    String? promptText,
    String? description,
    bool? isFavorite,
    int? usageCount,
  }) {
    return AIPrompt(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      promptText: promptText ?? this.promptText,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
