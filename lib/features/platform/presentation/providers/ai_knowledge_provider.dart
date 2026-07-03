import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_knowledge_model.dart';

class AIKnowledgeState {
  final bool isLoading;
  final String searchQuery;
  final String? selectedCategory;
  final List<KnowledgeArticle> articles;
  final List<KnowledgeCategory> categories;
  final List<String> searchHistory;
  final List<KnowledgeArticle> suggestedArticles;

  const AIKnowledgeState({
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedCategory,
    this.articles = const [],
    this.categories = const [],
    this.searchHistory = const [],
    this.suggestedArticles = const [],
  });

  AIKnowledgeState copyWith({
    bool? isLoading,
    String? searchQuery,
    String? selectedCategory,
    List<KnowledgeArticle>? articles,
    List<KnowledgeCategory>? categories,
    List<String>? searchHistory,
    List<KnowledgeArticle>? suggestedArticles,
  }) {
    return AIKnowledgeState(
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      articles: articles ?? this.articles,
      categories: categories ?? this.categories,
      searchHistory: searchHistory ?? this.searchHistory,
      suggestedArticles: suggestedArticles ?? this.suggestedArticles,
    );
  }

  List<KnowledgeArticle> get filteredArticles {
    var filtered = articles;
    if (selectedCategory != null) {
      filtered = filtered.where((a) => a.category == selectedCategory).toList();
    }
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((a) => 
        a.title.toLowerCase().contains(query) || 
        a.content.toLowerCase().contains(query)
      ).toList();
    }
    return filtered;
  }

  List<KnowledgeArticle> get favoriteArticles => articles.where((a) => a.isFavorite).toList();
}

class AIKnowledgeNotifier extends Notifier<AIKnowledgeState> {
  @override
  AIKnowledgeState build() {
    return AIKnowledgeState(
      categories: const [
        KnowledgeCategory(id: 'c1', name: 'Platform Documentation', icon: 'book', articleCount: 120),
        KnowledgeCategory(id: 'c2', name: 'Industry Packs', icon: 'package', articleCount: 45),
        KnowledgeCategory(id: 'c3', name: 'Workflows', icon: 'git-merge', articleCount: 82),
        KnowledgeCategory(id: 'c4', name: 'Policies', icon: 'shield', articleCount: 30),
        KnowledgeCategory(id: 'c5', name: 'FAQs', icon: 'help-circle', articleCount: 200),
        KnowledgeCategory(id: 'c6', name: 'Video Tutorials', icon: 'video', articleCount: 56),
        KnowledgeCategory(id: 'c7', name: 'Platform', icon: 'layout', articleCount: 15),
        KnowledgeCategory(id: 'c8', name: 'Furniture', icon: 'box', articleCount: 25),
        KnowledgeCategory(id: 'c9', name: 'Inventory', icon: 'database', articleCount: 60),
        KnowledgeCategory(id: 'c10', name: 'Production', icon: 'settings', articleCount: 40),
        KnowledgeCategory(id: 'c11', name: 'Finance', icon: 'dollar-sign', articleCount: 35),
        KnowledgeCategory(id: 'c12', name: 'Sales', icon: 'shopping-cart', articleCount: 75),
      ],
      searchHistory: const ['How to create a sales order', 'Configure production workflow', 'Manage inventory limits'],
      articles: _generateMockArticles(),
      suggestedArticles: _generateMockArticles().take(3).toList(),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    if (query.isNotEmpty && !state.searchHistory.contains(query)) {
      final newHistory = [query, ...state.searchHistory].take(10).toList();
      state = state.copyWith(searchHistory: newHistory);
    }
  }

  void setCategory(String? categoryName) {
    state = state.copyWith(selectedCategory: categoryName);
  }

  void toggleFavorite(String articleId) {
    final updatedArticles = state.articles.map((a) {
      if (a.id == articleId) {
        return a.copyWith(isFavorite: !a.isFavorite);
      }
      return a;
    }).toList();
    
    final updatedSuggested = state.suggestedArticles.map((a) {
      if (a.id == articleId) {
        return a.copyWith(isFavorite: !a.isFavorite);
      }
      return a;
    }).toList();

    state = state.copyWith(articles: updatedArticles, suggestedArticles: updatedSuggested);
  }

  List<KnowledgeArticle> _generateMockArticles() {
    return [
      KnowledgeArticle(
        id: 'a1',
        title: 'Getting Started with CoreAxis ERP',
        category: 'Platform Documentation',
        content: 'Welcome to CoreAxis ERP. This guide will walk you through the basic setup and navigation of the platform...',
        author: 'System Admin',
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        views: 1250,
        rating: 4.8,
        isFavorite: true,
      ),
      KnowledgeArticle(
        id: 'a2',
        title: 'Managing Furniture Inventory',
        category: 'Furniture',
        content: 'Learn how to track and manage your furniture inventory efficiently using barcode scanning and location tracking...',
        author: 'Inventory Lead',
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        views: 840,
        rating: 4.5,
      ),
      KnowledgeArticle(
        id: 'a3',
        title: 'Setting up Automated Workflows',
        category: 'Workflows',
        content: 'Discover how to create AI-driven automated workflows that trigger notifications and approval requests...',
        author: 'Platform Architect',
        lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
        views: 2100,
        rating: 4.9,
      ),
      KnowledgeArticle(
        id: 'a4',
        title: 'Production Routing and BOMs',
        category: 'Production',
        content: 'A comprehensive guide on setting up Bill of Materials (BOM) and routing for manufacturing processes...',
        author: 'Production Manager',
        lastUpdated: DateTime.now().subtract(const Duration(days: 15)),
        views: 630,
        rating: 4.2,
      ),
      KnowledgeArticle(
        id: 'a5',
        title: 'Financial Closing Procedures',
        category: 'Finance',
        content: 'Step-by-step instructions for performing month-end and year-end financial closing in the system...',
        author: 'Finance Controller',
        lastUpdated: DateTime.now().subtract(const Duration(days: 20)),
        views: 450,
        rating: 4.7,
      ),
      KnowledgeArticle(
        id: 'a6',
        title: 'Creating Sales Quotations',
        category: 'Sales',
        content: 'Learn the best practices for generating, approving, and sending sales quotations to customers...',
        author: 'Sales Director',
        lastUpdated: DateTime.now().subtract(const Duration(days: 25)),
        views: 1800,
        rating: 4.6,
        isFavorite: true,
      ),
    ];
  }
}

final aiKnowledgeProvider = NotifierProvider<AIKnowledgeNotifier, AIKnowledgeState>(() {
  return AIKnowledgeNotifier();
});
