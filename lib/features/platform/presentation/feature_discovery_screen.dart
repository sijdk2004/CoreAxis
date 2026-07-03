import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeatureDiscoveryScreen extends ConsumerStatefulWidget {
  const FeatureDiscoveryScreen({super.key});

  @override
  ConsumerState<FeatureDiscoveryScreen> createState() => _FeatureDiscoveryScreenState();
}

class _FeatureDiscoveryScreenState extends ConsumerState<FeatureDiscoveryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Feature Discovery'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Platform'),
            Tab(text: 'Automation'),
            Tab(text: 'Reports'),
            Tab(text: 'AI'),
            Tab(text: 'Industry Packs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryTab(
            context,
            isDesktop,
            [
              _FeatureData(
                title: 'Multi-Tenant Architecture',
                description: 'Manage unlimited organizations and tenants from a single unified codebase with complete data isolation.',
                icon: LucideIcons.building2,
                color: Colors.blue,
              ),
              _FeatureData(
                title: 'Workspace Manager',
                description: 'Create customized work environments tailored for specific roles or teams within your organization.',
                icon: LucideIcons.layoutTemplate,
                color: Colors.indigo,
              ),
              _FeatureData(
                title: 'Role-Based Access Control',
                description: 'Granular permissions matrix and access policies to secure your data and applications.',
                icon: LucideIcons.shieldCheck,
                color: Colors.teal,
              ),
              _FeatureData(
                title: 'Global Search',
                description: 'Instantly find records, documents, and settings across your entire ERP ecosystem.',
                icon: LucideIcons.search,
                color: Colors.cyan,
              ),
            ],
          ),
          _buildCategoryTab(
            context,
            isDesktop,
            [
              _FeatureData(
                title: 'Visual Workflow Builder',
                description: 'Design complex business processes using an intuitive drag-and-drop interface.',
                icon: LucideIcons.workflow,
                color: Colors.orange,
              ),
              _FeatureData(
                title: 'Approval Engine',
                description: 'Configure multi-tier approval chains with conditional logic and escalations.',
                icon: LucideIcons.checkSquare,
                color: Colors.deepOrange,
              ),
              _FeatureData(
                title: 'Notification Center',
                description: 'Automate email, SMS, and in-app alerts based on system events and data changes.',
                icon: LucideIcons.bellRing,
                color: Colors.amber,
              ),
            ],
          ),
          _buildCategoryTab(
            context,
            isDesktop,
            [
              _FeatureData(
                title: 'Dashboard Builder',
                description: 'Create custom analytics dashboards with drag-and-drop widgets and real-time data.',
                icon: LucideIcons.layoutDashboard,
                color: Colors.green,
              ),
              _FeatureData(
                title: 'Report Generator',
                description: 'Export and schedule automated reports in PDF, Excel, and CSV formats.',
                icon: LucideIcons.fileSpreadsheet,
                color: Colors.lightGreen,
              ),
            ],
          ),
          _buildCategoryTab(
            context,
            isDesktop,
            [
              _FeatureData(
                title: 'AI Workflow Assistant',
                description: 'Use natural language to automatically generate complex automated workflows.',
                icon: LucideIcons.bot,
                color: Colors.purple,
              ),
              _FeatureData(
                title: 'Predictive Analytics',
                description: 'Leverage machine learning to forecast trends and optimize business operations.',
                icon: LucideIcons.lineChart,
                color: Colors.deepPurple,
              ),
              _FeatureData(
                title: 'Document OCR',
                description: 'Automatically extract data from invoices and receipts using AI vision models.',
                icon: LucideIcons.scanLine,
                color: Colors.pink,
              ),
            ],
          ),
          _buildCategoryTab(
            context,
            isDesktop,
            [
              _FeatureData(
                title: 'Manufacturing Pack',
                description: 'Pre-configured workflows and reports tailored for the manufacturing industry.',
                icon: LucideIcons.factory,
                color: Colors.brown,
              ),
              _FeatureData(
                title: 'Logistics Pack',
                description: 'Supply chain management, inventory tracking, and fleet management presets.',
                icon: LucideIcons.truck,
                color: Colors.blueGrey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(BuildContext context, bool isDesktop, List<_FeatureData> features) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(context),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 1,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: isDesktop ? 1.2 : 1.5,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              return _buildFeatureCard(context, features[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover Platform Capabilities',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore the powerful tools and engines that drive the CoreAxis ERP platform.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureData feature, int index) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${feature.title}...'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feature.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(feature.icon, color: feature.color, size: 32),
              ),
              const SizedBox(height: 24),
              Text(
                feature.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  feature.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Open Feature',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(LucideIcons.arrowRight, size: 16, color: theme.colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (100 * index).ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _FeatureData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _FeatureData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
