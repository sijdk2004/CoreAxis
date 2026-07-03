import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/presentation/widgets/empty_state_widget.dart';

class EmptyStateLibraryScreen extends ConsumerStatefulWidget {
  const EmptyStateLibraryScreen({super.key});

  @override
  ConsumerState<EmptyStateLibraryScreen> createState() => _EmptyStateLibraryScreenState();
}

class _EmptyStateLibraryScreenState extends ConsumerState<EmptyStateLibraryScreen> {
  String _activeDevicePreview = 'Desktop';
  int _activeTabIndex = 0;

  final List<_EmptyStateDemo> _demos = [
    _EmptyStateDemo(
      name: 'No Data (Generic)',
      icon: LucideIcons.database,
      title: 'No Data Available',
      description: 'There is currently no data to display in this view. Check back later or adjust your filters.',
      primaryActionText: 'Refresh',
    ),
    _EmptyStateDemo(
      name: 'No Search Results',
      icon: LucideIcons.searchX,
      title: 'No Results Found',
      description: 'We couldn\'t find anything matching your search query. Try using different keywords.',
      primaryActionText: 'Clear Search',
    ),
    _EmptyStateDemo(
      name: 'No Users',
      icon: LucideIcons.users,
      title: 'No Users Found',
      description: 'There are no active users in this organization. Invite team members to get started.',
      primaryActionText: 'Invite User',
      secondaryActionText: 'Import Users',
    ),
    _EmptyStateDemo(
      name: 'No Tenants',
      icon: LucideIcons.building2,
      title: 'No Tenants Configured',
      description: 'You haven\'t set up any platform tenants yet. Create a tenant to begin onboarding customers.',
      primaryActionText: 'Create Tenant',
    ),
    _EmptyStateDemo(
      name: 'No Organizations',
      icon: LucideIcons.network,
      title: 'No Organizations Found',
      description: 'There are no organizations linked to this account.',
      primaryActionText: 'Add Organization',
    ),
    _EmptyStateDemo(
      name: 'No Workflows',
      icon: LucideIcons.workflow,
      title: 'No Workflows Yet',
      description: 'Create your first workflow to automate your business processes.',
      primaryActionText: 'Create Workflow',
      secondaryActionText: 'View Templates',
    ),
    _EmptyStateDemo(
      name: 'No Reports',
      icon: LucideIcons.pieChart,
      title: 'No Reports Generated',
      description: 'You haven\'t created or saved any analytics reports yet.',
      primaryActionText: 'Create Report',
    ),
    _EmptyStateDemo(
      name: 'No Documents',
      icon: LucideIcons.fileX2,
      title: 'Repository is Empty',
      description: 'There are no documents uploaded in this folder.',
      primaryActionText: 'Upload Document',
      secondaryActionText: 'Create Folder',
    ),
    _EmptyStateDemo(
      name: 'No Notifications',
      icon: LucideIcons.bellOff,
      title: 'You\'re All Caught Up',
      description: 'There are no new notifications or alerts for you at this time.',
    ),
    _EmptyStateDemo(
      name: 'No AI Conversations',
      icon: LucideIcons.messageSquareDashed,
      title: 'No Active Chats',
      description: 'Start a new conversation with the AI Copilot to get insights or automate tasks.',
      primaryActionText: 'New Chat',
    ),
    _EmptyStateDemo(
      name: 'No Industry Packs',
      icon: LucideIcons.packageOpen,
      title: 'No Industry Packs Installed',
      description: 'Enhance your ERP platform by installing an industry-specific module pack.',
      primaryActionText: 'Browse Marketplace',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Empty State Library'),
        centerTitle: false,
        actions: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Desktop', icon: Icon(LucideIcons.monitor, size: 16)),
              ButtonSegment(value: 'Tablet', icon: Icon(LucideIcons.tablet, size: 16)),
              ButtonSegment(value: 'Mobile', icon: Icon(LucideIcons.smartphone, size: 16)),
            ],
            selected: {_activeDevicePreview},
            onSelectionChanged: (set) => setState(() => _activeDevicePreview = set.first),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(right: BorderSide(color: theme.dividerColor)),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _demos.length,
              itemBuilder: (context, index) {
                final demo = _demos[index];
                final isActive = _activeTabIndex == index;
                return ListTile(
                  leading: Icon(demo.icon, color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                  title: Text(demo.name, style: TextStyle(color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                  selected: isActive,
                  selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  onTap: () => setState(() => _activeTabIndex = index),
                );
              },
            ),
          ),
          // Main Content Area
          Expanded(
            child: Center(
              child: Container(
                width: _getPreviewWidth(_activeDevicePreview),
                decoration: _activeDevicePreview != 'Desktop' 
                    ? BoxDecoration(
                        border: Border.all(color: theme.dividerColor, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      )
                    : null,
                clipBehavior: _activeDevicePreview != 'Desktop' ? Clip.hardEdge : Clip.none,
                child: Scaffold(
                  backgroundColor: theme.colorScheme.surface,
                  body: _buildActiveEmptyState(_demos[_activeTabIndex]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double? _getPreviewWidth(String device) {
    switch (device) {
      case 'Mobile': return 375.0;
      case 'Tablet': return 768.0;
      case 'Desktop': default: return null;
    }
  }

  Widget _buildActiveEmptyState(_EmptyStateDemo demo) {
    return PlatformEmptyState(
      icon: demo.icon,
      title: demo.title,
      description: demo.description,
      primaryActionText: demo.primaryActionText,
      onPrimaryAction: demo.primaryActionText != null ? () {} : null,
      secondaryActionText: demo.secondaryActionText,
      onSecondaryAction: demo.secondaryActionText != null ? () {} : null,
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _EmptyStateDemo {
  final String name;
  final IconData icon;
  final String title;
  final String description;
  final String? primaryActionText;
  final String? secondaryActionText;

  _EmptyStateDemo({
    required this.name,
    required this.icon,
    required this.title,
    required this.description,
    this.primaryActionText,
    this.secondaryActionText,
  });
}
