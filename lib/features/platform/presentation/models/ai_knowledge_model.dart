import 'package:flutter/foundation.dart';

@immutable
class KnowledgeArticle {
  final String id;
  final String title;
  final String category;
  final String content;
  final String author;
  final DateTime lastUpdated;
  final int views;
  final double rating;
  final bool isFavorite;

  const KnowledgeArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.author,
    required this.lastUpdated,
    required this.views,
    required this.rating,
    this.isFavorite = false,
  });

  KnowledgeArticle copyWith({
    String? id,
    String? title,
    String? category,
    String? content,
    String? author,
    DateTime? lastUpdated,
    int? views,
    double? rating,
    bool? isFavorite,
  }) {
    return KnowledgeArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      author: author ?? this.author,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      views: views ?? this.views,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

@immutable
class KnowledgeCategory {
  final String id;
  final String name;
  final String icon;
  final int articleCount;

  const KnowledgeCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.articleCount,
  });
}
