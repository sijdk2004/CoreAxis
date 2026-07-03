import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReleaseShowcaseScreen extends ConsumerStatefulWidget {
  const ReleaseShowcaseScreen({super.key});

  @override
  ConsumerState<ReleaseShowcaseScreen> createState() => _ReleaseShowcaseScreenState();
}

class _ReleaseShowcaseScreenState extends ConsumerState<ReleaseShowcaseScreen> {
  int _selectedReleaseIndex = 0;

  final List<_ReleaseData> _releases = [
    _ReleaseData(
      version: 'v2.4.0',
      date: 'July 1, 2026',
      title: 'The Automation Engine Update',
      description: 'A massive leap forward in enterprise automation, introducing visual workflow builders and AI-assisted task generation.',
      highlights: [
        'Visual Drag-and-Drop Workflow Builder',
        'AI Workflow Assistant Integration',
        'Advanced Approval Chains',
        'Real-time Execution Analytics',
      ],
      hasVideo: true,
      hasScreenshots: true,
      tag: 'Major Release',
    ),
    _ReleaseData(
      version: 'v2.3.0',
      date: 'May 15, 2026',
      title: 'Global Analytics & Reporting',
      description: 'Complete overhaul of the reporting engine with new customizable dashboards and real-time data streaming.',
      highlights: [
        'Custom Dashboard Builder',
        'Scheduled PDF/Excel Reports',
        'Cross-tenant Data Aggregation',
      ],
      hasVideo: false,
      hasScreenshots: true,
      tag: 'Feature Update',
    ),
    _ReleaseData(
      version: 'v2.2.0',
      date: 'March 10, 2026',
      title: 'Enterprise Security Pack',
      description: 'Enhanced security features including granular RBAC matrices, audit logging, and automated compliance reports.',
      highlights: [
        'Role-Permission Matrix Viewer',
        'Immutable Audit Trails',
        'SOC2 Compliance Report Templates',
      ],
      hasVideo: false,
      hasScreenshots: false,
      tag: 'Security Update',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Release Showcase'),
        centerTitle: false,
      ),
      body: isDesktop ? _buildDesktopLayout(theme) : _buildMobileLayout(theme),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Sidebar
        Container(
          width: 300,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: _buildTimelineList(theme),
        ),
        // Release Details
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: _buildReleaseDetails(theme, _releases[_selectedReleaseIndex]),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: _buildTimelineHorizontal(theme),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildReleaseDetails(theme, _releases[_selectedReleaseIndex]),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _releases.length,
      itemBuilder: (context, index) {
        final release = _releases[index];
        final isSelected = _selectedReleaseIndex == index;
        return InkWell(
          onTap: () => setState(() => _selectedReleaseIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.5) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: theme.colorScheme.primary.withOpacity(0.5)) : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        release.version,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        release.date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms);
      },
    );
  }

  Widget _buildTimelineHorizontal(ThemeData theme) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      itemCount: _releases.length,
      itemBuilder: (context, index) {
        final release = _releases[index];
        final isSelected = _selectedReleaseIndex == index;
        return InkWell(
          onTap: () => setState(() => _selectedReleaseIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            width: 150,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.5) : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: theme.colorScheme.primary.withOpacity(0.5)) : Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  release.version,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  release.date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms);
      },
    );
  }

  Widget _buildReleaseDetails(ThemeData theme, _ReleaseData release) {
    return Column(
      key: ValueKey(release.version),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            release.tag,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${release.version}: ${release.title}',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          release.description,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.fileText),
              label: const Text('Read Documentation'),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.listTree),
              label: const Text('Full Changelog'),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Text(
          'Release Highlights',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...release.highlights.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(LucideIcons.checkCircle2, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    h,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            )),
        const SizedBox(height: 48),
        if (release.hasVideo) ...[
          Text(
            'Feature Overview (Mock Video)',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(LucideIcons.video, size: 64, color: theme.colorScheme.primary.withOpacity(0.3)),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.play, color: Colors.white, size: 48),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
        if (release.hasScreenshots) ...[
          Text(
            'Screenshots',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: ResponsiveBreakpoints.of(context).largerThan(TABLET) ? 2 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 1.5,
            children: [
              _buildMockScreenshot(theme, 'Dashboard View', LucideIcons.layoutDashboard),
              _buildMockScreenshot(theme, 'Settings Panel', LucideIcons.settings),
            ],
          ),
        ],
        const SizedBox(height: 48),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildMockScreenshot(ThemeData theme, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Center(
            child: Icon(icon, size: 64, color: theme.colorScheme.primary.withOpacity(0.2)),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.9),
              child: Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReleaseData {
  final String version;
  final String date;
  final String title;
  final String description;
  final List<String> highlights;
  final bool hasVideo;
  final bool hasScreenshots;
  final String tag;

  _ReleaseData({
    required this.version,
    required this.date,
    required this.title,
    required this.description,
    required this.highlights,
    required this.hasVideo,
    required this.hasScreenshots,
    required this.tag,
  });
}
