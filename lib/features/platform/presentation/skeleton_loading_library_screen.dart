import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/presentation/widgets/skeleton_loader.dart';

class SkeletonLoadingLibraryScreen extends ConsumerStatefulWidget {
  const SkeletonLoadingLibraryScreen({super.key});

  @override
  ConsumerState<SkeletonLoadingLibraryScreen> createState() => _SkeletonLoadingLibraryScreenState();
}

class _SkeletonLoadingLibraryScreenState extends ConsumerState<SkeletonLoadingLibraryScreen> {
  String _activeDevicePreview = 'Desktop';
  SkeletonAnimation _activeAnimation = SkeletonAnimation.shimmer;
  int _activeTabIndex = 0;

  final List<_SkeletonDemo> _demos = [
    _SkeletonDemo(name: 'Dashboard', icon: LucideIcons.layoutDashboard),
    _SkeletonDemo(name: 'Card', icon: LucideIcons.creditCard),
    _SkeletonDemo(name: 'Table', icon: LucideIcons.table),
    _SkeletonDemo(name: 'Form', icon: LucideIcons.formInput),
    _SkeletonDemo(name: 'Sidebar', icon: LucideIcons.panelLeft),
    _SkeletonDemo(name: 'Chart', icon: LucideIcons.barChart2),
    _SkeletonDemo(name: 'Profile', icon: LucideIcons.user),
    _SkeletonDemo(name: 'Wizard', icon: LucideIcons.fastForward),
    _SkeletonDemo(name: 'Document', icon: LucideIcons.fileText),
    _SkeletonDemo(name: 'Report', icon: LucideIcons.pieChart),
    _SkeletonDemo(name: 'Workflow Canvas', icon: LucideIcons.workflow),
    _SkeletonDemo(name: 'AI Chat', icon: LucideIcons.messageSquareDashed),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Skeleton Loading Library'),
        centerTitle: false,
        actions: [
          SegmentedButton<SkeletonAnimation>(
            segments: const [
              ButtonSegment(value: SkeletonAnimation.shimmer, label: Text('Shimmer')),
              ButtonSegment(value: SkeletonAnimation.fade, label: Text('Fade')),
              ButtonSegment(value: SkeletonAnimation.pulse, label: Text('Pulse')),
            ],
            selected: {_activeAnimation},
            onSelectionChanged: (set) => setState(() => _activeAnimation = set.first),
          ),
          const SizedBox(width: 24),
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
                height: double.infinity,
                margin: const EdgeInsets.all(24),
                decoration: _activeDevicePreview != 'Desktop' 
                    ? BoxDecoration(
                        border: Border.all(color: theme.dividerColor, width: 2),
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.surface,
                      )
                    : BoxDecoration(color: theme.colorScheme.surface),
                clipBehavior: _activeDevicePreview != 'Desktop' ? Clip.hardEdge : Clip.none,
                child: Scaffold(
                  backgroundColor: theme.colorScheme.surface,
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildActiveLoader(_demos[_activeTabIndex].name),
                  ),
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

  Widget _buildActiveLoader(String name) {
    switch (name) {
      case 'Dashboard': return SkeletonDashboardLoader(animation: _activeAnimation);
      case 'Card': return SkeletonCardLoader(animation: _activeAnimation);
      case 'Table': return SkeletonTableLoader(animation: _activeAnimation);
      case 'Form': return SkeletonFormLoader(animation: _activeAnimation);
      case 'Sidebar': return SkeletonSidebarLoader(animation: _activeAnimation);
      case 'Chart': return SkeletonChartLoader(animation: _activeAnimation);
      case 'Profile': return SkeletonProfileLoader(animation: _activeAnimation);
      case 'Wizard': return SkeletonWizardLoader(animation: _activeAnimation);
      case 'Document': return SkeletonDocumentLoader(animation: _activeAnimation);
      case 'Report': return SkeletonReportLoader(animation: _activeAnimation);
      case 'Workflow Canvas': return SkeletonWorkflowCanvasLoader(animation: _activeAnimation);
      case 'AI Chat': return SkeletonAIChatLoader(animation: _activeAnimation);
      default: return const SizedBox.shrink();
    }
  }
}

class _SkeletonDemo {
  final String name;
  final IconData icon;

  _SkeletonDemo({required this.name, required this.icon});
}
