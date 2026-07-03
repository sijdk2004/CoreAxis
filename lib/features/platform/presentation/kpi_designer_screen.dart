import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../domain/kpi_model.dart';
import 'providers/kpi_provider.dart';

class KpiDesignerScreen extends ConsumerWidget {
  const KpiDesignerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(kpiProvider);
    final notifier = ref.read(kpiProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, theme),
          const Divider(height: 1),
          _buildToolbar(context, theme, notifier),
          const Divider(height: 1),
          _buildCategories(context, theme, state, notifier),
          const Divider(height: 1),
          Expanded(
            child: _buildGrid(context, theme, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KPI Designer',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define custom Key Performance Indicators, establish formulas, and configure visualization thresholds.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, KpiNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: (value) => notifier.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search KPIs...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showCreateKpiDialog(context, notifier),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Create KPI'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, ThemeData theme, KpiState state, KpiNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        children: [
          _buildCategoryChip(theme, state, notifier, null, 'All Categories'),
          const SizedBox(width: 8),
          ...KpiCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildCategoryChip(theme, state, notifier, category, _capitalize(category.name)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme, KpiState state, KpiNotifier notifier, KpiCategory? category, String label) {
    final isSelected = state.selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected || category == null) {
          notifier.setCategory(category);
        }
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withAlpha(25),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, ThemeData theme, KpiState state, KpiNotifier notifier) {
    final kpis = state.filteredKpis;

    if (kpis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.activity, size: 64, color: theme.dividerColor),
            const SizedBox(height: 16),
            Text('No KPIs found', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    if (width < 800) crossAxisCount = 1;
    else if (width < 1200) crossAxisCount = 2;
    else if (width > 1600) crossAxisCount = 4;

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        return _buildKpiCard(context, theme, kpis[index], notifier);
      },
    );
  }

  Widget _buildKpiCard(BuildContext context, ThemeData theme, KpiModel kpi, KpiNotifier notifier) {
    // Determine color based on threshold logic. Simple mock logic:
    Color kpiColor = theme.colorScheme.primary;
    if (kpi.thresholds.isNotEmpty) {
      // Sort thresholds ascending
      final sortedThresholds = List<KpiThreshold>.from(kpi.thresholds)..sort((a, b) => a.value.compareTo(b.value));
      for (var t in sortedThresholds) {
        if (kpi.currentValue <= t.value) {
          kpiColor = _colorFromHex(t.color);
          break;
        }
      }
      // If it's above all thresholds, take the last one's color
      if (kpi.currentValue > sortedThresholds.last.value) {
        kpiColor = _colorFromHex(sortedThresholds.last.color);
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    kpi.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.moreVertical, size: 20),
                  onSelected: (value) {
                    if (value == 'delete') notifier.deleteKpi(kpi.id);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              kpi.description,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      kpi.currentValue.toStringAsFixed(1),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: kpiColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Target: ${kpi.target}', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _capitalize(kpi.widgetType.name),
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                const Spacer(),
                Text(
                  'Formula defined',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  void _showCreateKpiDialog(BuildContext context, KpiNotifier notifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CreateKpiDialog(notifier: notifier),
    );
  }
}

class _CreateKpiDialog extends StatefulWidget {
  final KpiNotifier notifier;

  const _CreateKpiDialog({required this.notifier});

  @override
  State<_CreateKpiDialog> createState() => _CreateKpiDialogState();
}

class _CreateKpiDialogState extends State<_CreateKpiDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _formulaController = TextEditingController();
  final _targetController = TextEditingController();

  KpiCategory _category = KpiCategory.operations;
  KpiWidgetType _widgetType = KpiWidgetType.card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Create Custom KPI'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'KPI Name', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 2,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<KpiCategory>(
                        initialValue: _category,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        items: KpiCategory.values.map((cat) => DropdownMenuItem(value: cat, child: Text(_capitalize(cat.name)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _category = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<KpiWidgetType>(
                        initialValue: _widgetType,
                        decoration: const InputDecoration(labelText: 'Default Widget', border: OutlineInputBorder()),
                        items: KpiWidgetType.values.map((type) => DropdownMenuItem(value: type, child: Text(_capitalize(type.name)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _widgetType = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Calculation logic', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _formulaController,
                  decoration: const InputDecoration(
                    labelText: 'Formula (e.g. Sales / Target * 100)', 
                    border: OutlineInputBorder(),
                    hintText: 'Enter mock formula string',
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _targetController,
                  decoration: const InputDecoration(labelText: 'Target Value', border: OutlineInputBorder()),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (double.tryParse(value) == null) return 'Must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Mock Thresholds note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.primary.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.info, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'For this mock creation, default color thresholds (Red, Orange, Green) will be generated automatically relative to your Target Value.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final targetVal = double.parse(_targetController.text);
              final mockThresholds = [
                KpiThreshold(value: targetVal * 0.5, color: '#F44336'), // 50% = Red
                KpiThreshold(value: targetVal * 0.8, color: '#FF9800'), // 80% = Orange
                KpiThreshold(value: targetVal, color: '#4CAF50'), // 100% = Green
              ];

              widget.notifier.createKpi(KpiModel(
                id: '', // Will be generated
                name: _nameController.text,
                description: _descController.text,
                category: _category,
                formula: _formulaController.text,
                target: targetVal,
                thresholds: mockThresholds,
                widgetType: _widgetType,
                currentValue: 0.0, // Mocked during create
              ));
              Navigator.of(context).pop();
            }
          },
          child: const Text('Create KPI'),
        ),
      ],
    );
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _formulaController.dispose();
    _targetController.dispose();
    super.dispose();
  }
}
