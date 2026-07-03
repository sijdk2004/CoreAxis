import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/help_article_model.dart';

final helpCenterSearchProvider = NotifierProvider<SearchNotifier, String>(() => SearchNotifier());

class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
}

final helpArticlesProvider = Provider<List<HelpArticleModel>>((ref) {
  return [
    HelpArticleModel(
      id: '1',
      title: 'Getting Started with CoreAxis',
      summary: 'Learn the basics of navigating the platform and setting up your first workspace.',
      category: HelpCategory.gettingStarted,
      icon: LucideIcons.rocket,
      readTime: '5 min read',
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    HelpArticleModel(
      id: '2',
      title: 'Managing Roles and Permissions',
      summary: 'A deep dive into the RBAC system, creating custom roles, and assigning policies.',
      category: HelpCategory.account,
      icon: LucideIcons.shield,
      readTime: '8 min read',
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    HelpArticleModel(
      id: '3',
      title: 'Workflow Automation Tutorial',
      summary: 'Watch how to build a multi-step approval workflow using the drag-and-drop builder.',
      category: HelpCategory.troubleshooting,
      icon: LucideIcons.playCircle,
      readTime: '12 min watch',
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      isVideo: true,
    ),
    HelpArticleModel(
      id: '4',
      title: 'CoreAxis API v2.0 Reference',
      summary: 'Complete documentation for the new REST API endpoints, including authentication guides.',
      category: HelpCategory.api,
      icon: LucideIcons.code,
      readTime: '15 min read',
      updatedAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    HelpArticleModel(
      id: '5',
      title: 'Platform Update 2026.3',
      summary: 'Release notes covering the new UI components, performance upgrades, and bug fixes.',
      category: HelpCategory.releases,
      icon: LucideIcons.megaphone,
      readTime: '4 min read',
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    HelpArticleModel(
      id: '6',
      title: 'Understanding Billing Cycles',
      summary: 'How to read your invoice, upgrade your tenant tier, and manage payment methods.',
      category: HelpCategory.billing,
      icon: LucideIcons.creditCard,
      readTime: '3 min read',
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];
});

final filteredHelpArticlesProvider = Provider<List<HelpArticleModel>>((ref) {
  final searchQuery = ref.watch(helpCenterSearchProvider).toLowerCase();
  final articles = ref.watch(helpArticlesProvider);

  if (searchQuery.isEmpty) return articles;

  return articles.where((article) {
    return article.title.toLowerCase().contains(searchQuery) ||
           article.summary.toLowerCase().contains(searchQuery);
  }).toList();
});
