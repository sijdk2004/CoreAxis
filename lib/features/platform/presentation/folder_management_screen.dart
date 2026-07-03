import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../domain/models/folder_management_model.dart';
import 'providers/folder_management_provider.dart';

class FolderManagementScreen extends ConsumerStatefulWidget {
  const FolderManagementScreen({super.key});

  @override
  ConsumerState<FolderManagementScreen> createState() => _FolderManagementScreenState();
}

class _FolderManagementScreenState extends ConsumerState<FolderManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(folderManagementProvider);
    final notifier = ref.read(folderManagementProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          return Column(
            children: [
              _buildHeader(context, theme, state, notifier),
              Expanded(
                child: isDesktop 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 300,
                          decoration: BoxDecoration(
                            border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant)),
                            color: theme.colorScheme.surface,
                          ),
                          child: _buildFolderTreePane(theme, state, notifier),
                        ),
                        Expanded(child: _buildMainPane(context, theme, state, notifier)),
                      ],
                    )
                  : _buildMainPane(context, theme, state, notifier),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, FolderManagementState state, FolderManagementNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(LucideIcons.folderTree, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: state.breadcrumbs.map((f) {
                        final isLast = f.id == state.currentFolderId;
                        return Row(
                          children: [
                            InkWell(
                              onTap: () => notifier.selectFolder(f.id),
                              child: Text(
                                f.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                                  color: isLast ? theme.colorScheme.onSurface : theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            if (!isLast) const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Icon(LucideIcons.chevronRight, size: 16)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 250,
                child: TextField(
                  onChanged: notifier.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search subfolders...',
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                    filled: true,
                    fillColor: theme.colorScheme.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () => _showFolderDialog(context, null, state.currentFolderId, notifier, state),
                icon: const Icon(LucideIcons.folderPlus, size: 18),
                label: const Text('Create Folder'),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFolderTreePane(ThemeData theme, FolderManagementState state, FolderManagementNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Folder Tree', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.rootFolders.length,
            itemBuilder: (context, index) {
              return _buildTreeNode(state.rootFolders[index], 0, theme, state, notifier);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTreeNode(ManagedFolder node, int depth, ThemeData theme, FolderManagementState state, FolderManagementNotifier notifier) {
    final isSelected = node.id == state.currentFolderId;
    final hasChildren = node.children.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => notifier.selectFolder(node.id),
          child: Container(
            padding: EdgeInsets.only(left: 16.0 + (depth * 24.0), right: 16.0, top: 8.0, bottom: 8.0),
            color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
            child: Row(
              children: [
                if (hasChildren)
                  InkWell(
                    onTap: () => notifier.toggleFolderExpansion(node.id),
                    child: Icon(node.isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  )
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Icon(isSelected ? LucideIcons.folderOpen : LucideIcons.folder, size: 18, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasChildren && node.isExpanded)
          ...node.children.map((child) => _buildTreeNode(child, depth + 1, theme, state, notifier)),
      ],
    );
  }

  Widget _buildMainPane(BuildContext context, ThemeData theme, FolderManagementState state, FolderManagementNotifier notifier) {
    final format = NumberFormat.compact();
    final children = state.currentChildren;
    
    // Calculate aggregate stats for current view
    final totalSubfolders = children.length;
    final totalDocs = children.fold(0, (sum, f) => sum + f.documentsCount);
    final totalSize = children.fold(0.0, (sum, f) => sum + f.storageUsedMb);

    return Container(
      color: theme.colorScheme.background,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 800 ? 3 : 1;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 4,
                        children: [
                          _buildStatCard('Subfolders', totalSubfolders.toString(), LucideIcons.folder, Colors.blue, theme),
                          _buildStatCard('Total Documents', format.format(totalDocs), LucideIcons.fileText, Colors.purple, theme),
                          _buildStatCard('Storage Used', '${totalSize.toStringAsFixed(1)} MB', LucideIcons.hardDrive, Colors.green, theme),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 32),
                  Text('Contents', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (children.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(64.0),
                        child: Text('This folder is empty.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1));
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: children.length,
                          itemBuilder: (context, index) {
                            return _buildFolderCard(context, theme, children[index], notifier, state);
                          },
                        );
                      }
                    )
                ],
              ),
            ),
          )
        ],
      ),
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
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderCard(BuildContext context, ThemeData theme, ManagedFolder folder, FolderManagementNotifier notifier, FolderManagementState state) {
    final format = NumberFormat.compact();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => notifier.selectFolder(folder.id),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.folder, color: theme.colorScheme.primary, size: 32),
                  PopupMenuButton<String>(
                    icon: const Icon(LucideIcons.moreVertical, size: 20),
                    onSelected: (val) {
                      if (val == 'edit') _showFolderDialog(context, folder, folder.parentId, notifier, state);
                      if (val == 'delete') notifier.deleteFolder(folder.id);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(LucideIcons.edit, size: 16), SizedBox(width: 8), Text('Edit / Move')])),
                      const PopupMenuItem(value: 'archive', child: Row(children: [Icon(LucideIcons.archive, size: 16), SizedBox(width: 8), Text('Archive')])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(LucideIcons.trash2, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(folder.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(folder.description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${folder.documentsCount} docs', style: const TextStyle(fontSize: 12)),
                  Text('${folder.storageUsedMb.toStringAsFixed(1)} MB', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showFolderDialog(BuildContext context, ManagedFolder? folder, String? parentId, FolderManagementNotifier notifier, FolderManagementState state) {
    showDialog(
      context: context,
      builder: (context) => _FolderFormDialog(folder: folder, initialParentId: parentId ?? 'root', notifier: notifier, state: state),
    );
  }
}

class _FolderFormDialog extends StatefulWidget {
  final ManagedFolder? folder;
  final String initialParentId;
  final FolderManagementNotifier notifier;
  final FolderManagementState state;

  const _FolderFormDialog({this.folder, required this.initialParentId, required this.notifier, required this.state});

  @override
  State<_FolderFormDialog> createState() => _FolderFormDialogState();
}

class _FolderFormDialogState extends State<_FolderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _orgController;
  late TextEditingController _ownerController;
  
  late String _selectedParentId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.folder?.name ?? '');
    _descController = TextEditingController(text: widget.folder?.description ?? '');
    _orgController = TextEditingController(text: widget.folder?.organization ?? 'Acme Corp');
    _ownerController = TextEditingController(text: widget.folder?.owner ?? 'Admin');
    
    _selectedParentId = widget.folder?.parentId ?? widget.initialParentId;
  }

  List<DropdownMenuItem<String>> _buildParentOptions(List<ManagedFolder> folders, String prefix) {
    List<DropdownMenuItem<String>> options = [];
    for (var f in folders) {
      if (widget.folder != null && f.id == widget.folder!.id) continue; // Prevent assigning to self or children
      
      options.add(DropdownMenuItem(value: f.id, child: Text('$prefix${f.name}')));
      options.addAll(_buildParentOptions(f.children, '$prefix  └ '));
    }
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.folder != null;
    
    List<DropdownMenuItem<String>> parentOptions = [
      const DropdownMenuItem(value: 'root', child: Text('Root (Top Level)')),
    ];
    parentOptions.addAll(_buildParentOptions(widget.state.rootFolders, ''));

    // Failsafe if selectedParentId somehow isn't in options
    if (!parentOptions.any((opt) => opt.value == _selectedParentId)) {
      _selectedParentId = 'root';
    }

    return AlertDialog(
      title: Text(isEditing ? 'Edit Folder' : 'Create Folder'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Folder Name', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedParentId,
                  decoration: const InputDecoration(labelText: 'Parent Folder', border: OutlineInputBorder()),
                  items: parentOptions,
                  onChanged: (val) => setState(() => _selectedParentId = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _orgController,
                        decoration: const InputDecoration(labelText: 'Organization', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _ownerController,
                        decoration: const InputDecoration(labelText: 'Owner', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (isEditing) {
                // To properly "move" a folder in the mock state, it's easier to just delete and recreate it if parent changed
                if (widget.folder!.parentId != _selectedParentId) {
                  widget.notifier.deleteFolder(widget.folder!.id);
                  widget.notifier.createFolder(widget.folder!.copyWith(
                    name: _nameController.text,
                    parentId: _selectedParentId,
                    description: _descController.text,
                    organization: _orgController.text,
                    owner: _ownerController.text,
                  ));
                } else {
                  widget.notifier.updateFolder(widget.folder!.copyWith(
                    name: _nameController.text,
                    description: _descController.text,
                    organization: _orgController.text,
                    owner: _ownerController.text,
                  ));
                }
              } else {
                widget.notifier.createFolder(ManagedFolder(
                  id: 'f_${DateTime.now().millisecondsSinceEpoch}',
                  name: _nameController.text,
                  parentId: _selectedParentId,
                  description: _descController.text,
                  organization: _orgController.text,
                  owner: _ownerController.text,
                  storageUsedMb: 0,
                  documentsCount: 0,
                  sharedWith: [],
                ));
              }
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Folder ${isEditing ? 'updated' : 'created'}.')));
            }
          },
          child: Text(isEditing ? 'Save Changes' : 'Create Folder'),
        )
      ],
    );
  }
}
