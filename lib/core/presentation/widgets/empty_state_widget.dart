import 'package:flutter/material.dart';

class PlatformEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;

  const PlatformEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.primaryActionText,
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (primaryActionText != null || secondaryActionText != null) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (secondaryActionText != null) ...[
                    OutlinedButton(
                      onPressed: onSecondaryAction,
                      child: Text(secondaryActionText!),
                    ),
                    if (primaryActionText != null) const SizedBox(width: 16),
                  ],
                  if (primaryActionText != null)
                    FilledButton(
                      onPressed: onPrimaryAction,
                      child: Text(primaryActionText!),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
