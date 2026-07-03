import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'providers/presentation_mode_provider.dart';

class PresentationModeScreen extends ConsumerStatefulWidget {
  const PresentationModeScreen({super.key});

  @override
  ConsumerState<PresentationModeScreen> createState() => _PresentationModeScreenState();
}

class _PresentationModeScreenState extends ConsumerState<PresentationModeScreen> {
  Offset _pointerPosition = Offset.zero;
  bool _showToolbar = true;

  final List<String> _modules = [
    'Executive Dashboard',
    'Financial Overview',
    'Operational Analytics',
    'System Health',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(presentationModeProvider);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FocusableActionDetector(
        autofocus: true,
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.arrowRight): const NextSlideIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowLeft): const PreviousSlideIntent(),
          LogicalKeySet(LogicalKeyboardKey.escape): const ExitPresentationIntent(),
        },
        actions: {
          NextSlideIntent: CallbackAction<NextSlideIntent>(
            onInvoke: (_) => ref.read(presentationModeProvider.notifier).nextModule(_modules.length),
          ),
          PreviousSlideIntent: CallbackAction<PreviousSlideIntent>(
            onInvoke: (_) => ref.read(presentationModeProvider.notifier).previousModule(),
          ),
          ExitPresentationIntent: CallbackAction<ExitPresentationIntent>(
            onInvoke: (_) => context.go('/platform/home'),
          ),
        },
        child: MouseRegion(
          onHover: (event) {
            if (state.isLaserPointerActive) {
              setState(() {
                _pointerPosition = event.position;
              });
            }
          },
          child: Stack(
            children: [
              // Main Content Area (Zoomable)
              AnimatedScale(
                scale: state.zoomLevel,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Center(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _modules[state.currentModuleIndex],
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),
                        const SizedBox(height: 16),
                        Container(
                          width: 100,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ).animate().scaleX(begin: 0, duration: 400.ms, delay: 200.ms),
                        const SizedBox(height: 48),
                        Expanded(
                          child: _buildCurrentModuleContent(theme, state.currentModuleIndex),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Focus Mode Overlay
              if (state.isFocusModeActive)
                IgnorePointer(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: Container(
                        width: 800,
                        height: 500,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: theme.colorScheme.primary, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 50,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(1.1, 1.1)),
                    ),
                  ),
                ),

              // Mock Laser Pointer
              if (state.isLaserPointerActive)
                Positioned(
                  left: _pointerPosition.dx - 8,
                  top: _pointerPosition.dy - 8,
                  child: IgnorePointer(
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withValues(alpha: 0.6),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Floating Toolbar
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _showToolbar = true),
                    onExit: (_) => setState(() => _showToolbar = true), // Keep visible for now for ease of use
                    child: AnimatedOpacity(
                      opacity: _showToolbar ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.chevronLeft),
                              onPressed: state.currentModuleIndex > 0
                                  ? () => ref.read(presentationModeProvider.notifier).previousModule()
                                  : null,
                              tooltip: 'Previous Slide',
                            ),
                            Text('${state.currentModuleIndex + 1} / ${_modules.length}'),
                            IconButton(
                              icon: const Icon(LucideIcons.chevronRight),
                              onPressed: state.currentModuleIndex < _modules.length - 1
                                  ? () => ref.read(presentationModeProvider.notifier).nextModule(_modules.length)
                                  : null,
                              tooltip: 'Next Slide',
                            ),
                            const SizedBox(width: 16),
                            Container(width: 1, height: 24, color: theme.dividerColor),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: Icon(
                                LucideIcons.mousePointer2,
                                color: state.isLaserPointerActive ? Colors.redAccent : null,
                              ),
                              onPressed: () => ref.read(presentationModeProvider.notifier).toggleLaserPointer(),
                              tooltip: 'Toggle Laser Pointer',
                            ),
                            IconButton(
                              icon: Icon(
                                LucideIcons.scanLine,
                                color: state.isFocusModeActive ? theme.colorScheme.primary : null,
                              ),
                              onPressed: () => ref.read(presentationModeProvider.notifier).toggleFocusMode(),
                              tooltip: 'Toggle Focus Mode',
                            ),
                            const SizedBox(width: 16),
                            Container(width: 1, height: 24, color: theme.dividerColor),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(LucideIcons.zoomOut),
                              onPressed: () => ref.read(presentationModeProvider.notifier).setZoomLevel(state.zoomLevel - 0.1),
                              tooltip: 'Zoom Out',
                            ),
                            Text('${(state.zoomLevel * 100).round()}%'),
                            IconButton(
                              icon: const Icon(LucideIcons.zoomIn),
                              onPressed: () => ref.read(presentationModeProvider.notifier).setZoomLevel(state.zoomLevel + 0.1),
                              tooltip: 'Zoom In',
                            ),
                            const SizedBox(width: 16),
                            Container(width: 1, height: 24, color: theme.dividerColor),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(LucideIcons.x),
                              onPressed: () => context.go('/platform/home'),
                              tooltip: 'Exit Presentation',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentModuleContent(ThemeData theme, int index) {
    // Return different mock layouts based on the current slide/module
    switch (index) {
      case 0: // Executive Dashboard
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildMockMetricCard(theme, 'Total Active Tenants', '1,248', LucideIcons.building, '+12%')),
                const SizedBox(width: 24),
                Expanded(child: _buildMockMetricCard(theme, 'System ARR', '\$4.2M', LucideIcons.dollarSign, '+5%')),
                const SizedBox(width: 24),
                Expanded(child: _buildMockMetricCard(theme, 'Active Users', '45,912', LucideIcons.users, '+2%')),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 2, child: _buildMockChart(theme)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildMockActivityList(theme)),
                ],
              ),
            ),
          ],
        );
      case 1: // Financial Overview
        return _buildBigIconScreen(theme, LucideIcons.pieChart, 'Financial Modules', 'Showcasing multi-tenant billing and invoicing.');
      case 2: // Operational Analytics
        return _buildBigIconScreen(theme, LucideIcons.workflow, 'Workflow Automations', 'Highlighting supply chain and operational bottlenecks.');
      case 3: // System Health
        return _buildBigIconScreen(theme, LucideIcons.activity, 'System Health', 'Live view of server and database performance.');
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMockMetricCard(ThemeData theme, String title, String value, IconData icon, String trend) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(trend, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Spacer(),
            Text(title, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMockChart(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      child: Center(
        child: Icon(LucideIcons.barChart3, size: 120, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
    );
  }

  Widget _buildMockActivityList(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: 5,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) => ListTile(
          leading: const CircleAvatar(child: Icon(LucideIcons.user)),
          title: Text('User Action ${index + 1}'),
          subtitle: Text('Performed ${index + 2} minutes ago'),
        ),
      ),
    );
  }

  Widget _buildBigIconScreen(ThemeData theme, IconData icon, String title, String subtitle) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 120, color: theme.colorScheme.primary),
            const SizedBox(height: 32),
            Text(title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class NextSlideIntent extends Intent {
  const NextSlideIntent();
}

class PreviousSlideIntent extends Intent {
  const PreviousSlideIntent();
}

class ExitPresentationIntent extends Intent {
  const ExitPresentationIntent();
}
