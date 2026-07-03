enum InsightCategory {
  operations,
  security,
  finance,
  workflow,
  reporting,
  users,
  documents,
  notifications,
}

enum InsightPriority {
  low,
  medium,
  high,
  critical,
}

class AiInsight {
  final String id;
  final String title;
  final String description;
  final InsightCategory category;
  final InsightPriority priority;
  final String impact;
  final double confidence; // percentage 0-100
  final String recommendation;
  final DateTime date;
  final bool isDismissed;

  AiInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.impact,
    required this.confidence,
    required this.recommendation,
    required this.date,
    this.isDismissed = false,
  });

  AiInsight copyWith({
    bool? isDismissed,
  }) {
    return AiInsight(
      id: id,
      title: title,
      description: description,
      category: category,
      priority: priority,
      impact: impact,
      confidence: confidence,
      recommendation: recommendation,
      date: date,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}

class AiInsightsCenterState {
  final bool isLoading;
  final List<AiInsight> insights;
  final String selectedPriority;
  final String selectedCategory;
  final String selectedDate;
  final String searchQuery;

  AiInsightsCenterState({
    this.isLoading = false,
    this.insights = const [],
    this.selectedPriority = 'All',
    this.selectedCategory = 'All',
    this.selectedDate = 'Any Time',
    this.searchQuery = '',
  });

  AiInsightsCenterState copyWith({
    bool? isLoading,
    List<AiInsight>? insights,
    String? selectedPriority,
    String? selectedCategory,
    String? selectedDate,
    String? searchQuery,
  }) {
    return AiInsightsCenterState(
      isLoading: isLoading ?? this.isLoading,
      insights: insights ?? this.insights,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDate: selectedDate ?? this.selectedDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<AiInsight> get filteredInsights {
    return insights.where((insight) {
      if (insight.isDismissed) return false;
      
      if (selectedPriority != 'All' && 
          insight.priority.name.toLowerCase() != selectedPriority.toLowerCase()) {
        return false;
      }
      
      if (selectedCategory != 'All' && 
          insight.category.name.toLowerCase() != selectedCategory.toLowerCase()) {
        return false;
      }

      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!insight.title.toLowerCase().contains(query) && 
            !insight.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
