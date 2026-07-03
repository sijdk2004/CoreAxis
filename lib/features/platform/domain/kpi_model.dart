enum KpiCategory { operations, finance, sales, production, hr, workflow }
enum KpiWidgetType { gauge, card, trend, sparkline }

class KpiThreshold {
  final double value;
  final String color; // Hex string e.g., '#FF0000'

  KpiThreshold({required this.value, required this.color});
}

class KpiModel {
  final String id;
  final String name;
  final String description;
  final KpiCategory category;
  final String formula;
  final double target;
  final List<KpiThreshold> thresholds;
  final KpiWidgetType widgetType;
  final double currentValue; // Mock calculated value

  KpiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.formula,
    required this.target,
    required this.thresholds,
    required this.widgetType,
    required this.currentValue,
  });

  KpiModel copyWith({
    String? id,
    String? name,
    String? description,
    KpiCategory? category,
    String? formula,
    double? target,
    List<KpiThreshold>? thresholds,
    KpiWidgetType? widgetType,
    double? currentValue,
  }) {
    return KpiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      formula: formula ?? this.formula,
      target: target ?? this.target,
      thresholds: thresholds ?? this.thresholds,
      widgetType: widgetType ?? this.widgetType,
      currentValue: currentValue ?? this.currentValue,
    );
  }
}
