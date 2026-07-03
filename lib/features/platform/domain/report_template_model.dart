enum TemplateCategory { executive, finance, sales, production, inventory, hr, audit, workflow }
enum ComplexityLevel { low, medium, high }

class ReportTemplateModel {
  final String id;
  final String name;
  final String description;
  final TemplateCategory category;
  final ComplexityLevel complexity;
  final int widgetCount;
  final String estimatedTime;
  final bool isFavorite;
  final String previewImage;

  ReportTemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.complexity,
    required this.widgetCount,
    required this.estimatedTime,
    required this.isFavorite,
    required this.previewImage,
  });

  ReportTemplateModel copyWith({
    String? id,
    String? name,
    String? description,
    TemplateCategory? category,
    ComplexityLevel? complexity,
    int? widgetCount,
    String? estimatedTime,
    bool? isFavorite,
    String? previewImage,
  }) {
    return ReportTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      complexity: complexity ?? this.complexity,
      widgetCount: widgetCount ?? this.widgetCount,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      isFavorite: isFavorite ?? this.isFavorite,
      previewImage: previewImage ?? this.previewImage,
    );
  }
}
