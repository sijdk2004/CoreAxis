import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/design_system_audit_provider.dart';

class DesignSystemAuditScreen extends ConsumerStatefulWidget {
  const DesignSystemAuditScreen({super.key});

  @override
  ConsumerState<DesignSystemAuditScreen> createState() => _DesignSystemAuditScreenState();
}

class _DesignSystemAuditScreenState extends ConsumerState<DesignSystemAuditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _mockSuccessState = false;
  bool _mockErrorState = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(designSystemAuditProvider);
    final notifier = ref.read(designSystemAuditProvider.notifier);
    
    // Create a mock theme specifically for preview if they selected dark mode preview
    final baseTheme = Theme.of(context);
    final theme = state.isDarkModePreview 
        ? ThemeData.dark().copyWith(colorScheme: baseTheme.colorScheme, textTheme: baseTheme.textTheme)
        : baseTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Design System Audit Center'),
        centerTitle: false,
        actions: [
          Row(
            children: [
              const Text('Preview Mode: ', style: TextStyle(fontSize: 12)),
              Switch(
                value: state.isDarkModePreview,
                onChanged: (val) => notifier.toggleDarkModePreview(val),
                activeColor: theme.colorScheme.primary,
              ),
              Icon(state.isDarkModePreview ? LucideIcons.moon : LucideIcons.sun, size: 16),
              const SizedBox(width: 24),
            ],
          ),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Desktop', icon: Icon(LucideIcons.monitor, size: 16)),
              ButtonSegment(value: 'Tablet', icon: Icon(LucideIcons.tablet, size: 16)),
              ButtonSegment(value: 'Mobile', icon: Icon(LucideIcons.smartphone, size: 16)),
            ],
            selected: {state.activeDevicePreview},
            onSelectionChanged: (set) => notifier.setActiveDevicePreview(set.first),
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
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildSidebarItem(context, theme, 'Overview', 0, LucideIcons.layoutDashboard, state.activeTabIndex, notifier),
                _buildSidebarItem(context, theme, 'Components Gallery', 1, LucideIcons.component, state.activeTabIndex, notifier),
                _buildSidebarItem(context, theme, 'Design Tokens', 2, LucideIcons.paintbrush, state.activeTabIndex, notifier),
                _buildSidebarItem(context, theme, 'Audit Report', 3, LucideIcons.clipboardCheck, state.activeTabIndex, notifier),
              ],
            ),
          ),
          // Main Content Area (Responsive Wrapper based on Device Preview)
          Expanded(
            child: Center(
              child: Container(
                width: _getPreviewWidth(state.activeDevicePreview),
                decoration: state.activeDevicePreview != 'Desktop' 
                    ? BoxDecoration(
                        border: Border.all(color: theme.dividerColor, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      )
                    : null,
                clipBehavior: state.activeDevicePreview != 'Desktop' ? Clip.hardEdge : Clip.none,
                child: Theme(
                  data: theme,
                  child: Scaffold(
                    backgroundColor: theme.colorScheme.background,
                    body: _buildContent(context, theme, state),
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
      case 'Desktop': default: return null; // take full width
    }
  }

  Widget _buildSidebarItem(BuildContext context, ThemeData theme, String title, int index, IconData icon, int activeIndex, DesignSystemAuditNotifier notifier) {
    final isActive = activeIndex == index;
    return ListTile(
      leading: Icon(icon, color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
      title: Text(title, style: TextStyle(color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      selected: isActive,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      onTap: () => notifier.setActiveTab(index),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, DesignSystemAuditState state) {
    switch (state.activeTabIndex) {
      case 0: return _buildOverviewSection(theme);
      case 1: return _buildComponentsGallery(theme);
      case 2: return _buildDesignTokens(theme);
      case 3: return _buildAuditReport(theme, state.usageStats);
      default: return const SizedBox.shrink();
    }
  }

  // --- SECTIONS ---

  Widget _buildOverviewSection(ThemeData theme) {
    final notifier = ref.read(designSystemAuditProvider.notifier);
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Text('Design System Overview', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('CoreAxis ERP standard UI patterns and structural elements.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 32),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _buildFeatureCard(theme, 'Typography', LucideIcons.type, 'Inter typeface, modular scale.', () => notifier.setActiveTab(2)),
            _buildFeatureCard(theme, 'Spacing', LucideIcons.move, '8px baseline grid system.', () => notifier.setActiveTab(2)),
            _buildFeatureCard(theme, 'Colors', LucideIcons.palette, 'Semantic palettes for light/dark.', () => notifier.setActiveTab(2)),
            _buildFeatureCard(theme, 'Icons', LucideIcons.smile, 'Lucide icons suite.', () => notifier.setActiveTab(2)),
            _buildFeatureCard(theme, 'Components', LucideIcons.component, 'Interactive UI elements.', () => notifier.setActiveTab(1)),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildFeatureCard(ThemeData theme, String title, IconData icon, String desc, VoidCallback onTap) {
    return SizedBox(
      width: 250,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: PremiumCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(desc, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentsGallery(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Text('Components Gallery', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        _buildGallerySectionTitle(theme, 'Buttons'),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton(onPressed: () {}, child: const Text('Primary Button')),
            FilledButton(onPressed: () {}, child: const Text('Filled Button')),
            FilledButton.tonal(onPressed: () {}, child: const Text('Secondary (Tonal)')),
            OutlinedButton(onPressed: () {}, child: const Text('Outlined Button')),
            TextButton(onPressed: () {}, child: const Text('Text Button')),
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.plus), label: const Text('With Icon')),
          ],
        ),
        const SizedBox(height: 32),
        _buildGallerySectionTitle(theme, 'Forms & Validation'),
        PremiumCard(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Standard Input', hintText: 'Enter text here', border: OutlineInputBorder()),
                  validator: (v) => _mockErrorState ? 'This field is required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Dropdown Select', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('Option 1')),
                    DropdownMenuItem(value: '2', child: Text('Option 2')),
                  ],
                  onChanged: (v) {},
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _mockErrorState = true;
                          _formKey.currentState?.validate();
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error, foregroundColor: theme.colorScheme.onError),
                      child: const Text('Trigger Error State'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _mockErrorState = false;
                          _mockSuccessState = true;
                          _formKey.currentState?.validate();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form validated successfully!')));
                        });
                      },
                      child: const Text('Trigger Success State'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildGallerySectionTitle(theme, 'Data Table (Mock)'),
        PremiumCard(
          padding: const EdgeInsets.all(0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                _buildMockDataRow(theme, 'USR-001', 'Alice Smith', 'Admin', 'Active'),
                _buildMockDataRow(theme, 'USR-002', 'Bob Jones', 'Editor', 'Pending'),
                _buildMockDataRow(theme, 'USR-003', 'Carol White', 'Viewer', 'Active'),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  DataRow _buildMockDataRow(ThemeData theme, String id, String name, String role, String status) {
    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(name)),
      DataCell(Text(role)),
      DataCell(Chip(
        label: Text(status, style: TextStyle(fontSize: 12, color: status == 'Active' ? Colors.green.shade900 : Colors.orange.shade900)),
        backgroundColor: status == 'Active' ? Colors.green.shade100 : Colors.orange.shade100,
        side: BorderSide.none,
      )),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(LucideIcons.edit, size: 16), onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.trash, size: 16, color: Colors.red), onPressed: () {}),
        ],
      )),
    ]);
  }

  Widget _buildGallerySectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
    );
  }

  Widget _buildDesignTokens(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Text('Design Tokens', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        _buildGallerySectionTitle(theme, 'Color Palette'),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildColorSwatch('Primary', theme.colorScheme.primary, theme.colorScheme.onPrimary),
            _buildColorSwatch('Secondary', theme.colorScheme.secondary, theme.colorScheme.onSecondary),
            _buildColorSwatch('Tertiary', theme.colorScheme.tertiary, theme.colorScheme.onTertiary),
            _buildColorSwatch('Error', theme.colorScheme.error, theme.colorScheme.onError),
            _buildColorSwatch('Surface', theme.colorScheme.surface, theme.colorScheme.onSurface),
            _buildColorSwatch('Background', theme.colorScheme.background, theme.colorScheme.onBackground),
          ],
        ),
        const SizedBox(height: 32),
        _buildGallerySectionTitle(theme, 'Typography Scale'),
        PremiumCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Display Large', style: theme.textTheme.displayLarge),
              const Divider(height: 32),
              Text('Headline Large', style: theme.textTheme.headlineLarge),
              const Divider(height: 32),
              Text('Title Large', style: theme.textTheme.titleLarge),
              const Divider(height: 32),
              Text('Body Large', style: theme.textTheme.bodyLarge),
              const Divider(height: 32),
              Text('Label Large', style: theme.textTheme.labelLarge),
            ],
          ),
        )
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildColorSwatch(String name, Color color, Color onColor) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Text(name, style: TextStyle(color: onColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAuditReport(ThemeData theme, List<ComponentUsageStats> stats) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Text('Audit Report & Compliance', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        PremiumCard(
          padding: const EdgeInsets.all(0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withValues(alpha: 0.3)),
              columns: const [
                DataColumn(label: Text('Component')),
                DataColumn(label: Text('Usage (Current)')),
                DataColumn(label: Text('Target (Max)')),
                DataColumn(label: Text('Compliance %')),
                DataColumn(label: Text('Status')),
              ],
              rows: stats.map((stat) {
                final isCompliant = stat.complianceScore >= 90;
                final isWarning = stat.complianceScore >= 50 && stat.complianceScore < 90;
                return DataRow(cells: [
                  DataCell(Text(stat.componentName, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('${stat.currentUsage}')),
                  DataCell(Text('${stat.recommendedUsage > 0 ? stat.recommendedUsage : "0 (Deprecated)"}')),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: stat.complianceScore / 100,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          color: isCompliant ? Colors.green : (isWarning ? Colors.orange : Colors.red),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${stat.complianceScore.toStringAsFixed(1)}%'),
                    ],
                  )),
                  DataCell(Chip(
                    label: Text(stat.status, style: const TextStyle(fontSize: 12)),
                    backgroundColor: isCompliant ? Colors.green.withValues(alpha: 0.1) : (isWarning ? Colors.orange.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1)),
                    labelStyle: TextStyle(color: isCompliant ? Colors.green.shade700 : (isWarning ? Colors.orange.shade700 : Colors.red.shade700)),
                    side: BorderSide.none,
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}
