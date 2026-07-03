import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../domain/models/document_upload_model.dart';
import 'providers/document_upload_provider.dart';
import 'dart:math';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedCategory = 'Financials';
  String _selectedOrganization = 'Acme Corp';
  String _selectedModule = 'Finance';
  String _selectedFolder = 'Q1 Reports';
  final _tagsController = TextEditingController(text: 'finance, Q1, report');
  final _descController = TextEditingController(text: '');
  final _versionController = TextEditingController(text: 'Initial upload');
  bool _simulateError = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(documentUploadProvider);
    final notifier = ref.read(documentUploadProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1000;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enterprise Upload Center', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 32),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildLeftColumn(theme, notifier)),
                            const SizedBox(width: 32),
                            Expanded(flex: 2, child: _buildRightColumn(theme, state, notifier)),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLeftColumn(theme, notifier),
                            const SizedBox(height: 32),
                            _buildRightColumn(theme, state, notifier),
                          ],
                        ),
                    ],
                  ),
                ),
              )
            ],
          );
        }
      ),
    );
  }

  Widget _buildLeftColumn(ThemeData theme, DocumentUploadNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDropZone(theme, notifier),
        const SizedBox(height: 24),
        _buildMetadataForm(theme),
      ],
    );
  }

  Widget _buildDropZone(ThemeData theme, DocumentUploadNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 2, style: BorderStyle.solid), // In a real app, use a package for dashed borders
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(LucideIcons.cloudUpload, size: 64, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text('Drag & drop your files here', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Supports PDF, DOCX, XLSX, PPT, PNG up to 250MB.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _startMockUpload(notifier);
                  }
                },
                icon: const Icon(LucideIcons.folderSearch, size: 18),
                label: const Text('Browse Files'),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Checkbox(value: _simulateError, onChanged: (v) => setState(() => _simulateError = v!)),
                  const Text('Simulate Failure'),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  void _startMockUpload(DocumentUploadNotifier notifier) {
    final r = Random();
    final names = ['Financial_Statement_Final', 'HR_Policy_Draft', 'Architecture_V2', 'Meeting_Transcript'];
    final exts = ['.pdf', '.docx', '.xlsx'];
    
    final item = UploadTaskItem(
      id: 'TASK-${DateTime.now().millisecondsSinceEpoch}',
      fileName: '${names[r.nextInt(names.length)]}${exts[r.nextInt(exts.length)]}',
      fileSizeMb: r.nextDouble() * 15 + 1,
      status: UploadTaskStatus.pending,
      progress: 0.0,
      category: _selectedCategory,
      organization: _selectedOrganization,
      module: _selectedModule,
      folder: _selectedFolder,
      tags: _tagsController.text,
      description: _descController.text,
    );

    notifier.startMockUpload(item, forceFail: _simulateError);
  }

  Widget _buildMetadataForm(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Document Metadata', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Financials', child: Text('Financials')),
                        DropdownMenuItem(value: 'Human Resources', child: Text('Human Resources')),
                        DropdownMenuItem(value: 'Legal', child: Text('Legal')),
                      ],
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedOrganization,
                      decoration: const InputDecoration(labelText: 'Organization', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Acme Corp', child: Text('Acme Corp')),
                        DropdownMenuItem(value: 'Globex', child: Text('Globex')),
                        DropdownMenuItem(value: 'Internal', child: Text('Internal')),
                      ],
                      onChanged: (val) => setState(() => _selectedOrganization = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedModule,
                      decoration: const InputDecoration(labelText: 'Module', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Finance', child: Text('Finance')),
                        DropdownMenuItem(value: 'HR', child: Text('HR')),
                        DropdownMenuItem(value: 'IT', child: Text('IT')),
                      ],
                      onChanged: (val) => setState(() => _selectedModule = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFolder,
                      decoration: const InputDecoration(labelText: 'Destination Folder', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Q1 Reports', child: Text('Q1 Reports')),
                        DropdownMenuItem(value: 'Invoices', child: Text('Invoices')),
                        DropdownMenuItem(value: 'Policies', child: Text('Policies')),
                      ],
                      onChanged: (val) => setState(() => _selectedFolder = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma separated)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _versionController,
                decoration: const InputDecoration(labelText: 'Version Notes', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightColumn(ThemeData theme, DocumentUploadState state, DocumentUploadNotifier notifier) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Upload Queue', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (state.completed.isNotEmpty)
                  TextButton(
                    onPressed: notifier.clearCompleted,
                    child: const Text('Clear Completed'),
                  )
              ],
            ),
          ),
          const Divider(height: 1),
          if (state.queue.isEmpty)
            Padding(
              padding: const EdgeInsets.all(64.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.list, size: 48, color: theme.colorScheme.outlineVariant),
                    const SizedBox(height: 16),
                    Text('Queue is empty', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.queue.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildQueueItem(state.queue[index], theme, notifier);
              },
            )
        ],
      ),
    );
  }

  Widget _buildQueueItem(UploadTaskItem item, ThemeData theme, DocumentUploadNotifier notifier) {
    IconData statusIcon;
    Color statusColor;

    switch (item.status) {
      case UploadTaskStatus.pending:
      case UploadTaskStatus.uploading:
        statusIcon = LucideIcons.loader;
        statusColor = theme.colorScheme.primary;
        break;
      case UploadTaskStatus.completed:
        statusIcon = LucideIcons.checkCircle2;
        statusColor = Colors.green;
        break;
      case UploadTaskStatus.failed:
        statusIcon = LucideIcons.alertCircle;
        statusColor = Colors.red;
        break;
      case UploadTaskStatus.cancelled:
        statusIcon = LucideIcons.xCircle;
        statusColor = Colors.grey;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.fileName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${item.fileSizeMb.toStringAsFixed(1)} MB • ${item.folder}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (item.status == UploadTaskStatus.uploading)
                IconButton(icon: const Icon(LucideIcons.x, size: 18), onPressed: () => notifier.cancelUpload(item.id), tooltip: 'Cancel'),
              if (item.status == UploadTaskStatus.failed || item.status == UploadTaskStatus.cancelled)
                IconButton(icon: const Icon(LucideIcons.refreshCw, size: 18), onPressed: () => notifier.retryUpload(item.id), tooltip: 'Retry'),
            ],
          ),
          if (item.status == UploadTaskStatus.uploading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: item.progress),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Uploading...', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                Text('${(item.progress * 100).toInt()}%', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
              ],
            )
          ],
          if (item.status == UploadTaskStatus.failed && item.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(item.errorMessage!, style: const TextStyle(fontSize: 12, color: Colors.red)),
          ]
        ],
      ),
    );
  }
}
