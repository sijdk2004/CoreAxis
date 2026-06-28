import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  final String tenantId;
  const SubscriptionScreen({super.key, required this.tenantId});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final asyncState = ref.watch(subscriptionProvider(widget.tenantId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Manage Subscription'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/tenants/${widget.tenantId}'),
        ),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) => _buildBody(context, state, isDesktop),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SubscriptionState state, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentPlanSection(context, state, isDesktop),
          const SizedBox(height: 32),
          const Text('Plan Comparison', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPlanComparisonCards(context, state, isDesktop),
          const SizedBox(height: 32),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildUsageCharts(context, state)),
                const SizedBox(width: 24),
                Expanded(child: _buildBillingHistory(context, state)),
              ],
            )
          else
            Column(
              children: [
                _buildUsageCharts(context, state),
                const SizedBox(height: 24),
                _buildBillingHistory(context, state),
              ],
            ),
          const SizedBox(height: 32),
          _buildInvoicesTable(context, state, isDesktop),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanSection(BuildContext context, SubscriptionState state, bool isDesktop) {
    final theme = Theme.of(context);
    final card = PremiumCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Plan', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(state.tenant.subscriptionPlan, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: const Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Auto Renewal', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(width: 8),
                  Switch(value: state.autoRenewal, onChanged: (val) {}),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildInfoItem('Start Date', DateFormat('MMM dd, yyyy').format(state.startDate), LucideIcons.calendar)),
              Expanded(child: _buildInfoItem('Expiry Date', DateFormat('MMM dd, yyyy').format(state.expiryDate), LucideIcons.calendarClock)),
              Expanded(child: _buildInfoItem('Tenant Code', state.tenant.code, LucideIcons.hash)),
            ],
          ),
          const SizedBox(height: 32),
          _buildProgressItem('License Count', state.usedLicenses, state.maxLicenses, Colors.blue),
          const SizedBox(height: 16),
          _buildProgressItem('Storage Limit (GB)', state.usedStorageGb, state.maxStorageGb, Colors.purple),
          const SizedBox(height: 16),
          _buildProgressItem('API Limits (Calls)', state.apiCalls, state.maxApiCalls, Colors.teal),
        ],
      ),
    );

    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.arrowUpCircle), label: const Text('Upgrade Plan')),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.arrowDownCircle), label: const Text('Downgrade Plan')),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.refreshCcw), label: const Text('Renew Manually')),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        TextButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.pauseCircle), label: const Text('Suspend Subscription', style: TextStyle(color: Colors.orange))),
        const SizedBox(height: 8),
        TextButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.trash2), label: const Text('Cancel Subscription', style: TextStyle(color: Colors.red))),
      ],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: card),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: PremiumCard(padding: const EdgeInsets.all(24), child: actions)),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          card,
          const SizedBox(height: 24),
          PremiumCard(padding: const EdgeInsets.all(24), child: actions),
        ],
      );
    }
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressItem(String label, int used, int max, Color color) {
    final percent = (used / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('$used / $max', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percent,
          color: color,
          backgroundColor: color.withOpacity(0.1),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildPlanComparisonCards(BuildContext context, SubscriptionState state, bool isDesktop) {
    final plans = [
      {'name': 'Trial', 'price': 'Free', 'users': '5', 'storage': '10GB'},
      {'name': 'Basic', 'price': '\$99/mo', 'users': '20', 'storage': '50GB'},
      {'name': 'Professional', 'price': '\$299/mo', 'users': '100', 'storage': '250GB'},
      {'name': 'Enterprise', 'price': 'Custom', 'users': 'Unlimited', 'storage': '1TB'},
    ];

    Widget buildCard(Map<String, String> plan) {
      final isCurrent = state.tenant.subscriptionPlan == plan['name'];
      final theme = Theme.of(context);
      return PremiumCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCurrent)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(4)),
                child: const Text('Current Plan', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            Text(plan['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(plan['price']!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
            const SizedBox(height: 16),
            _buildFeatureRow('Users: ${plan['users']}'),
            const SizedBox(height: 8),
            _buildFeatureRow('Storage: ${plan['storage']}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: isCurrent 
                ? OutlinedButton(onPressed: null, child: const Text('Current Plan'))
                : FilledButton(onPressed: () {}, child: const Text('Select Plan')),
            )
          ],
        ),
      );
    }

    if (isDesktop) {
      return Row(
        children: plans.map((p) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16.0), child: buildCard(p)))).toList(),
      );
    } else {
      return Column(
        children: plans.map((p) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: buildCard(p))).toList(),
      );
    }
  }

  Widget _buildFeatureRow(String text) {
    return Row(
      children: [
        const Icon(LucideIcons.check, size: 16, color: Colors.green),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildUsageCharts(BuildContext context, SubscriptionState state) {
    final data = state.charts['storage_usage'] as List;
    final colors = [Colors.blue, Colors.orange, Colors.teal, Colors.grey.shade300];

    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Storage Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 50,
                      sections: data.asMap().entries.map((e) {
                        return PieChartSectionData(
                          color: colors[e.key % colors.length],
                          value: (e.value['value'] as num).toDouble(),
                          title: '${e.value['value']}%',
                          radius: 20,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[e.key % colors.length],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${e.value['label']} (${e.value['value']}%)'),
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBillingHistory(BuildContext context, SubscriptionState state) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Billing History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...state.history.map((h) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.receipt, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(DateFormat('MMM dd, yyyy').format(h.date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Text('\$${h.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInvoicesTable(BuildContext context, SubscriptionState state, bool isDesktop) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Invoices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: isDesktop ? 32 : 16,
                    headingRowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)),
                    columns: const [
                      DataColumn(label: Text('Invoice ID')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Download')),
                    ],
                    rows: state.invoices.map((inv) {
                      return DataRow(
                        cells: [
                          DataCell(Text(inv.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(DateFormat('MMM dd, yyyy').format(inv.date))),
                          DataCell(Text('\$${inv.amount.toStringAsFixed(2)}')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(inv.status, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(LucideIcons.download),
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading PDF...'))),
                            )
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}
