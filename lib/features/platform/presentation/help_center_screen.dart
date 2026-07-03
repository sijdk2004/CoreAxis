import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import 'providers/help_center_provider.dart';
import 'models/help_article_model.dart';

class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Help Center'),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.messageCircle),
            label: const Text('Contact Support'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context, theme, ref),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickLinksGrid(context, theme, isDesktop),
                  const SizedBox(height: 64),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildArticleList(context, theme, ref, 'Popular Articles')),
                        const SizedBox(width: 64),
                        Expanded(flex: 1, child: _buildArticleList(context, theme, ref, 'Recent Updates', isRecent: true)),
                      ],
                    )
                  else ...[
                    _buildArticleList(context, theme, ref, 'Popular Articles'),
                    const SizedBox(height: 48),
                    _buildArticleList(context, theme, ref, 'Recent Updates', isRecent: true),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Text(
            'How can we help you?',
            style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: TextField(
              onChanged: (value) => ref.read(helpCenterSearchProvider.notifier).updateQuery(value),
              decoration: InputDecoration(
                hintText: 'Search for articles, tutorials, or FAQs...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 24, right: 12),
                  child: Icon(LucideIcons.search),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinksGrid(BuildContext context, ThemeData theme, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isDesktop ? 3 : 2;
        if (constraints.maxWidth < 500) crossAxisCount = 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: isDesktop ? 2.5 : 2.0,
          children: [
            _buildQuickLinkCard(theme, 'Documentation', 'Comprehensive guides and API references.', LucideIcons.bookOpen),
            _buildQuickLinkCard(theme, 'Video Tutorials', 'Step-by-step visual learning.', LucideIcons.video),
            _buildQuickLinkCard(theme, 'FAQs', 'Answers to common platform questions.', LucideIcons.helpCircle),
            _buildQuickLinkCard(theme, 'Knowledge Base', 'In-depth articles by our experts.', LucideIcons.libraryBig),
            _buildQuickLinkCard(theme, 'Release Notes', 'What\'s new in the latest versions.', LucideIcons.megaphone),
            _buildQuickLinkCard(theme, 'Community Forum', 'Connect with other CoreAxis users.', LucideIcons.users),
          ],
        );
      },
    );
  }

  Widget _buildQuickLinkCard(ThemeData theme, String title, String subtitle, IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleList(BuildContext context, ThemeData theme, WidgetRef ref, String title, {bool isRecent = false}) {
    final articles = ref.watch(filteredHelpArticlesProvider);
    
    // For mock purposes, just take the first half for Popular and second half for Recent if not searching
    final isSearching = ref.watch(helpCenterSearchProvider).isNotEmpty;
    List<HelpArticleModel> displayList = articles;
    
    if (!isSearching && articles.length >= 4) {
      if (isRecent) {
        displayList = articles.sublist(articles.length ~/ 2);
      } else {
        displayList = articles.sublist(0, articles.length ~/ 2);
      }
    }

    if (displayList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Text('No articles found matching your criteria.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayList.length,
          separatorBuilder: (context, index) => const Divider(height: 32),
          itemBuilder: (context, index) {
            final article = displayList[index];
            return InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(article.icon, color: theme.colorScheme.primary, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(article.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(article.summary, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              if (article.isVideo) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('Video', style: TextStyle(fontSize: 12, color: Colors.red.shade900, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Text(article.readTime, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                              const SizedBox(width: 12),
                              Text('•', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              const SizedBox(width: 12),
                              Text('Updated ${DateFormat.yMMMd().format(article.updatedAt)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
        ),
      ],
    );
  }
}
