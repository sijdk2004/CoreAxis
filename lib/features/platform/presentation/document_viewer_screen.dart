import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../domain/models/document_viewer_model.dart';
import 'providers/document_viewer_provider.dart';

class DocumentViewerScreen extends ConsumerWidget {
  final String documentId;
  const DocumentViewerScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // In a real app this might be an AsyncValue, but we use a sync provider for mock data
    final doc = ref.watch(documentViewerProvider(documentId));

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Column(
          children: [
            _buildHeader(context, theme, doc),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 1200;
                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 250, child: _buildLeftPane(theme, doc)),
                        Expanded(child: _buildCenterPane(theme, doc)),
                        SizedBox(width: 350, child: _buildRightPane(theme, doc)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Expanded(child: _buildCenterPane(theme, doc)),
                        Expanded(child: _buildRightPane(theme, doc)),
                      ],
                    );
                  }
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, DocumentViewerContext doc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () {
                  if (GoRouter.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.go('/platform/documents/repository');
                  }
                },
              ),
              const SizedBox(width: 8),
              Icon(_getIconForType(doc.type), color: _getColorForType(doc.type)),
              const SizedBox(width: 12),
              Text(doc.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(doc.status, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => context.push('/platform/documents/${doc.id}/versions'),
                icon: const Icon(LucideIcons.history, size: 18),
                label: const Text('Version History'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.printer, size: 18), label: const Text('Print')),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => context.push('/platform/documents/${doc.id}/sharing'),
                icon: const Icon(LucideIcons.share2, size: 18),
                label: const Text('Share'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.download, size: 18), label: const Text('Download')),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLeftPane(ThemeData theme, DocumentViewerContext doc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildInfoRow('Type', doc.type.toUpperCase(), theme),
          const SizedBox(height: 16),
          _buildInfoRow('Size', '${doc.sizeMb.toStringAsFixed(2)} MB', theme),
          const SizedBox(height: 16),
          _buildInfoRow('Owner', doc.owner, theme),
          const SizedBox(height: 16),
          _buildInfoRow('Category', doc.category, theme),
          const SizedBox(height: 16),
          _buildInfoRow('Created', DateFormat.yMMMd().format(doc.createdAt), theme),
          const SizedBox(height: 16),
          _buildInfoRow('Modified', DateFormat.yMMMd().format(doc.modifiedAt), theme),
          const SizedBox(height: 24),
          Text('Tags', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doc.tags.map((t) => Chip(
              label: Text(t, style: const TextStyle(fontSize: 12)),
              backgroundColor: theme.colorScheme.secondaryContainer,
              side: BorderSide.none,
            )).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCenterPane(ThemeData theme, DocumentViewerContext doc) {
    return Container(
      color: theme.colorScheme.background,
      padding: const EdgeInsets.all(32),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          color: Colors.white, // Paper color
          width: double.infinity,
          height: double.infinity,
          child: _buildMockPreviewContent(doc, theme),
        ),
      ),
    );
  }

  Widget _buildMockPreviewContent(DocumentViewerContext doc, ThemeData theme) {
    if (doc.type == 'excel') {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.green.shade50,
            child: Row(
              children: List.generate(10, (i) => Expanded(child: Center(child: Text(String.fromCharCode(65 + i), style: const TextStyle(fontWeight: FontWeight.bold))))),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 50,
              itemBuilder: (context, row) {
                return Row(
                  children: List.generate(10, (col) => Expanded(
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200)),
                      child: Center(child: Text(col == 0 ? '${row + 1}' : (row * col).toString(), style: const TextStyle(color: Colors.grey))),
                    ),
                  )),
                );
              },
            ),
          )
        ],
      );
    } else if (doc.type == 'word' || doc.type == 'pdf') {
      return Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doc.name.split('.').first.replaceAll('_', ' '), style: theme.textTheme.headlineLarge?.copyWith(color: Colors.black)),
            const SizedBox(height: 24),
            Container(height: 12, width: double.infinity, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Container(height: 12, width: double.infinity, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Container(height: 12, width: 200, color: Colors.grey.shade300),
            const SizedBox(height: 48),
            Text('1. Introduction', style: theme.textTheme.titleLarge?.copyWith(color: Colors.black)),
            const SizedBox(height: 16),
            ...List.generate(5, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(height: 12, width: double.infinity, color: Colors.grey.shade200),
            ))
          ],
        ),
      );
    } else if (doc.type == 'cad') {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              image: DecorationImage(
                image: const NetworkImage('https://www.transparenttextures.com/patterns/blueprint.png'),
                repeat: ImageRepeat.repeat,
                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.1), BlendMode.srcATop)
              )
            ),
          ),
          Center(
            child: Icon(LucideIcons.box, size: 200, color: Colors.white.withOpacity(0.3)),
          ),
          Positioned(bottom: 24, right: 24, child: Text('SCALE 1:100', style: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'monospace')))
        ],
      );
    } else {
      // Image or generic
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.image, size: 120, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text('Preview Generation Complete', style: TextStyle(color: Colors.grey.shade600))
          ],
        ),
      );
    }
  }

  Widget _buildRightPane(ThemeData theme, DocumentViewerContext doc) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(left: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Versions'),
              Tab(text: 'Sharing'),
              Tab(text: 'Audit'),
              Tab(text: 'Comments'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOverviewTab(theme, doc),
                _buildVersionsTab(theme, doc),
                _buildSharingTab(theme, doc),
                _buildAuditTab(theme, doc),
                _buildCommentsTab(theme, doc),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme, DocumentViewerContext doc) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(doc.description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 32),
        Text('Current Version', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(child: Icon(LucideIcons.fileClock, size: 18)),
          title: Text(doc.version),
          subtitle: Text(DateFormat.yMMMd().add_jm().format(doc.modifiedAt)),
        ),
      ],
    );
  }

  Widget _buildVersionsTab(ThemeData theme, DocumentViewerContext doc) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: doc.versions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final v = doc.versions[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(v.versionNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(DateFormat.yMMMd().format(v.date), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('By ${v.author}'),
              const SizedBox(height: 4),
              Text(v.notes, style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
          trailing: IconButton(icon: const Icon(LucideIcons.download, size: 18), onPressed: () {}),
        );
      },
    );
  }

  Widget _buildSharingTab(ThemeData theme, DocumentViewerContext doc) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FilledButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.userPlus, size: 18), label: const Text('Add People or Groups')),
        const SizedBox(height: 24),
        ...doc.sharedWith.map((user) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(child: Text(user[0])),
          title: Text(user),
          trailing: DropdownButton<String>(
            value: 'Viewer',
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'Viewer', child: Text('Viewer')),
              DropdownMenuItem(value: 'Editor', child: Text('Editor')),
            ],
            onChanged: (v) {},
          ),
        )),
      ],
    );
  }

  Widget _buildAuditTab(ThemeData theme, DocumentViewerContext doc) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: doc.auditLogs.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final log = doc.auditLogs[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(DateFormat.jm().format(log.timestamp), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 4),
              Text('${log.user} • ${log.ipAddress}', style: theme.textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsTab(ThemeData theme, DocumentViewerContext doc) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: doc.comments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final comment = doc.comments[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 16, child: Text(comment.author[0])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text(DateFormat.yMMMd().format(comment.date), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                          child: Text(comment.text),
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant))),
          child: Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: () {}, icon: const Icon(LucideIcons.send, size: 18)),
            ],
          ),
        )
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'pdf': return LucideIcons.fileText;
      case 'excel': return LucideIcons.sheet;
      case 'word': return LucideIcons.fileType2;
      case 'image': return LucideIcons.image;
      case 'cad': return LucideIcons.box;
      default: return LucideIcons.file;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'pdf': return Colors.red;
      case 'excel': return Colors.green;
      case 'word': return Colors.blue;
      case 'image': return Colors.purple;
      case 'cad': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
