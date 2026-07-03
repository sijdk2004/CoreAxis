import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WhatsNewScreen extends ConsumerWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('What\'s New'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(context, theme),
            const SizedBox(height: 48),
            _buildSectionHeader(theme, 'New Features', LucideIcons.sparkles, Colors.amber),
            const SizedBox(height: 16),
            _buildGridOrList(
              isDesktop,
              [
                _buildFeatureCard(
                  theme,
                  title: 'AI Workflow Assistant',
                  description: 'Automate complex tasks with our new AI-powered workflow assistant. Describe what you want to do, and the assistant will build the workflow for you.',
                  tag: 'Major Release',
                  tagColor: Colors.purple,
                  hasVideo: true,
                  imagePlaceholderIcon: LucideIcons.bot,
                ),
                _buildFeatureCard(
                  theme,
                  title: 'Advanced Analytics Dashboard',
                  description: 'Gain deeper insights with customizable dashboards, real-time metrics, and AI-driven data predictions across all your modules.',
                  tag: 'New',
                  tagColor: Colors.blue,
                  hasImage: true,
                  imagePlaceholderIcon: LucideIcons.barChart3,
                ),
              ],
            ),
            const SizedBox(height: 48),
            _buildSectionHeader(theme, 'Improvements', LucideIcons.trendingUp, Colors.green),
            const SizedBox(height: 16),
            _buildGridOrList(
              isDesktop,
              [
                _buildUpdateCard(theme, 'Faster Document Processing', 'Document OCR and indexing is now up to 40% faster.'),
                _buildUpdateCard(theme, 'Enhanced Role Management', 'Added granular permission controls and matrix views.'),
                _buildUpdateCard(theme, 'UI Responsiveness', 'Improved layout rendering on tablet and mobile devices.'),
              ],
              crossAxisCount: isDesktop ? 3 : 1,
            ),
            const SizedBox(height: 48),
            _buildSectionHeader(theme, 'Bug Fixes', LucideIcons.bug, Colors.red),
            const SizedBox(height: 16),
            _buildGridOrList(
              isDesktop,
              [
                _buildUpdateCard(theme, 'Approval Engine Loop', 'Resolved an issue where multi-step approvals could loop infinitely.'),
                _buildUpdateCard(theme, 'Tenant Switching Delay', 'Fixed a bug causing UI freezes when switching between large tenants.'),
              ],
              crossAxisCount: isDesktop ? 2 : 1,
            ),
            const SizedBox(height: 48),
            _buildSectionHeader(theme, 'Coming Soon', LucideIcons.calendarClock, Colors.orange),
            const SizedBox(height: 16),
            _buildComingSoonCard(theme),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Release 2.4.0',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The AI & Automation Update',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Experience the next generation of enterprise resource planning with our new AI capabilities, enhanced analytics, and massive performance improvements.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.playCircle),
            label: const Text('Watch Release Video'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildGridOrList(bool isDesktop, List<Widget> children, {int crossAxisCount = 2}) {
    if (isDesktop) {
      return GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: crossAxisCount == 2 ? 1.5 : 2.5,
        children: children,
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: children.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => children[index],
      );
    }
  }

  Widget _buildFeatureCard(
    ThemeData theme, {
    required String title,
    required String description,
    required String tag,
    required Color tagColor,
    bool hasVideo = false,
    bool hasImage = false,
    required IconData imagePlaceholderIcon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(imagePlaceholderIcon, size: 64, color: theme.colorScheme.primary.withOpacity(0.3)),
                  if (hasVideo)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.play, color: Colors.white, size: 32),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: tagColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildUpdateCard(ThemeData theme, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildComingSoonCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.rocket, color: theme.colorScheme.primary, size: 32),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enterprise Marketplace',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We are putting the finishing touches on our new add-on marketplace. Discover, install, and manage industry-specific modules directly from the platform.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          OutlinedButton(
            onPressed: () {},
            child: const Text('View Roadmap'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
