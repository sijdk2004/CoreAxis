import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'providers/ai_model_center_provider.dart';
import 'models/ai_provider_model.dart';

class AiModelCenterScreen extends ConsumerWidget {
  const AiModelCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(aiModelCenterProvider);
    final notifier = ref.read(aiModelCenterProvider.notifier);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, theme),
          Expanded(
            child: _buildProviderList(context, theme, state, notifier, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.cpu, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Model Center',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage AI providers and configure language models',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Add Provider'),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderList(BuildContext context, ThemeData theme, AiModelCenterState state, AiModelCenterNotifier notifier, bool isDesktop) {
    final providers = state.providers;

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 340,
      ),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        return _buildProviderCard(context, theme, providers[index], notifier);
      },
    );
  }

  Widget _buildProviderCard(BuildContext context, ThemeData theme, AiProviderModel provider, AiModelCenterNotifier notifier) {
    final isInactive = provider.status == 'Inactive' || provider.status == 'Error';
    final isError = provider.status == 'Error';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isError ? theme.colorScheme.error : theme.colorScheme.outlineVariant,
          width: isError ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isError 
                        ? theme.colorScheme.errorContainer
                        : isInactive 
                            ? theme.colorScheme.surfaceContainerHighest 
                            : theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(provider.icon), 
                    color: isError 
                        ? theme.colorScheme.error
                        : isInactive 
                            ? theme.colorScheme.onSurfaceVariant 
                            : theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.providerName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isInactive && !isError ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStatusColor(provider.status),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            provider.status,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isError ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                              fontWeight: isError ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.moreVertical, size: 20),
                  onSelected: (value) {
                    if (value == 'toggle') {
                      notifier.toggleStatus(provider.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(provider.status == 'Active' ? LucideIcons.powerOff : LucideIcons.play, size: 16),
                          const SizedBox(width: 8),
                          Text(provider.status == 'Active' ? 'Disable' : 'Enable'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.zap, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Model: ${provider.modelName}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn(context, 'Latency', '${provider.latencyMs > 0 ? provider.latencyMs : "--"} ms'),
                _buildStatColumn(context, 'Usage', _formatNumber(provider.totalRequests)),
                _buildStatColumn(context, 'Cost', '\$${provider.costUsd.toStringAsFixed(2)}'),
              ],
            ),
          ),
          
          const Spacer(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    _showConfigurationDialog(context, theme, provider, notifier);
                  },
                  child: const Text('Configure'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.1,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showConfigurationDialog(BuildContext context, ThemeData theme, AiProviderModel provider, AiModelCenterNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) {
        return _ConfigurationDialog(provider: provider, notifier: notifier);
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active': return Colors.green;
      case 'Inactive': return Colors.grey;
      case 'Error': return Colors.red;
      case 'Testing': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'cpu': return LucideIcons.cpu;
      case 'cloud': return LucideIcons.cloud;
      case 'globe': return LucideIcons.globe;
      case 'box': return LucideIcons.box;
      case 'server': return LucideIcons.server;
      default: return LucideIcons.bot;
    }
  }
  
  String _formatNumber(int num) {
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}k';
    }
    return num.toString();
  }
}

class _ConfigurationDialog extends StatefulWidget {
  final AiProviderModel provider;
  final AiModelCenterNotifier notifier;

  const _ConfigurationDialog({required this.provider, required this.notifier});

  @override
  State<_ConfigurationDialog> createState() => _ConfigurationDialogState();
}

class _ConfigurationDialogState extends State<_ConfigurationDialog> {
  late TextEditingController _endpointController;
  late TextEditingController _modelController;
  late double _temperature;
  late double _maxTokens;
  bool _isTesting = false;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _endpointController = TextEditingController(text: widget.provider.apiEndpoint);
    _modelController = TextEditingController(text: widget.provider.modelName);
    _temperature = widget.provider.temperature;
    _maxTokens = widget.provider.maxTokens.toDouble();
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _runConnectionTest() async {
    setState(() {
      _isTesting = true;
      _testSuccess = false;
    });
    
    final success = await widget.notifier.testConnection(widget.provider.id);
    
    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccess = success;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Connection successful!' : 'Connection failed.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _saveConfiguration() {
    final updatedProvider = widget.provider.copyWith(
      apiEndpoint: _endpointController.text,
      modelName: _modelController.text,
      temperature: _temperature,
      maxTokens: _maxTokens.toInt(),
    );
    widget.notifier.updateProvider(updatedProvider);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Configure ${widget.provider.providerName}',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _endpointController,
              decoration: const InputDecoration(
                labelText: 'API Endpoint',
                border: OutlineInputBorder(),
                prefixIcon: Icon(LucideIcons.link),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(LucideIcons.cpu),
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Temperature', style: theme.textTheme.bodyMedium),
                Text(_temperature.toStringAsFixed(2), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _temperature,
              min: 0.0,
              max: 2.0,
              divisions: 20,
              onChanged: (val) {
                setState(() => _temperature = val);
              },
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Max Tokens', style: theme.textTheme.bodyMedium),
                Text(_maxTokens.toInt().toString(), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _maxTokens,
              min: 256,
              max: 32768,
              divisions: 127,
              onChanged: (val) {
                setState(() => _maxTokens = val);
              },
            ),
            
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _isTesting ? null : _runConnectionTest,
                  icon: _isTesting 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(_testSuccess ? LucideIcons.check : LucideIcons.activity, size: 18),
                  label: Text(_isTesting ? 'Testing...' : (_testSuccess ? 'Test Passed' : 'Test Connection')),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _saveConfiguration,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
