import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../domain/models/document_repository_model.dart';
import 'providers/document_repository_provider.dart';

class DocumentRepositoryScreen extends ConsumerWidget {
  const DocumentRepositoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(documentRepositoryProvider);
    final notifier = ref.read(documentRepositoryProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildToolbar(context, theme, state, notifier),
          const Divider(height: 1),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLeftPanel(context, theme, state, notifier),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Column(
                    children: [
                      _buildBreadcrumbAndActionBar(context, theme, state, notifier),
                      const Divider(height: 1),
                      Expanded(child: _buildCenterPanel(context, theme, state, notifier)),
                    ],
                  ),
                ),
                if (state.previewFileId != null) const VerticalDivider(width: 1),
                if (state.previewFileId != null) _buildRightPanel(context, theme, state, notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, DocumentRepositoryState state, DocumentRepositoryNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Text('Document Repository', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 32),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.upload, size: 16),
            label: const Text('Upload'),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.folderPlus, size: 16),
            label: const Text('New Folder'),
          ),
          const Spacer(),
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: notifier.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                suffixIcon: const Icon(LucideIcons.slidersHorizontal, size: 18),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.downloadCloud, size: 20),
            tooltip: 'Export',
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbAndActionBar(BuildContext context, ThemeData theme, DocumentRepositoryState state, DocumentRepositoryNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: state.breadcrumbs.asMap().entries.map((entry) {
              final isLast = entry.key == state.breadcrumbs.length - 1;
              return Row(
                children: [
                  InkWell(
                    onTap: () => notifier.selectFolder(entry.value.id),
                    child: Text(
                      entry.value.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                        color: isLast ? theme.colorScheme.onBackground : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (!isLast) const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Icon(LucideIcons.chevronRight, size: 16)),
                ],
              );
            }).toList(),
          ),
          Row(
            children: [
              if (state.selectedFileIds.isNotEmpty) ...[
                Text('${state.selectedFileIds.length} selected', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                IconButton(icon: const Icon(LucideIcons.download, size: 18), onPressed: () {}, tooltip: 'Download Selected'),
                IconButton(icon: const Icon(LucideIcons.archive, size: 18), onPressed: () => notifier.archiveSelected(), tooltip: 'Archive Selected'),
                IconButton(icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red), onPressed: () => notifier.deleteSelected(), tooltip: 'Delete Selected'),
                const SizedBox(width: 16),
              ],
              SegmentedButton<RepositoryViewMode>(
                segments: const [
                  ButtonSegment(value: RepositoryViewMode.table, icon: Icon(LucideIcons.table)),
                  ButtonSegment(value: RepositoryViewMode.grid, icon: Icon(LucideIcons.layoutGrid)),
                  ButtonSegment(value: RepositoryViewMode.list, icon: Icon(LucideIcons.list)),
                ],
                selected: {state.viewMode},
                onSelectionChanged: (Set<RepositoryViewMode> newSelection) {
                  notifier.setViewMode(newSelection.first);
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context, ThemeData theme, DocumentRepositoryState state, DocumentRepositoryNotifier notifier) {
    return SizedBox(
      width: 250,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          _buildSpecialFolderItem(theme, 'Favorites', LucideIcons.star, false),
          _buildSpecialFolderItem(theme, 'Recently Opened', LucideIcons.clock, false),
          const Divider(),
          ...state.folders.map((f) => _buildFolderTreeItem(f, 0, theme, state, notifier)).toList(),
        ],
      ),
    );
  }

  Widget _buildSpecialFolderItem(ThemeData theme, String title, IconData icon, bool isSelected) {
    return ListTile(
      leading: Icon(icon, size: 20, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? theme.colorScheme.primary : null)),
      selected: isSelected,
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildFolderTreeItem(DocumentFolder folder, int depth, ThemeData theme, DocumentRepositoryState state, DocumentRepositoryNotifier notifier) {
    final isSelected = folder.id == state.currentFolderId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => notifier.selectFolder(folder.id),
          child: Padding(
            padding: EdgeInsets.only(left: 24.0 + (depth * 24.0), right: 24.0, top: 8.0, bottom: 8.0),
            child: Row(
              children: [
                if (folder.children.isNotEmpty)
                  InkWell(
                    onTap: () => notifier.toggleFolderExpansion(folder.id),
                    child: Icon(folder.isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight, size: 16),
                  )
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Icon(isSelected ? LucideIcons.folderOpen : LucideIcons.folder, size: 18, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    folder.name,
                    style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? theme.colorScheme.primary : null),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (folder.isExpanded)
          ...folder.children.map((child) => _buildFolderTreeItem(child, depth + 1, theme, state, notifier)).toList(),
      ],
    );
  }

  Widget _buildCenterPanel(BuildContext context, ThemeData theme, DocumentRepositoryState state, DocumentRepositoryNotifier notifier) {
    if (state.currentFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 24),
            Text('This folder is empty', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Drag and drop files here to upload.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: () {
            switch (state.viewMode) {
              case RepositoryViewMode.table:
                return _buildTableView(context, theme, state, notifier);
              case RepositoryViewMode.grid:
                return _buildGridView(context, theme, state, notifier);
              case RepositoryViewMode.list:
                return _buildListView(context, theme, state, notifier);
            }
          }()
        ),
      ],
    );
  }

  Widget _buildTableView(BuildContext context, ThemeData theme, DocumentRepositoryState state, DocumentRepositoryNotifier notifier) {
    final format = DateFormat('MMM dd, yyyy');
    final allSelected = state.currentFiles.isNotEmpty && state.selectedFileIds.length == state.currentFiles.length;

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          showCheckboxColumn: true,
          headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          columns: [
            DataColumn(
              label: Row(
                children: [
                  Checkbox(
                    value: allSelected,
                    onChanged: (val) {
                      if (val == true) notifier.selectAll();
                      else notifier.clearSelection();
                    },
                  ),
                  const Text('Name'),
                ],
              )
            ),
            const DataColumn(label: Text('Category')),
            const DataColumn(label: Text('Owner')),
            const DataColumn(label: Text('Version')),
            const DataColumn(label: Text('Size')),
            const DataColumn(label: Text('Last Modified')),
            const DataColumn(label: Text('Status')),
            const DataColumn(label: Text('Actions')),
          ],
          rows: state.currentFiles.map((f) {
            final isSelected = state.selectedFileIds.contains(f.id);
            return DataRow(
              selected: isSelected,
              onSelectChanged: (val) {
                notifier.toggleFileSelection(f.id);
              },
              cells: [
                DataCell(
                  InkWell(
                    onTap: () => context.push('/platform/documents/${f.id}'),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (val) => notifier.toggleFileSelection(f.id),
                        ),
                        Icon(_getIconForType(f.type), size: 20, color: _getColorForType(f.type)),
                        const SizedBox(width: 12),
                        Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
                DataCell(Text(f.category)),
                DataCell(Text(f.owner)),
                DataCell(Text(f.version)),
                DataCell(Text('${f.sizeMb.toStringAsFixed(1)} MB')),
                DataCell(Text(format.format(f.lastModified))),
                DataCell(_buildStatusBadge(f.status, theme)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(LucideIcons.eye, size: 18), onPressed: () => notifier.selectPreview(f.id), tooltip: 'Preview'),
                      IconButton(icon: const Icon(LucideIcons.moreVertical, size: 18), onPressed: () {}, tooltip: 'More'),
                    ],
                  )
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGridView(BuildContext context, ThemeData theme, DocumentRepositoryState state, DocumentRepositoryNotifier notifier) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      itemCount: state.currentFiles.length,
      itemBuilder: (context, index) {
        final f = state.currentFiles[index];
        final isSelected = state.selectedFileIds.contains(f.id);
        return InkWell(
          onTap: () => notifier.selectPreview(f.id),
          onLongPress: () => notifier.toggleFileSelection(f.id),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getColorForType(f.type).withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Stack(
                      children: [
                        Center(child: Icon(_getIconForType(f.type), size: 48, color: _getColorForType(f.type))),
                        if (isSelected)
                          Positioned(
                            top: 8, left: 8,
                            child: Icon(LucideIcons.checkCircle2, color: theme.colorScheme.primary),
                          )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => context.push('/platform/documents/${f.id}'),
                        child: Text(
                          f.name,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${f.sizeMb.toStringAsFixed(1)} MB', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, ThemeData theme, DocumentRepositoryState state, DocumentRepositoryNotifier notifier) {
    final format = DateFormat('MMM dd, yyyy');
    return ListView.separated(
      itemCount: state.currentFiles.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final f = state.currentFiles[index];
        final isSelected = state.selectedFileIds.contains(f.id);
        return ListTile(
          selected: isSelected,
          selectedTileColor: theme.colorScheme.primary.withOpacity(0.05),
          leading: Icon(_getIconForType(f.type), size: 24, color: _getColorForType(f.type)),
          title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${f.owner} • ${format.format(f.lastModified)}'),
          trailing: Text('${f.sizeMb.toStringAsFixed(1)} MB'),
          onTap: () => notifier.selectPreview(f.id),
          onLongPress: () => notifier.toggleFileSelection(f.id),
        );
      },
    );
  }

  Widget _buildRightPanel(BuildContext context, ThemeData theme, DocumentRepositoryState state, DocumentRepositoryNotifier notifier) {
    final file = state.allFiles.firstWhere((f) => f.id == state.previewFileId);
    final format = DateFormat('MMM dd, yyyy HH:mm');
    
    return Container(
      width: 320,
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(icon: const Icon(LucideIcons.x, size: 18), onPressed: () => notifier.closePreview()),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: _getColorForType(file.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Center(child: Icon(_getIconForType(file.type), size: 64, color: _getColorForType(file.type))),
                ),
                const SizedBox(height: 24),
                Text(file.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildStatusBadge(file.status, theme),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildMetadataRow('ID', file.id, theme),
                _buildMetadataRow('Type', file.type.toUpperCase(), theme),
                _buildMetadataRow('Size', '${file.sizeMb.toStringAsFixed(1)} MB', theme),
                _buildMetadataRow('Owner', file.owner, theme),
                _buildMetadataRow('Organization', file.organization, theme),
                _buildMetadataRow('Module', file.module, theme),
                _buildMetadataRow('Version', file.version, theme),
                _buildMetadataRow('Modified', format.format(file.lastModified), theme),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionBtn('Download', LucideIcons.download, theme),
                    _buildActionBtn('Share', LucideIcons.share, theme),
                    _buildActionBtn('History', LucideIcons.history, theme),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, ThemeData theme) {
    return Column(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(icon),
          style: IconButton.styleFrom(backgroundColor: theme.colorScheme.primary.withOpacity(0.1)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'pdf': return LucideIcons.fileText;
      case 'doc': return LucideIcons.fileType2;
      case 'xls': return LucideIcons.fileSpreadsheet;
      case 'img': return LucideIcons.image;
      case 'ppt': return LucideIcons.presentation;
      default: return LucideIcons.file;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'pdf': return Colors.red;
      case 'doc': return Colors.blue;
      case 'xls': return Colors.green;
      case 'img': return Colors.purple;
      case 'ppt': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color;
    switch (status) {
      case 'Active': color = Colors.green; break;
      case 'Draft': color = Colors.orange; break;
      case 'Pending Review': color = Colors.purple; break;
      case 'Archived': color = Colors.grey; break;
      default: color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
