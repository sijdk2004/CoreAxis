import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/widgets/toast_service.dart';

class ToastPlaygroundScreen extends ConsumerStatefulWidget {
  const ToastPlaygroundScreen({super.key});

  @override
  ConsumerState<ToastPlaygroundScreen> createState() => _ToastPlaygroundScreenState();
}

class _ToastPlaygroundScreenState extends ConsumerState<ToastPlaygroundScreen> {
  ToastType _selectedType = ToastType.success;
  ToastPosition _selectedPosition = ToastPosition.topRight;
  bool _includeMessage = true;
  bool _includeAction = false;
  double _durationSeconds = 4.0;

  void _triggerToast() {
    String title;
    String? message;
    
    switch (_selectedType) {
      case ToastType.success:
        title = 'Saved Successfully';
        message = 'Your changes have been saved to the database.';
        break;
      case ToastType.error:
        title = 'Failed to Save';
        message = 'A network error occurred while saving.';
        break;
      case ToastType.warning:
        title = 'Unsaved Changes';
        message = 'You have unsaved changes in your form.';
        break;
      case ToastType.info:
        title = 'System Update';
        message = 'A new version of the platform is available.';
        break;
      case ToastType.progress:
        title = 'Exporting Data';
        message = 'Please wait while we generate your report.';
        break;
      case ToastType.undo:
        title = 'Item Deleted';
        message = 'The record was successfully deleted.';
        break;
    }

    if (!_includeMessage) message = null;

    PlatformToastService().showToast(
      context,
      type: _selectedType,
      title: title,
      message: message,
      position: _selectedPosition,
      duration: Duration(milliseconds: (_durationSeconds * 1000).toInt()),
      actionLabel: _includeAction || _selectedType == ToastType.undo ? 'Undo' : null,
      onAction: _includeAction || _selectedType == ToastType.undo ? () {
        PlatformToastService().showToast(
          context,
          type: ToastType.info,
          title: 'Action Reversed',
          position: _selectedPosition,
        );
      } : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Global Toast Notification System'),
        centerTitle: false,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Control Panel
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: theme.dividerColor)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Text('Toast Configuration', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                // Type Selection
                Text('Type', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ToastType.values.map((type) => ChoiceChip(
                    label: Text(type.name.toUpperCase()),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = type);
                    },
                  )).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Position Selection
                Text('Position', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ToastPosition.values.map((pos) => ChoiceChip(
                    label: Text(pos.name),
                    selected: _selectedPosition == pos,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedPosition = pos);
                    },
                  )).toList(),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Toggles
                SwitchListTile(
                  title: const Text('Include Description'),
                  value: _includeMessage,
                  onChanged: (val) => setState(() => _includeMessage = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Include Action Button'),
                  value: _includeAction,
                  onChanged: (val) => setState(() => _includeAction = val),
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 24),
                
                // Duration
                Text('Duration: ${_durationSeconds.toStringAsFixed(1)}s', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                Slider(
                  value: _durationSeconds,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (val) => setState(() => _durationSeconds = val),
                ),

                const SizedBox(height: 32),
                
                FilledButton(
                  onPressed: _triggerToast,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Trigger Toast'),
                ),
              ],
            ),
          ),
        ),

          // Preview Area
          Expanded(
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: const Center(
                child: Text('Toast Playground\nConfigure and trigger toasts from the left panel.', textAlign: TextAlign.center),
              ),
            ),
          )
        ],
      ),
    );
  }
}
