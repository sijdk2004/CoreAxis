import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum FeedbackType { success, warning, error, info }

class FeedbackHelper {
  static Color getColor(BuildContext context, FeedbackType type) {
    switch (type) {
      case FeedbackType.success: return Colors.green.shade600;
      case FeedbackType.warning: return Colors.orange.shade600;
      case FeedbackType.error: return Colors.red.shade600;
      case FeedbackType.info: return Colors.blue.shade600;
    }
  }

  static IconData getIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.success: return LucideIcons.checkCircle2;
      case FeedbackType.warning: return LucideIcons.alertTriangle;
      case FeedbackType.error: return LucideIcons.xCircle;
      case FeedbackType.info: return LucideIcons.info;
    }
  }
}

// 1. Platform Feedback Card
class PlatformFeedbackCard extends StatelessWidget {
  final FeedbackType type;
  final String title;
  final String message;

  const PlatformFeedbackCard({
    super.key,
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = FeedbackHelper.getColor(context, type);
    final icon = FeedbackHelper.getIcon(type);

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 2. Platform Feedback Banner
class PlatformFeedbackBanner extends StatelessWidget {
  final FeedbackType type;
  final String message;
  final VoidCallback? onDismiss;

  const PlatformFeedbackBanner({
    super.key,
    required this.type,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = FeedbackHelper.getColor(context, type);
    final icon = FeedbackHelper.getIcon(type);

    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.white, size: 20),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

// 3. Platform Feedback Service (Dialogs, Snackbars, Toasts)
class PlatformFeedbackService {
  
  static void showDialog({
    required BuildContext context,
    required FeedbackType type,
    required String title,
    required String message,
  }) {
    final color = FeedbackHelper.getColor(context, type);
    final icon = FeedbackHelper.getIcon(type);
    
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return AlertDialog(
          icon: Icon(icon, color: color, size: 48),
          title: Text(title),
          content: Text(message, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(backgroundColor: color),
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  static void showSnackbar({
    required BuildContext context,
    required FeedbackType type,
    required String message,
  }) {
    final color = FeedbackHelper.getColor(context, type);
    final icon = FeedbackHelper.getIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.fixed,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  static void showToast({
    required BuildContext context,
    required FeedbackType type,
    required String message,
  }) {
    final color = FeedbackHelper.getColor(context, type);
    final icon = FeedbackHelper.getIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        width: 400, // Fixed width for toast style
      ),
    );
  }
}
