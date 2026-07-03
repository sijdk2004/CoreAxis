import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../domain/models/notification_channel_model.dart';
import 'providers/notification_channel_provider.dart';

class NotificationChannelScreen extends ConsumerWidget {
  const NotificationChannelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(notificationChannelProvider);
    final notifier = ref.read(notificationChannelProvider.notifier);

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
                  _buildHeader(context, theme),
                  const SizedBox(height: 24),
                  _buildChannelGrid(context, theme, state, notifier),
                  const SizedBox(height: 32),
                  _buildChartsSection(context, theme, state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Channel Management', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: () {},
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildChannelGrid(BuildContext context, ThemeData theme, NotificationChannelState state, NotificationChannelNotifier notifier) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.6,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: state.channels.length,
          itemBuilder: (context, index) {
            final channel = state.channels[index];
            return _buildChannelCard(context, theme, channel, notifier);
          },
        );
      }
    );
  }

  Widget _buildChannelCard(BuildContext context, ThemeData theme, NotificationChannel channel, NotificationChannelNotifier notifier) {
    IconData icon;
    Color iconColor;
    switch (channel.id) {
      case 'CH_EMAIL': icon = LucideIcons.mail; iconColor = Colors.blue; break;
      case 'CH_SMS': icon = LucideIcons.messageSquare; iconColor = Colors.green; break;
      case 'CH_PUSH': icon = LucideIcons.smartphone; iconColor = Colors.purple; break;
      case 'CH_WA': icon = LucideIcons.messageCircle; iconColor = Colors.teal; break;
      case 'CH_INAPP': icon = LucideIcons.bell; iconColor = Colors.orange; break;
      default: icon = LucideIcons.box; iconColor = Colors.grey;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: iconColor),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(channel.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text(channel.provider, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: channel.isEnabled,
                  onChanged: (val) => notifier.toggleChannelStatus(channel.id, val),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Messages Sent', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('${channel.messagesSent}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Success Rate', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('${(channel.successRate * 100).toStringAsFixed(1)}%', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: channel.successRate > 0.95 ? Colors.green : Colors.orange)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    _buildStatusBadge(channel.configStatus, theme),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showConfigDialog(context, theme, channel, notifier),
                child: const Text('Configure'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color;
    if (status == 'Active') color = Colors.green;
    else if (status == 'Disabled') color = Colors.grey;
    else color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, ThemeData theme, NotificationChannelState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;
        
        final usageChart = _buildUsageChartCard(theme, state);
        final successChart = _buildSuccessChartCard(theme, state);

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: usageChart),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: successChart),
            ],
          );
        } else {
          return Column(
            children: [
              usageChart,
              const SizedBox(height: 24),
              successChart,
            ],
          );
        }
      },
    );
  }

  Widget _buildUsageChartCard(ThemeData theme, NotificationChannelState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Channel Usage (Last 6 Months)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 30000,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value >= 0 && value < state.usageData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(state.usageData[value.toInt()].month, style: const TextStyle(fontSize: 12)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value == 0) return const Text('0');
                          return Text('${(value / 1000).toInt()}k', style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: state.usageData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(toY: data.emailVolume.toDouble(), color: Colors.blue, width: 12, borderRadius: BorderRadius.circular(2)),
                        BarChartRodData(toY: data.pushVolume.toDouble(), color: Colors.purple, width: 12, borderRadius: BorderRadius.circular(2)),
                        BarChartRodData(toY: data.smsVolume.toDouble(), color: Colors.green, width: 12, borderRadius: BorderRadius.circular(2)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Email', Colors.blue),
                const SizedBox(width: 16),
                _buildLegendItem('Push', Colors.purple),
                const SizedBox(width: 16),
                _buildLegendItem('SMS', Colors.green),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSuccessChartCard(ThemeData theme, NotificationChannelState state) {
    // Calculate overall average success rate for active channels
    final activeChannels = state.channels.where((c) => c.isEnabled).toList();
    double avgSuccess = 0.0;
    if (activeChannels.isNotEmpty) {
      avgSuccess = activeChannels.fold(0.0, (sum, c) => sum + c.successRate) / activeChannels.length;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overall Delivery Success', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 70,
                      startDegreeOffset: 270,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: avgSuccess * 100,
                          title: '',
                          radius: 20,
                        ),
                        PieChartSectionData(
                          color: theme.colorScheme.surfaceVariant,
                          value: (1 - avgSuccess) * 100,
                          title: '',
                          radius: 20,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${(avgSuccess * 100).toStringAsFixed(1)}%', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('Delivered', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Breakdown by Channel', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...activeChannels.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(c.name, style: theme.textTheme.bodySmall),
                  Text('${(c.successRate * 100).toStringAsFixed(1)}%', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _showConfigDialog(BuildContext context, ThemeData theme, NotificationChannel channel, NotificationChannelNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) {
        return _ConfigurationDialog(channel: channel, notifier: notifier);
      }
    );
  }
}

class _ConfigurationDialog extends StatefulWidget {
  final NotificationChannel channel;
  final NotificationChannelNotifier notifier;

  const _ConfigurationDialog({required this.channel, required this.notifier});

  @override
  State<_ConfigurationDialog> createState() => _ConfigurationDialogState();
}

class _ConfigurationDialogState extends State<_ConfigurationDialog> {
  late TextEditingController _providerController;
  late TextEditingController _apiKeyController;
  late TextEditingController _senderNameController;
  late TextEditingController _senderEmailController;
  late TextEditingController _webhookUrlController;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _providerController = TextEditingController(text: widget.channel.provider);
    _apiKeyController = TextEditingController(text: widget.channel.apiKey);
    _senderNameController = TextEditingController(text: widget.channel.senderName);
    _senderEmailController = TextEditingController(text: widget.channel.senderEmail);
    _webhookUrlController = TextEditingController(text: widget.channel.webhookUrl);
  }

  @override
  void dispose() {
    _providerController.dispose();
    _apiKeyController.dispose();
    _senderNameController.dispose();
    _senderEmailController.dispose();
    _webhookUrlController.dispose();
    super.dispose();
  }

  void _testConnection() async {
    setState(() => _isTesting = true);
    final success = await widget.notifier.testConnection(widget.channel.id);
    if (!mounted) return;
    setState(() => _isTesting = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection test successful!'), backgroundColor: Colors.green));
    }
  }

  void _saveConfig() {
    final updated = widget.channel.copyWith(
      provider: _providerController.text,
      apiKey: _apiKeyController.text,
      senderName: _senderNameController.text,
      senderEmail: _senderEmailController.text,
      webhookUrl: _webhookUrlController.text,
    );
    widget.notifier.updateChannelConfig(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuration saved successfully.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(LucideIcons.settings, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('Configure ${widget.channel.name}'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Provider Name', _providerController, theme),
              const SizedBox(height: 16),
              _buildTextField('API Key / Token', _apiKeyController, theme, obscureText: true),
              const SizedBox(height: 16),
              if (widget.channel.id == 'CH_EMAIL') ...[
                _buildTextField('Sender Name', _senderNameController, theme),
                const SizedBox(height: 16),
                _buildTextField('Sender Email', _senderEmailController, theme),
                const SizedBox(height: 16),
              ],
              _buildTextField('Webhook URL', _webhookUrlController, theme),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: _isTesting ? null : _testConnection,
          icon: _isTesting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(LucideIcons.zap, size: 16),
          label: const Text('Test Connection'),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveConfig,
          child: const Text('Save Changes'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, ThemeData theme, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
          ),
        ),
      ],
    );
  }
}
