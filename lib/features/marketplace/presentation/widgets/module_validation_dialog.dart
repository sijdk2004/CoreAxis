import 'package:flutter/material.dart';
import '../../domain/models/marketplace_validation_result.dart';

class ModuleValidationDialog extends StatelessWidget {
  final MarketplaceValidationResult validationResult;

  const ModuleValidationDialog({
    super.key,
    required this.validationResult,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            validationResult.isValid ? Icons.check_circle : Icons.error,
            color: validationResult.isValid ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(validationResult.isValid ? 'Validation Successful' : 'Validation Failed'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (validationResult.errors.isNotEmpty) ...[
                Text(
                  'Errors',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...validationResult.errors.map((error) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.close, size: 16, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(error, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
              ],
              
              if (validationResult.warnings.isNotEmpty) ...[
                Text(
                  'Warnings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...validationResult.warnings.map((warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(child: Text(warning, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                )),
              ],

              if (validationResult.isValid && validationResult.warnings.isEmpty)
                Text(
                  'All checks passed. The module is ready for publication.',
                  style: theme.textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
