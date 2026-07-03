import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

class TourModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const TourModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<TourModel> availableTours = [
  TourModel(
    id: 'dashboard',
    title: 'Dashboard Tour',
    description: 'Learn how to customize widgets, view real-time metrics, and filter data on the main dashboard.',
    icon: LucideIcons.layoutDashboard,
  ),
  TourModel(
    id: 'users',
    title: 'Users & Roles Tour',
    description: 'Explore the user management system, role-based access control, and organization charts.',
    icon: LucideIcons.users,
  ),
  TourModel(
    id: 'workflow',
    title: 'Workflow Automation Tour',
    description: 'See how to drag-and-drop nodes to create complex approval chains and business rules.',
    icon: LucideIcons.workflow,
  ),
  TourModel(
    id: 'reports',
    title: 'Advanced Reports Tour',
    description: 'Discover how to generate, schedule, and export dynamic data visualizations.',
    icon: LucideIcons.barChart4,
  ),
  TourModel(
    id: 'ai',
    title: 'AI Copilot Tour',
    description: 'Interact with our integrated AI assistant to query data and get predictive insights.',
    icon: LucideIcons.sparkles,
  ),
  TourModel(
    id: 'notifications',
    title: 'Notifications Tour',
    description: 'Manage alerts, set up push channels, and review the global audit log.',
    icon: LucideIcons.bell,
  ),
];

class ProductTourLauncherScreen extends ConsumerWidget {
  const ProductTourLauncherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final isMobile = ResponsiveBreakpoints.of(context).equals(MOBILE);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Guided Product Tours'),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a feature to experience an interactive walkthrough.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: isDesktop || !isMobile
                ? SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 2,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _TourCard(tour: availableTours[index]);
                      },
                      childCount: availableTours.length,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _TourCard(tour: availableTours[index]),
                        );
                      },
                      childCount: availableTours.length,
                    ),
                  ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 48)),
        ],
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  final TourModel tour;

  const _TourCard({required this.tour});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
                  child: Icon(
                    tour.icon,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    tour.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Text(
                tour.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  context.push('/platform/tours/${tour.id}');
                },
                child: const Text('Start Tour'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
