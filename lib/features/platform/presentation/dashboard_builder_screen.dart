import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../domain/dashboard_builder_model.dart';
import 'providers/dashboard_builder_provider.dart';

class DashboardBuilderScreen extends ConsumerWidget {
  const DashboardBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardBuilderProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      body: Column(
        children: [
          _buildToolbar(context, ref, theme, state),
          Expanded(
            child: Row(
              children: [
                _buildLeftPanel(context, ref, theme, state),
                Expanded(
                  child: _buildCanvas(context, ref, theme, state),
                ),
                _buildRightPanel(context, ref, theme, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref, ThemeData theme, DashboardBuilderState state) {
    final notifier = ref.read(dashboardBuilderProvider.notifier);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.layoutDashboard, size: 24),
          const SizedBox(width: 12),
          Text('Dashboard Builder', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: Icon(LucideIcons.undo2),
            onPressed: state.historyIndex > 0 ? () => notifier.undo() : null,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: Icon(LucideIcons.redo2),
            onPressed: state.historyIndex < state.history.length - 1 ? () => notifier.redo() : null,
            tooltip: 'Redo',
          ),
          const SizedBox(width: 16),
          FilledButton.tonalIcon(
            onPressed: () => notifier.togglePreviewMode(),
            icon: Icon(state.isPreviewMode ? LucideIcons.edit3 : LucideIcons.eye),
            label: Text(state.isPreviewMode ? 'Edit Mode' : 'Preview'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dashboard saved successfully.')));
            },
            icon: Icon(LucideIcons.save),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dashboard published.')));
            },
            icon: Icon(LucideIcons.uploadCloud),
            label: const Text('Publish'),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(LucideIcons.download),
            tooltip: 'Export',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dashboard exported.')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context, WidgetRef ref, ThemeData theme, DashboardBuilderState state) {
    if (state.isPreviewMode) return const SizedBox.shrink();

    return Container(
      width: 280,
      color: theme.colorScheme.surface,
      child: ListView(
        children: [
          ExpansionTile(
            title: const Text('Widgets', style: TextStyle(fontWeight: FontWeight.bold)),
            initiallyExpanded: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: DashboardWidgetType.values.map((type) => _buildDraggableWidgetIcon(theme, type)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableWidgetIcon(ThemeData theme, DashboardWidgetType type) {
    return Draggable<DashboardWidgetType>(
      data: type,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(type.icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(type.label, style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      child: Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, size: 28, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(type.label, style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas(BuildContext context, WidgetRef ref, ThemeData theme, DashboardBuilderState state) {
    return DragTarget<DashboardWidgetType>(
      onAcceptWithDetails: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.offset);
        final adjustedPosition = Offset(localPosition.dx - 50, localPosition.dy - 40);
        
        ref.read(dashboardBuilderProvider.notifier).addWidget(details.data, adjustedPosition);
      },
      builder: (BuildContext context, List<DashboardWidgetType?> candidateData, List<dynamic> rejectedData) {
        return GestureDetector(
          onTap: () {
            if (!state.isPreviewMode) {
              ref.read(dashboardBuilderProvider.notifier).selectWidget(null);
            }
          },
          child: Container(
            color: candidateData.isNotEmpty ? theme.colorScheme.primaryContainer.withOpacity(0.3) : Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (!state.isPreviewMode)
                  CustomPaint(
                    size: Size.infinite,
                    painter: GridPainter(theme.dividerColor.withOpacity(0.3)),
                  ),
                ...state.widgets.map((widget) => _buildWidget(context, ref, theme, widget, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWidget(BuildContext context, WidgetRef ref, ThemeData theme, DashboardWidgetConfig widget, DashboardBuilderState state) {
    final isSelected = state.selectedWidgetId == widget.id;

    final content = Container(
      width: widget.size.width,
      height: widget.size.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isSelected && !state.isPreviewMode 
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(widget.type.icon, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (isSelected && !state.isPreviewMode)
                  IconButton(
                    icon: Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => ref.read(dashboardBuilderProvider.notifier).removeWidget(widget.id),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _buildMockWidgetContent(theme, widget),
          ),
        ],
      ),
    );

    if (state.isPreviewMode) {
      return Positioned(
        left: widget.position.dx,
        top: widget.position.dy,
        child: content,
      );
    }

    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onTap: () => ref.read(dashboardBuilderProvider.notifier).selectWidget(widget.id),
        onPanUpdate: (details) {
          ref.read(dashboardBuilderProvider.notifier).selectWidget(widget.id);
          ref.read(dashboardBuilderProvider.notifier).updateWidgetPosition(
                widget.id,
                Offset(widget.position.dx + details.delta.dx, widget.position.dy + details.delta.dy),
              );
        },
        onPanEnd: (details) {
          ref.read(dashboardBuilderProvider.notifier).commitWidgetMove();
        },
        child: Stack(
          children: [
            content,
            if (isSelected)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    final newWidth = (widget.size.width + details.delta.dx).clamp(200.0, 1200.0);
                    final newHeight = (widget.size.height + details.delta.dy).clamp(150.0, 800.0);
                    ref.read(dashboardBuilderProvider.notifier).updateWidgetSize(
                          widget.id,
                          Size(newWidth, newHeight),
                        );
                  },
                  onPanEnd: (details) {
                    ref.read(dashboardBuilderProvider.notifier).commitWidgetMove();
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Icon(LucideIcons.scaling, size: 16, color: theme.colorScheme.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockWidgetContent(ThemeData theme, DashboardWidgetConfig widget) {
    if (widget.dataSourceId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.database, size: 32, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No Data Source Selected',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a Data Source from the Properties panel.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    switch (widget.type) {
      case DashboardWidgetType.kpiCard:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\$1.2M', style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.trendingUp, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('+12% vs last month', style: theme.textTheme.bodySmall?.copyWith(color: Colors.green)),
                ],
              )
            ],
          ),
        );
      case DashboardWidgetType.chart:
      case DashboardWidgetType.heatmap:
      case DashboardWidgetType.timeline:
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.dividerColor),
              left: BorderSide(color: theme.dividerColor),
            ),
          ),
          child: Stack(
            children: [
              Positioned(bottom: 20, left: 10, child: Container(width: 30, height: 100, color: theme.colorScheme.primary.withOpacity(0.6))),
              Positioned(bottom: 20, left: 60, child: Container(width: 30, height: 160, color: theme.colorScheme.primary.withOpacity(0.8))),
              Positioned(bottom: 20, left: 110, child: Container(width: 30, height: 80, color: theme.colorScheme.primary.withOpacity(0.4))),
              Positioned(bottom: 20, left: 160, child: Container(width: 30, height: 210, color: theme.colorScheme.primary)),
            ],
          ),
        );
      case DashboardWidgetType.table:
      case DashboardWidgetType.pivot:
        return ListView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(child: Container(height: 20, color: theme.colorScheme.surfaceContainerHighest)),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 20, color: theme.colorScheme.surfaceContainerHighest)),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 20, color: theme.colorScheme.surfaceContainerHighest)),
                ],
              ),
            );
          },
        );
      case DashboardWidgetType.map:
        return Center(child: Icon(LucideIcons.map, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)));
      case DashboardWidgetType.gauge:
        return Center(
          child: Container(
            width: 150,
            height: 75,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.colorScheme.primary, width: 10),
                left: BorderSide(color: theme.colorScheme.primary, width: 10),
                right: BorderSide(color: theme.colorScheme.primary, width: 10),
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(150)),
            ),
          ),
        );
      case DashboardWidgetType.calendar:
        return Center(child: Icon(LucideIcons.calendar, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)));
    }
  }

  Widget _buildRightPanel(BuildContext context, WidgetRef ref, ThemeData theme, DashboardBuilderState state) {
    if (state.isPreviewMode) return const SizedBox.shrink();

    final selectedWidget = state.selectedWidgetId != null
        ? state.widgets.firstWhere((c) => c.id == state.selectedWidgetId, orElse: () => state.widgets.first)
        : null;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(left: BorderSide(color: theme.dividerColor)),
      ),
      child: selectedWidget == null
          ? Center(
              child: Text(
                'Select a widget to edit properties',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Properties', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildPropertySection(
                  theme,
                  'General',
                  [
                    _buildTextField(
                      theme,
                      label: 'Title',
                      value: selectedWidget.title,
                      onChanged: (val) => ref.read(dashboardBuilderProvider.notifier).updateWidgetProperty(selectedWidget.id, 'title', val),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildPropertySection(
                  theme,
                  'Data Source',
                  [
                    _buildDropdown(
                      theme,
                      label: 'Source',
                      value: selectedWidget.dataSourceId,
                      items: ref.read(dashboardBuilderProvider.notifier).availableDataSources.map((ds) {
                        return DropdownMenuItem<String>(
                          value: ds.id,
                          child: Text(ds.name),
                        );
                      }).toList(),
                      onChanged: (val) => ref.read(dashboardBuilderProvider.notifier).updateWidgetProperty(selectedWidget.id, 'dataSourceId', val),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      theme,
                      label: 'Filter',
                      value: selectedWidget.filter,
                      items: const [
                        DropdownMenuItem(value: 'None', child: Text('None')),
                        DropdownMenuItem(value: 'Top 10', child: Text('Top 10')),
                        DropdownMenuItem(value: 'Bottom 10', child: Text('Bottom 10')),
                      ],
                      onChanged: (val) => ref.read(dashboardBuilderProvider.notifier).updateWidgetProperty(selectedWidget.id, 'filter', val),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      theme,
                      label: 'Date Range',
                      value: selectedWidget.dateRange,
                      items: const [
                        DropdownMenuItem(value: 'Today', child: Text('Today')),
                        DropdownMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
                        DropdownMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days')),
                        DropdownMenuItem(value: 'This Year', child: Text('This Year')),
                      ],
                      onChanged: (val) => ref.read(dashboardBuilderProvider.notifier).updateWidgetProperty(selectedWidget.id, 'dateRange', val),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildPropertySection(
                  theme,
                  'Formatting',
                  [
                    _buildDropdown(
                      theme,
                      label: 'Color Scheme',
                      value: selectedWidget.colorScheme,
                      items: const [
                        DropdownMenuItem(value: 'Default', child: Text('Default')),
                        DropdownMenuItem(value: 'Monochrome', child: Text('Monochrome')),
                        DropdownMenuItem(value: 'Vibrant', child: Text('Vibrant')),
                        DropdownMenuItem(value: 'Pastel', child: Text('Pastel')),
                      ],
                      onChanged: (val) => ref.read(dashboardBuilderProvider.notifier).updateWidgetProperty(selectedWidget.id, 'colorScheme', val),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildPropertySection(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTextField(ThemeData theme, {required String label, required String value, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown(ThemeData theme, {required String label, required String? value, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final Color gridColor;

  GridPainter(this.gridColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
