import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../domain/models/marketplace_module.dart';
import '../../domain/models/marketplace_module_draft.dart';
import '../../domain/models/marketplace_module_visibility.dart';
import '../../application/marketplace_providers.dart';
import '../../application/marketplace_publishing_providers.dart';

class MarketplaceModuleEditorScreen extends ConsumerStatefulWidget {
  final String? moduleId; // Null if creating a brand new module

  const MarketplaceModuleEditorScreen({
    super.key,
    this.moduleId,
  });

  @override
  ConsumerState<MarketplaceModuleEditorScreen> createState() => _MarketplaceModuleEditorScreenState();
}

class _MarketplaceModuleEditorScreenState extends ConsumerState<MarketplaceModuleEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _versionController;
  late TextEditingController _shortDescController;
  late TextEditingController _descController;
  
  MarketplaceModule? _module;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _versionController = TextEditingController();
    _shortDescController = TextEditingController();
    _descController = TextEditingController();
    
    _loadData();
  }
  
  Future<void> _loadData() async {
    if (widget.moduleId == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    final repo = ref.read(marketplaceRepositoryProvider);
    final module = await repo.getModuleById(widget.moduleId!);
    
    if (mounted) {
      setState(() {
        _module = module;
        if (module != null && module.draft != null) {
          _nameController.text = module.draft!.name;
          _versionController.text = module.draft!.version;
          _shortDescController.text = module.draft!.shortDescription;
          _descController.text = module.draft!.description;
        } else if (module != null && module.releases.isNotEmpty) {
          // No active draft, populate from latest release to show something, 
          // but we'll disable inputs until they click "Create New Version Draft"
          final latest = module.releases.last;
          _nameController.text = latest.name;
          _versionController.text = latest.version;
          _shortDescController.text = latest.shortDescription;
          _descController.text = latest.description;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;
    
    final draft = MarketplaceModuleDraft(
      name: _nameController.text,
      version: _versionController.text,
      shortDescription: _shortDescController.text,
      description: _descController.text,
      icon: _module?.draft?.icon ?? 'box', // Preserve or default
      state: MarketplaceDraftState.drafting,
    );

    if (widget.moduleId == null) {
      await ref.read(marketplacePublishingControllerProvider.notifier).createModule(draft);
      if (mounted) {
        context.pop();
      }
    } else {
      await ref.read(marketplacePublishingControllerProvider.notifier).updateDraft(widget.moduleId!, draft);
      _loadData();
    }
  }

  Future<void> _validateDraft() async {
    if (widget.moduleId != null) {
      await ref.read(marketplacePublishingControllerProvider.notifier).validateDraft(widget.moduleId!);
      _loadData();
      
      final state = ref.read(marketplacePublishingControllerProvider);
      if (state.validationResult != null && !state.validationResult!.isValid) {
        if (mounted) {
          _showValidationDialog(state.validationResult!.errors);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Validation successful!')),
          );
        }
      }
    }
  }
  
  void _showValidationDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors.map((e) => Text('• $e')).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _publishDraft() async {
    if (widget.moduleId != null) {
      await ref.read(marketplacePublishingControllerProvider.notifier).publishDraft(widget.moduleId!);
      if (mounted) {
        context.pop();
      }
    }
  }

  Future<void> _createNewVersionDraft() async {
    if (widget.moduleId != null) {
      await ref.read(marketplacePublishingControllerProvider.notifier).createNewVersionDraft(widget.moduleId!);
      _loadData();
    }
  }
  
  Future<void> _deprecateModule() async {
    if (widget.moduleId != null) {
      await ref.read(marketplacePublishingControllerProvider.notifier).deprecateModule(widget.moduleId!);
      _loadData();
    }
  }
  
  Future<void> _retireModule() async {
     if (widget.moduleId != null) {
      await ref.read(marketplacePublishingControllerProvider.notifier).retireModule(widget.moduleId!);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final isNew = widget.moduleId == null;
    final hasDraft = _module?.draft != null;
    final canEdit = isNew || hasDraft;
    final isPublished = _module?.visibility == MarketplaceModuleVisibility.published;
    final isDeprecated = _module?.visibility == MarketplaceModuleVisibility.deprecated;


    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(isNew ? 'Create Module' : 'Manage Module'),
        actions: [
          if (!isNew && !hasDraft && (isPublished || isDeprecated))
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 8),
               child: OutlinedButton.icon(
                 onPressed: _createNewVersionDraft,
                 icon: const Icon(LucideIcons.plus, size: 18),
                 label: const Text('New Version Draft'),
               ),
             ),
          if (hasDraft) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: OutlinedButton.icon(
                onPressed: _validateDraft,
                icon: const Icon(LucideIcons.checkCircle2, size: 18),
                label: const Text('Validate'),
              ),
            ),
            if (_module!.draft!.state == MarketplaceDraftState.validated)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FilledButton.icon(
                  onPressed: _publishDraft,
                  icon: const Icon(LucideIcons.upload, size: 18),
                  label: const Text('Publish'),
                ),
              ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isNew) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Visibility: ${_module!.visibility.displayName}',
                      style: theme.textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        if (isPublished)
                          OutlinedButton.icon(
                            onPressed: _deprecateModule,
                            icon: const Icon(LucideIcons.alertTriangle, size: 18),
                            label: const Text('Deprecate'),
                          ),
                        const SizedBox(width: 8),
                        if (isPublished || isDeprecated)
                           OutlinedButton.icon(
                            onPressed: _retireModule,
                            icon: const Icon(LucideIcons.archive, size: 18),
                            label: const Text('Retire'),
                          ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
              ],
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Module Name',
                  border: OutlineInputBorder(),
                ),
                enabled: canEdit,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _versionController,
                decoration: const InputDecoration(
                  labelText: 'Version (e.g. 1.0.0)',
                  border: OutlineInputBorder(),
                ),
                enabled: canEdit,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shortDescController,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                  border: OutlineInputBorder(),
                ),
                enabled: canEdit,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                enabled: canEdit,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              if (canEdit)
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _saveDraft,
                    icon: const Icon(LucideIcons.save, size: 18),
                    label: const Text('Save Draft'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
