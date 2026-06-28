import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../domain/models/user_session.dart';
import 'providers/user_sessions_provider.dart';

class UserSessionsScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserSessionsScreen({super.key, required this.userId});

  @override
  ConsumerState<UserSessionsScreen> createState() => _UserSessionsScreenState();
}

class _UserSessionsScreenState extends ConsumerState<UserSessionsScreen> {
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userSessionsProvider.notifier).init(widget.userId);
    });
  }

  void _terminateAllSessions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terminate All Sessions?'),
        content: const Text('This will log the user out of all active devices immediately. They will need to log back in to access the platform.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(userSessionsProvider.notifier).terminateAllSessions();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All sessions terminated.'), backgroundColor: Colors.green));
            },
            child: const Text('Terminate All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(userSessionsProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/users/\${widget.userId}'),
        ),
        title: const Text('Session Management'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
              ),
              onPressed: _terminateAllSessions,
              icon: const Icon(LucideIcons.shieldAlert, size: 18),
              label: const Text('Terminate All Sessions'),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, state, isDesktop),
    );
  }

  Widget _buildBody(BuildContext context, UserSessionsState state, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStats(state.allSessions, isDesktop),
          const SizedBox(height: 24),
          _buildToolbar(context, state, isDesktop),
          const SizedBox(height: 16),
          _buildTable(context, state, isDesktop),
        ],
      ),
    );
  }

  Widget _buildStats(List<UserSession> allSessions, bool isDesktop) {
    final activeCount = allSessions.where((s) => s.status == 'Active').length;
    final mobileCount = allSessions.where((s) => s.os.contains('iOS') || s.os.contains('Android') || s.os.contains('iPadOS')).length;
    final desktopCount = allSessions.where((s) => s.os.contains('macOS') || s.os.contains('Windows')).length;
    final browserCount = allSessions.where((s) => s.browser != 'Native App').length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Active Sessions', activeCount.toString(), LucideIcons.activity, Colors.green, isDesktop),
        _buildStatCard('Mobile Devices', mobileCount.toString(), LucideIcons.smartphone, Colors.blue, isDesktop),
        _buildStatCard('Desktop Devices', desktopCount.toString(), LucideIcons.monitor, Colors.purple, isDesktop),
        _buildStatCard('Browser Sessions', browserCount.toString(), LucideIcons.globe, Colors.orange, isDesktop),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDesktop) {
    return SizedBox(
      width: isDesktop ? 250 : double.infinity,
      child: PremiumCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, UserSessionsState state, bool isDesktop) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isDesktop ? 300 : double.infinity,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search sessions...',
              prefixIcon: const Icon(LucideIcons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (val) => ref.read(userSessionsProvider.notifier).setSearchQuery(val),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Desktop', 'Mobile', 'Browser', 'Active', 'Expired'].map((filter) {
              final isSelected = state.selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => ref.read(userSessionsProvider.notifier).setFilter(filter),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, UserSessionsState state, bool isDesktop) {
    final theme = Theme.of(context);
    final sessions = state.filteredSessions;
    
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, sessions.length);
    final currentSessions = sessions.sublist(startIndex, endIndex);

    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderRow(context),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentSessions.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor.withOpacity(0.4)),
            itemBuilder: (context, index) => _buildSessionRow(context, currentSessions[index], theme),
          ),
          if (sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('No sessions found.')),
            ),
          const Divider(height: 1),
          _buildPagination(context, sessions.length, startIndex, endIndex, theme),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: _headerText('Device')),
          Expanded(flex: 2, child: _headerText('IP Address')),
          Expanded(flex: 2, child: _headerText('Location')),
          Expanded(flex: 2, child: _headerText('Last Activity')),
          Expanded(flex: 1, child: _headerText('Status')),
          const SizedBox(width: 48), // Actions
        ],
      ),
    );
  }

  Widget _headerText(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSessionRow(BuildContext context, UserSession session, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(
                  session.os.contains('iOS') || session.os.contains('Android') ? LucideIcons.smartphone : LucideIcons.monitor,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.device, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('\${session.browser} on \${session.os}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(session.ipAddress),
          ),
          Expanded(
            flex: 2,
            child: Text(session.location),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMM d, y, h:mm a').format(session.lastActivity)),
                Text("Logged in: \${DateFormat('MMM d').format(session.loginTime)}", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: session.status == 'Active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                session.status,
                style: TextStyle(
                  color: session.status == 'Active' ? Colors.green[700] : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: session.status == 'Active' 
                ? PopupMenuButton<String>(
                    icon: const Icon(LucideIcons.moreVertical),
                    onSelected: (val) {
                      if (val == 'terminate') {
                        ref.read(userSessionsProvider.notifier).terminateSession(session.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session terminated.')));
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'terminate',
                        child: Text('Terminate Session', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, int totalItems, int startIndex, int endIndex, ThemeData theme) {
    final totalPages = (totalItems / _itemsPerPage).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing \${totalItems > 0 ? startIndex + 1 : 0} to \$endIndex of \$totalItems entries',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
          ),
          if (totalPages > 1)
            Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.chevronLeft, size: 20),
                  onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                ),
                const SizedBox(width: 8),
                Text('Page \${_currentPage + 1} of \$totalPages', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.chevronRight, size: 20),
                  onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
