import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../domain/models/document_version_model.dart';
import 'providers/document_version_provider.dart';

class DocumentVersionScreen extends ConsumerWidget {
  final String documentId;
  const DocumentVersionScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(documentVersionProvider(documentId));

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          _buildHeader(context, theme, state),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildMainContent(context, theme, state),
                      ),
                      Container(
                        width: 350,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border(left: BorderSide(color: theme.colorScheme.outlineVariant)),
                        ),
                        child: _buildTimeline(theme, state),
                      )
                    ],
                  );
                } else {
                  return _buildMainContent(context, theme, state); // Hide timeline on mobile/tablet or put it in a tab
                }
              }
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, DocumentVersionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/platform/documents/${state.documentId}');
              }
            },
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version History', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Document: ${state.documentId}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ThemeData theme, DocumentVersionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsRow(theme, state),
          const SizedBox(height: 32),
          Text('All Versions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildVersionTable(context, theme, state),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow(ThemeData theme, DocumentVersionState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildStatCard('Current Version', state.currentVersion, LucideIcons.checkCircle, Colors.green, theme),
            _buildStatCard('Previous Versions', state.previousCount.toString(), LucideIcons.history, Colors.blue, theme),
            _buildStatCard('Drafts', state.draftCount.toString(), LucideIcons.fileEdit, Colors.orange, theme),
            _buildStatCard('Published', state.publishedCount.toString(), LucideIcons.globe, Colors.purple, theme),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionTable(BuildContext context, ThemeData theme, DocumentVersionState state) {
    final format = DateFormat('MMM dd, yyyy HH:mm');
    
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          columns: const [
            DataColumn(label: Text('Version')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Uploaded By')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Changes')),
            DataColumn(label: Text('Size')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.versions.map((v) {
            return DataRow(
              cells: [
                DataCell(Text(v.version, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(_buildStatusBadge(v.status)),
                DataCell(Text(v.uploadedBy)),
                DataCell(Text(format.format(v.date))),
                DataCell(SizedBox(width: 250, child: Text(v.changes, maxLines: 2, overflow: TextOverflow.ellipsis))),
                DataCell(Text('${v.sizeMb.toStringAsFixed(1)} MB')),
                DataCell(
                  PopupMenuButton<String>(
                    icon: const Icon(LucideIcons.moreVertical, size: 20),
                    onSelected: (val) {
                      if (val == 'preview') ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Previewing ${v.version}')));
                      if (val == 'restore') ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restoring ${v.version} as Current')));
                      if (val == 'compare') ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Comparing ${v.version} with Current')));
                      if (val == 'download') ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading ${v.version}')));
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'preview', child: Row(children: [Icon(LucideIcons.eye, size: 16), SizedBox(width: 8), Text('Preview')])),
                      const PopupMenuItem(value: 'compare', child: Row(children: [Icon(LucideIcons.splitSquareHorizontal, size: 16), SizedBox(width: 8), Text('Compare')])),
                      const PopupMenuItem(value: 'download', child: Row(children: [Icon(LucideIcons.download, size: 16), SizedBox(width: 8), Text('Download')])),
                      if (v.status != 'Current')
                        const PopupMenuItem(value: 'restore', child: Row(children: [Icon(LucideIcons.history, size: 16, color: Colors.orange), SizedBox(width: 8), Text('Restore', style: TextStyle(color: Colors.orange))])),
                    ],
                  )
                ),
              ]
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Current': color = Colors.green; break;
      case 'Draft': color = Colors.orange; break;
      case 'Published': color = Colors.purple; break;
      default: color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTimeline(ThemeData theme, DocumentVersionState state) {
    final format = DateFormat('MMM dd');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('Version Timeline', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            itemCount: state.versions.length,
            itemBuilder: (context, index) {
              final v = state.versions[index];
              final isLast = index == state.versions.length - 1;
              final isCurrent = v.status == 'Current';
              
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent ? Colors.green : theme.colorScheme.outline,
                            border: Border.all(color: theme.colorScheme.surface, width: 2),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: theme.colorScheme.outlineVariant,
                            ),
                          )
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(v.version, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(format.format(v.date), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(v.uploadedBy, style: theme.textTheme.bodySmall),
                            const SizedBox(height: 8),
                            Text(v.changes, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
