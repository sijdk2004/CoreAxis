import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../domain/report_builder_model.dart';
import 'providers/report_builder_provider.dart';

class ReportBuilderScreen extends ConsumerWidget {
  const ReportBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(reportBuilderProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    if (!isDesktop) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.monitorOff, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('Desktop Required', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('The Report Builder is only available on desktop.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildToolbar(context, ref, theme, state),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLeftPanel(context, ref, theme, state),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _buildCanvas(context, ref, theme, state)),
                if (state.selectedComponentId != null && !state.isPreviewMode) ...[
                  const VerticalDivider(width: 1, thickness: 1),
                  _buildRightPanel(context, ref, theme, state),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref, ThemeData theme, ReportBuilderState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.penTool, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            'Enterprise Report Builder',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(LucideIcons.undo),
            tooltip: 'Undo',
            onPressed: state.historyIndex >= 0 ? () => ref.read(reportBuilderProvider.notifier).undo() : null,
          ),
          IconButton(
            icon: const Icon(LucideIcons.redo),
            tooltip: 'Redo',
            onPressed: state.historyIndex < state.history.length - 1 ? () => ref.read(reportBuilderProvider.notifier).redo() : null,
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () => ref.read(reportBuilderProvider.notifier).togglePreview(),
            icon: Icon(state.isPreviewMode ? LucideIcons.edit2 : LucideIcons.eye),
            label: Text(state.isPreviewMode ? 'Exit Preview' : 'Preview'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.share2),
            label: const Text('Share'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.calendarClock),
            label: const Text('Schedule'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.download),
            label: const Text('Export'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.save),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context, WidgetRef ref, ThemeData theme, ReportBuilderState state) {
    if (state.isPreviewMode) return const SizedBox.shrink();

    final notifier = ref.read(reportBuilderProvider.notifier);

    return Container(
      width: 280,
      color: theme.colorScheme.surface,
      child: ListView(
        children: [
          ExpansionTile(
            title: const Text('Data Sources', style: TextStyle(fontWeight: FontWeight.bold)),
            initiallyExpanded: true,
            children: notifier.availableDataSources.map((ds) => _buildDataSourceItem(theme, ds)).toList(),
          ),
          ExpansionTile(
            title: const Text('Industry Packs', style: TextStyle(fontWeight: FontWeight.bold)),
            children: notifier.industryPacks.map((ds) => _buildDataSourceItem(theme, ds)).toList(),
          ),
          ExpansionTile(
            title: const Text('Visualizations', style: TextStyle(fontWeight: FontWeight.bold)),
            initiallyExpanded: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ComponentType.values.map((type) => _buildDraggableComponentIcon(theme, type)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceItem(ThemeData theme, DataSourceEntity ds) {
    return ExpansionTile(
      leading: Icon(ds.icon, size: 20, color: theme.colorScheme.primary),
      title: Text(ds.name),
      childrenPadding: const EdgeInsets.only(left: 40, bottom: 8),
      children: ds.fields.map((field) {
        return Draggable<String>(
          data: '${ds.name}.$field',
          feedback: Material(
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: theme.colorScheme.surface,
              child: Text(field, style: theme.textTheme.bodyMedium),
            ),
          ),
          child: ListTile(
            dense: true,
            leading: const Icon(LucideIcons.hash, size: 14),
            title: Text(field, style: theme.textTheme.bodySmall),
            visualDensity: VisualDensity.compact,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDraggableComponentIcon(ThemeData theme, ComponentType type) {
    return Draggable<ComponentType>(
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
              Icon(type.icon, color: theme.colorScheme.primary),
              const SizedBox(height: 4),
              Text(type.label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      child: Tooltip(
        message: type.label,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(type.icon, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(type.label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanvas(BuildContext context, WidgetRef ref, ThemeData theme, ReportBuilderState state) {
    return DragTarget<Object>(
      onAcceptWithDetails: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.offset);
        final adjustedPosition = Offset(localPosition.dx - 40, localPosition.dy - 40);
        
        final notifier = ref.read(reportBuilderProvider.notifier);
        if (details.data is ComponentType) {
          notifier.addComponent(details.data as ComponentType, adjustedPosition);
        } else if (details.data is String) {
          // Auto-create a table if a field is dropped on empty canvas
          notifier.addComponent(ComponentType.table, adjustedPosition);
          // The newly added component is now selected and is at the end of the list
          final newComponentId = notifier.state.components.last.id;
          notifier.addFieldToComponent(newComponentId, details.data as String, 'values');
        }
      },
      builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
        return GestureDetector(
          onTap: () {
            if (!state.isPreviewMode) {
              ref.read(reportBuilderProvider.notifier).selectComponent(null);
            }
          },
          child: Container(
            color: theme.scaffoldBackgroundColor,
            child: Stack(
              children: [
                // Dotted grid background
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: CustomPaint(
                      painter: _GridPainter(color: theme.colorScheme.onSurface),
                    ),
                  ),
                ),
                // Components
                ...state.components.map((component) => _buildCanvasComponent(context, ref, theme, state, component)),
                
                if (state.components.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.layoutDashboard, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Drag and drop visualizations here',
                          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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

  Widget _buildCanvasComponent(BuildContext context, WidgetRef ref, ThemeData theme, ReportBuilderState state, CanvasComponent component) {
    final isSelected = state.selectedComponentId == component.id;

    Widget content = Container(
      width: component.size.width,
      height: component.size.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected && !state.isPreviewMode ? theme.colorScheme.primary : theme.dividerColor,
          width: isSelected && !state.isPreviewMode ? 2 : 1,
        ),
        boxShadow: isSelected && !state.isPreviewMode ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.2), blurRadius: 8)] : [
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(component.type.icon, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    component.title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (isSelected && !state.isPreviewMode)
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => ref.read(reportBuilderProvider.notifier).removeComponent(component.id),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _buildMockComponentContent(theme, component),
          ),
        ],
      ),
    );

    if (state.isPreviewMode) {
      return Positioned(
        left: component.position.dx,
        top: component.position.dy,
        child: content,
      );
    }

    return Positioned(
      left: component.position.dx,
      top: component.position.dy,
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          ref.read(reportBuilderProvider.notifier).addFieldToComponent(component.id, details.data, 'values');
        },
        builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return Container(
            decoration: isHovering ? BoxDecoration(border: Border.all(color: theme.colorScheme.primary, width: 2)) : null,
            child: GestureDetector(
        onTap: () => ref.read(reportBuilderProvider.notifier).selectComponent(component.id),
        onPanUpdate: (details) {
          ref.read(reportBuilderProvider.notifier).selectComponent(component.id);
          ref.read(reportBuilderProvider.notifier).updateComponentPosition(
                component.id,
                Offset(component.position.dx + details.delta.dx, component.position.dy + details.delta.dy),
              );
        },
        onPanEnd: (details) {
          ref.read(reportBuilderProvider.notifier).commitComponentMove();
        },
        child: Stack(
          children: [
            content,
            // Mock Resize handle
            if (isSelected)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    final newWidth = (component.size.width + details.delta.dx).clamp(200.0, 1200.0);
                    final newHeight = (component.size.height + details.delta.dy).clamp(150.0, 800.0);
                    ref.read(reportBuilderProvider.notifier).updateComponentSize(
                          component.id,
                          Size(newWidth, newHeight),
                        );
                  },
                  onPanEnd: (details) {
                    ref.read(reportBuilderProvider.notifier).commitComponentMove(); // reuse move commit for resize
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Icon(LucideIcons.scaling, size: 14, color: theme.colorScheme.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
          );
        },
      ),
    );
  }

  Widget _buildMockComponentContent(ThemeData theme, CanvasComponent component) {
    if (component.columns.isEmpty && component.values.isEmpty && component.type != ComponentType.kpi) {
      return Center(
        child: Text(
          'Select component and drag fields into Properties panel',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      );
    }

    // A very basic mock visualization based on type
    switch (component.type) {
      case ComponentType.table:
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              if (component.columns.isEmpty) const DataColumn(label: Text('Column 1')),
              ...component.columns.map((c) => DataColumn(label: Text(c.split('.').last))),
              ...component.values.map((c) => DataColumn(label: Text(c.split('.').last))),
            ],
            rows: List.generate(3, (index) => DataRow(cells: [
              if (component.columns.isEmpty) const DataCell(Text('Data')),
              ...component.columns.map((c) => DataCell(Text('Row $index'))),
              ...component.values.map((c) => DataCell(Text('${(index + 1) * 100}'))),
            ])),
          ),
        );
      case ComponentType.kpi:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(component.values.isNotEmpty ? component.values.first.split('.').last : 'Metric', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('1,234', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            ],
          ),
        );
      default:
        return Center(
          child: Icon(component.type.icon, size: 64, color: theme.colorScheme.primary.withOpacity(0.2)),
        );
    }
  }

  Widget _buildRightPanel(BuildContext context, WidgetRef ref, ThemeData theme, ReportBuilderState state) {
    final component = state.components.firstWhere((c) => c.id == state.selectedComponentId);

    return Container(
      width: 320,
      color: theme.colorScheme.surface,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: theme.colorScheme.surface,
              child: const TabBar(
                tabs: [
                  Tab(text: 'Data'),
                  Tab(text: 'Format'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Data Tab
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Properties for ${component.type.label}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildDropZone(context, ref, theme, 'Columns / Categories', 'columns', component),
                      const SizedBox(height: 16),
                      _buildDropZone(context, ref, theme, 'Values / Measures', 'values', component),
                      const SizedBox(height: 16),
                      _buildDropZone(context, ref, theme, 'Filters', 'filters', component),
                    ],
                  ),
                  // Format Tab
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text('Formatting Options', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                        controller: TextEditingController(text: component.title),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Show Legend'),
                        value: true,
                        onChanged: (_) {},
                      ),
                      SwitchListTile(
                        title: const Text('Show Data Labels'),
                        value: false,
                        onChanged: (_) {},
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
  }

  Widget _buildDropZone(BuildContext context, WidgetRef ref, ThemeData theme, String title, String target, CanvasComponent component) {
    List<String> items = [];
    if (target == 'columns') items = component.columns;
    if (target == 'values') items = component.values;
    if (target == 'filters') items = component.filters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DragTarget<String>(
          onAcceptWithDetails: (details) {
            ref.read(reportBuilderProvider.notifier).addFieldToComponent(component.id, details.data, target);
          },
          builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
            final isHovering = candidateData.isNotEmpty;
            return Container(
              constraints: const BoxConstraints(minHeight: 60),
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHovering ? theme.colorScheme.primaryContainer.withOpacity(0.5) : theme.scaffoldBackgroundColor,
                border: Border.all(color: isHovering ? theme.colorScheme.primary : theme.dividerColor, style: isHovering ? BorderStyle.solid : BorderStyle.none),
                borderRadius: BorderRadius.circular(8),
              ),
              child: items.isEmpty
                  ? Center(child: Text('Drop field here', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: items.map((field) {
                        return Chip(
                          label: Text(field, style: const TextStyle(fontSize: 12)),
                          onDeleted: () {
                            ref.read(reportBuilderProvider.notifier).removeFieldFromComponent(component.id, field, target);
                          },
                          deleteIcon: const Icon(LucideIcons.x, size: 14),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
            );
          },
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const spacing = 20.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
