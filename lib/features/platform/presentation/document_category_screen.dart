import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../domain/models/document_category_model.dart';
import 'providers/document_category_provider.dart';

class DocumentCategoryScreen extends ConsumerWidget {
  const DocumentCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(documentCategoryProvider);
    final notifier = ref.read(documentCategoryProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme, notifier),
                  const SizedBox(height: 32),
                  _buildStatistics(theme, state),
                  const SizedBox(height: 32),
                  _buildCategoryGrid(context, theme, state, notifier),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, DocumentCategoryNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Document Categories', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        Row(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                onChanged: notifier.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(LucideIcons.search, size: 18),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () => _showCategoryDialog(context, null, notifier),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Create Category'),
            )
          ],
        )
      ],
    );
  }

  Widget _buildStatistics(ThemeData theme, DocumentCategoryState state) {
    final format = NumberFormat.compact();
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3.5,
          children: [
            _buildStatCard('Total Categories', state.totalCategories.toString(), LucideIcons.layers, Colors.blue, theme),
            _buildStatCard('Active Categories', state.activeCategories.toString(), LucideIcons.checkCircle2, Colors.green, theme),
            _buildStatCard('Archived Categories', state.archivedCategories.toString(), LucideIcons.archive, Colors.grey, theme),
            _buildStatCard('Total Documents', format.format(state.totalDocuments), LucideIcons.fileSearch, Colors.purple, theme),
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, ThemeData theme, DocumentCategoryState state, DocumentCategoryNotifier notifier) {
    if (state.currentCategories.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(64.0), child: Text('No categories found.')));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1400 ? 4 : (constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 600 ? 2 : 1));
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.1,
          ),
          itemCount: state.currentCategories.length,
          itemBuilder: (context, index) {
            final category = state.currentCategories[index];
            return _buildCategoryCard(context, theme, category, notifier);
          },
        );
      }
    );
  }

  Widget _buildCategoryCard(BuildContext context, ThemeData theme, DocumentCategory category, DocumentCategoryNotifier notifier) {
    final format = NumberFormat.compact();
    final isArchived = category.status == 'Archived';
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showCategoryDialog(context, category, notifier),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _getSemanticColor(category.color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_getSemanticIcon(category.icon), color: _getSemanticColor(category.color), size: 28),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(LucideIcons.moreVertical, size: 20),
                    onSelected: (val) {
                      if (val == 'edit') _showCategoryDialog(context, category, notifier);
                      if (val == 'archive') notifier.archiveCategory(category.id);
                      if (val == 'delete') notifier.deleteCategory(category.id);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(LucideIcons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
                      if (!isArchived) const PopupMenuItem(value: 'archive', child: Row(children: [Icon(LucideIcons.archive, size: 16), SizedBox(width: 8), Text('Archive')])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(LucideIcons.trash2, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                    ],
                  )
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(child: Text(category.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (isArchived) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('Archived', style: TextStyle(fontSize: 10, color: Colors.grey))),
                ],
              ),
              const SizedBox(height: 8),
              Text(category.description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Documents', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(format.format(category.documentCount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Retention', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(category.retentionPolicy, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, DocumentCategory? category, DocumentCategoryNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => _CategoryFormDialog(category: category, notifier: notifier),
    );
  }

  IconData _getSemanticIcon(String iconName) {
    switch (iconName) {
      case 'dollarSign': return LucideIcons.dollarSign;
      case 'users': return LucideIcons.users;
      case 'scale': return LucideIcons.scale;
      case 'image': return LucideIcons.image;
      case 'archive': return LucideIcons.archive;
      case 'shield': return LucideIcons.shield;
      case 'lock': return LucideIcons.lock;
      case 'file': return LucideIcons.file;
      default: return LucideIcons.layers;
    }
  }

  Color _getSemanticColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'grey': return Colors.grey;
      case 'orange': return Colors.orange;
      case 'teal': return Colors.teal;
      default: return Colors.blue;
    }
  }
}

class _CategoryFormDialog extends StatefulWidget {
  final DocumentCategory? category;
  final DocumentCategoryNotifier notifier;

  const _CategoryFormDialog({this.category, required this.notifier});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _fileTypesController;
  late TextEditingController _maxSizeController;
  
  String _selectedIcon = 'layers';
  String _selectedColor = 'blue';
  String _selectedRetention = '7 Years';
  String _selectedVisibility = 'Restricted';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descController = TextEditingController(text: widget.category?.description ?? '');
    _fileTypesController = TextEditingController(text: widget.category?.allowedFileTypes.join(', ') ?? 'pdf, doc, docx');
    _maxSizeController = TextEditingController(text: widget.category?.maxFileSizeMb.toString() ?? '50');
    
    if (widget.category != null) {
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
      _selectedRetention = widget.category!.retentionPolicy;
      _selectedVisibility = widget.category!.visibility;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.category != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Category' : 'Create Category'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Category Name', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedColor,
                        decoration: const InputDecoration(labelText: 'Theme Color', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'blue', child: Text('Blue')),
                          DropdownMenuItem(value: 'green', child: Text('Green')),
                          DropdownMenuItem(value: 'purple', child: Text('Purple')),
                          DropdownMenuItem(value: 'red', child: Text('Red')),
                          DropdownMenuItem(value: 'orange', child: Text('Orange')),
                          DropdownMenuItem(value: 'grey', child: Text('Grey')),
                        ],
                        onChanged: (val) => setState(() => _selectedColor = val!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedIcon,
                        decoration: const InputDecoration(labelText: 'Icon', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'layers', child: Text('Layers')),
                          DropdownMenuItem(value: 'dollarSign', child: Text('Dollar Sign')),
                          DropdownMenuItem(value: 'users', child: Text('Users')),
                          DropdownMenuItem(value: 'scale', child: Text('Scale')),
                          DropdownMenuItem(value: 'image', child: Text('Image')),
                          DropdownMenuItem(value: 'shield', child: Text('Shield')),
                        ],
                        onChanged: (val) => setState(() => _selectedIcon = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRetention,
                        decoration: const InputDecoration(labelText: 'Retention Policy', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: '1 Year', child: Text('1 Year')),
                          DropdownMenuItem(value: '3 Years', child: Text('3 Years')),
                          DropdownMenuItem(value: '7 Years', child: Text('7 Years')),
                          DropdownMenuItem(value: '10 Years', child: Text('10 Years')),
                          DropdownMenuItem(value: 'Indefinite', child: Text('Indefinite')),
                        ],
                        onChanged: (val) => setState(() => _selectedRetention = val!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedVisibility,
                        decoration: const InputDecoration(labelText: 'Visibility', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'Public', child: Text('Public')),
                          DropdownMenuItem(value: 'Restricted', child: Text('Restricted')),
                          DropdownMenuItem(value: 'Private', child: Text('Private')),
                        ],
                        onChanged: (val) => setState(() => _selectedVisibility = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fileTypesController,
                        decoration: const InputDecoration(labelText: 'Allowed File Types (comma separated)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _maxSizeController,
                        decoration: const InputDecoration(labelText: 'Max File Size (MB)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid number' : null,
                      ),
                    ),
                  ],
                )
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
              final newCat = DocumentCategory(
                id: isEditing ? widget.category!.id : 'CAT-${DateTime.now().millisecondsSinceEpoch}',
                name: _nameController.text,
                description: _descController.text,
                icon: _selectedIcon,
                color: _selectedColor,
                documentCount: isEditing ? widget.category!.documentCount : 0,
                retentionPolicy: _selectedRetention,
                visibility: _selectedVisibility,
                allowedFileTypes: _fileTypesController.text.split(',').map((e) => e.trim()).toList(),
                maxFileSizeMb: double.parse(_maxSizeController.text),
                status: isEditing ? widget.category!.status : 'Active',
              );
              
              if (isEditing) {
                widget.notifier.updateCategory(newCat);
              } else {
                widget.notifier.addCategory(newCat);
              }
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category ${isEditing ? 'updated' : 'created'} successfully.')));
            }
          },
          child: Text(isEditing ? 'Save Changes' : 'Create Category'),
        )
      ],
    );
  }
}
