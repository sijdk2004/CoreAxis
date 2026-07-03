import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/presentation/widgets/feedback_patterns.dart';

class FeedbackCenterScreen extends ConsumerStatefulWidget {
  const FeedbackCenterScreen({super.key});

  @override
  ConsumerState<FeedbackCenterScreen> createState() => _FeedbackCenterScreenState();
}

class _FeedbackCenterScreenState extends ConsumerState<FeedbackCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Global Feedback Center'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(LucideIcons.checkCircle2), text: 'Success'),
            Tab(icon: Icon(LucideIcons.alertTriangle), text: 'Warning'),
            Tab(icon: Icon(LucideIcons.xCircle), text: 'Error'),
            Tab(icon: Icon(LucideIcons.info), text: 'Info'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedbackTab(
            theme: theme,
            type: FeedbackType.success,
            examples: [
              _FeedbackExample('Saved Successfully', 'Your changes have been saved.'),
              _FeedbackExample('User Created', 'The new user account has been successfully provisioned.'),
              _FeedbackExample('Workflow Published', 'The workflow is now active and published to all tenants.'),
              _FeedbackExample('Report Generated', 'Your monthly analytics report is ready to download.'),
            ],
          ),
          _buildFeedbackTab(
            theme: theme,
            type: FeedbackType.warning,
            examples: [
              _FeedbackExample('Unsaved Changes', 'You have unsaved changes that will be lost if you leave.'),
              _FeedbackExample('Session Expiring', 'Your session will expire in 5 minutes due to inactivity.'),
              _FeedbackExample('Validation Warning', 'Some fields are missing, which may cause issues later.'),
            ],
          ),
          _buildFeedbackTab(
            theme: theme,
            type: FeedbackType.error,
            examples: [
              _FeedbackExample('Server Error', 'Unable to connect to the server (500). Please try again later.'),
              _FeedbackExample('Permission Denied', 'You do not have the required permissions to perform this action.'),
              _FeedbackExample('Network Error', 'Check your internet connection and try again.'),
            ],
          ),
          _buildFeedbackTab(
            theme: theme,
            type: FeedbackType.info,
            examples: [
              _FeedbackExample('Maintenance Scheduled', 'The system will be down for maintenance on Saturday at 2 AM.'),
              _FeedbackExample('Feature Coming Soon', 'This feature is currently in beta and will be available soon.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTab({
    required ThemeData theme,
    required FeedbackType type,
    required List<_FeedbackExample> examples,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inline Patterns', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInlineSection(type, examples),
          const SizedBox(height: 48),
          Text('Overlay Patterns', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildOverlaySection(type, examples),
        ],
      ),
    );
  }

  Widget _buildInlineSection(FeedbackType type, List<_FeedbackExample> examples) {
    return Wrap(
      spacing: 32,
      runSpacing: 32,
      children: [
        // Banners
        SizedBox(
          width: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Banner (Full Width)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...examples.take(2).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: PlatformFeedbackBanner(type: type, message: '${e.title}: ${e.message}', onDismiss: () {}),
              )),
            ],
          ),
        ),
        // Cards
        SizedBox(
          width: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Card (Inline Component)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...examples.take(2).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: PlatformFeedbackCard(type: type, title: e.title, message: e.message),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverlaySection(FeedbackType type, List<_FeedbackExample> examples) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: examples.map((e) => _buildOverlayTrigger(type, e.title, e.message)).toList(),
    );
  }

  Widget _buildOverlayTrigger(FeedbackType type, String title, String message) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(LucideIcons.appWindow, size: 16),
                  label: const Text('Dialog'),
                  onPressed: () => PlatformFeedbackService.showDialog(context: context, type: type, title: title, message: message),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(LucideIcons.panelBottom, size: 16),
                  label: const Text('Snackbar'),
                  onPressed: () => PlatformFeedbackService.showSnackbar(context: context, type: type, message: '$title: $message'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(LucideIcons.messageSquare, size: 16),
                  label: const Text('Toast'),
                  onPressed: () => PlatformFeedbackService.showToast(context: context, type: type, message: title),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _FeedbackExample {
  final String title;
  final String message;

  _FeedbackExample(this.title, this.message);
}
