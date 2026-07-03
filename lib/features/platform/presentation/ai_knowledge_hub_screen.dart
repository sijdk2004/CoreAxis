import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'providers/ai_knowledge_provider.dart';
import 'models/ai_knowledge_model.dart';
import 'package:intl/intl.dart';

class AiKnowledgeHubScreen extends ConsumerWidget {
  const AiKnowledgeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(aiKnowledgeProvider);
    final notifier = ref.read(aiKnowledgeProvider.notifier);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, theme, state, notifier),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop) _buildSidebar(context, theme, state, notifier),
                if (isDesktop) const VerticalDivider(width: 1),
                Expanded(
                  child: _buildMainContent(context, theme, state, notifier, isDesktop),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, AIKnowledgeState state, AIKnowledgeNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.bookOpen, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Knowledge Hub',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Central knowledge repository for ERP users',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSearchBar(context, theme, state, notifier),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme, AIKnowledgeState state, AIKnowledgeNotifier notifier) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      child: SearchBar(
        hintText: 'Search documentation, workflows, FAQs...',
        leading: Icon(LucideIcons.search, color: theme.colorScheme.onSurfaceVariant),
        trailing: [
          IconButton(
            icon: Icon(LucideIcons.slidersHorizontal, color: theme.colorScheme.primary),
            onPressed: () {},
            tooltip: 'Advanced Filters',
          ),
        ],
        onChanged: notifier.setSearchQuery,
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, ThemeData theme, AIKnowledgeState state, AIKnowledgeNotifier notifier) {
    return SizedBox(
      width: 280,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSidebarSectionTitle(theme, 'BROWSE CATEGORIES'),
          ...state.categories.map((category) => _buildSidebarItem(theme, state, notifier, category)),
          const Divider(height: 32),
          _buildSidebarSectionTitle(theme, 'QUICK LINKS'),
          _buildQuickLinkItem(theme, LucideIcons.star, 'Favorites', () {
            notifier.setCategory('Favorites');
          }, state.selectedCategory == 'Favorites'),
          _buildQuickLinkItem(theme, LucideIcons.clock, 'Recently Viewed', () {}, false),
        ],
      ),
    );
  }

  Widget _buildSidebarSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSidebarItem(ThemeData theme, AIKnowledgeState state, AIKnowledgeNotifier notifier, KnowledgeCategory category) {
    final isSelected = state.selectedCategory == category.name;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(
        _getIconForCategory(category.icon),
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      title: Text(
        category.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Text(
        '${category.articleCount}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
      onTap: () {
        if (isSelected) {
          notifier.setCategory(null);
        } else {
          notifier.setCategory(category.name);
        }
      },
    );
  }

  Widget _buildQuickLinkItem(ThemeData theme, IconData icon, String title, VoidCallback onTap, bool isSelected) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
      onTap: onTap,
    );
  }

  Widget _buildMainContent(BuildContext context, ThemeData theme, AIKnowledgeState state, AIKnowledgeNotifier notifier, bool isDesktop) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (state.searchQuery.isEmpty && state.selectedCategory == null) ...[
          _buildSectionHeader(theme, 'Suggested Articles', LucideIcons.sparkles),
          const SizedBox(height: 16),
          _buildSuggestedArticlesGrid(context, theme, state, notifier, isDesktop),
          const SizedBox(height: 32),
        ],
        _buildSectionHeader(
          theme, 
          state.searchQuery.isNotEmpty 
              ? 'Search Results for "${state.searchQuery}"' 
              : (state.selectedCategory ?? 'All Articles'), 
          LucideIcons.fileText
        ),
        const SizedBox(height: 16),
        _buildArticlesList(context, theme, state, notifier),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedArticlesGrid(BuildContext context, ThemeData theme, AIKnowledgeState state, AIKnowledgeNotifier notifier, bool isDesktop) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.5 : 2.5,
      ),
      itemCount: state.suggestedArticles.length,
      itemBuilder: (context, index) {
        return _buildArticleCard(context, theme, state.suggestedArticles[index], notifier);
      },
    );
  }

  Widget _buildArticleCard(BuildContext context, ThemeData theme, KnowledgeArticle article, AIKnowledgeNotifier notifier) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      article.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      article.isFavorite ? LucideIcons.star : LucideIcons.star,
                      size: 18,
                      color: article.isFavorite ? Colors.orange : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => notifier.toggleFavorite(article.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  article.content,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(LucideIcons.eye, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${article.views}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(LucideIcons.calendar, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(article.lastUpdated),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticlesList(BuildContext context, ThemeData theme, AIKnowledgeState state, AIKnowledgeNotifier notifier) {
    final articles = state.selectedCategory == 'Favorites' ? state.favoriteArticles : state.filteredArticles;
    
    if (articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.searchX, size: 48, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                'No articles found',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or category filter',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: articles.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final article = articles[index];
        return InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.fileText, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              article.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              article.isFavorite ? LucideIcons.star : LucideIcons.star,
                              size: 20,
                              color: article.isFavorite ? Colors.orange : theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () => notifier.toggleFavorite(article.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              article.category,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(LucideIcons.user, size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            article.author,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(LucideIcons.calendar, size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, yyyy').format(article.lastUpdated),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName) {
      case 'book': return LucideIcons.book;
      case 'package': return LucideIcons.package;
      case 'git-merge': return LucideIcons.gitMerge;
      case 'shield': return LucideIcons.shield;
      case 'help-circle': return LucideIcons.helpCircle;
      case 'video': return LucideIcons.video;
      case 'layout': return LucideIcons.layout;
      case 'box': return LucideIcons.box;
      case 'database': return LucideIcons.database;
      case 'settings': return LucideIcons.settings;
      case 'dollar-sign': return LucideIcons.dollarSign;
      case 'shopping-cart': return LucideIcons.shoppingCart;
      default: return LucideIcons.folder;
    }
  }
}
