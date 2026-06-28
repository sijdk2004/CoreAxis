import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../domain/models/user_invitation.dart';
import 'providers/user_invitations_provider.dart';

class UserInvitationsScreen extends ConsumerStatefulWidget {
  const UserInvitationsScreen({super.key});

  @override
  ConsumerState<UserInvitationsScreen> createState() => _UserInvitationsScreenState();
}

class _UserInvitationsScreenState extends ConsumerState<UserInvitationsScreen> {
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    // The provider self-initializes now, no need to call init here.
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _CreateInvitationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(userInvitationsProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/users'),
        ),
        title: const Text('Invitation Management'),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mock: Exporting data to CSV...'), backgroundColor: Colors.green),
              );
            },
            icon: const Icon(LucideIcons.download, size: 18),
            label: const Text('Export CSV'),
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: FilledButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(LucideIcons.userPlus, size: 18),
              label: const Text('Invite User'),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, state, isDesktop),
    );
  }

  Widget _buildBody(BuildContext context, UserInvitationsState state, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStats(state.allInvitations, isDesktop),
          const SizedBox(height: 24),
          _buildToolbar(context, state, isDesktop),
          const SizedBox(height: 16),
          _buildTable(context, state, isDesktop),
        ],
      ),
    );
  }

  Widget _buildStats(List<UserInvitation> allInvitations, bool isDesktop) {
    final pending = allInvitations.where((s) => s.status == 'Pending').length;
    final accepted = allInvitations.where((s) => s.status == 'Accepted').length;
    final expired = allInvitations.where((s) => s.status == 'Expired').length;
    final cancelled = allInvitations.where((s) => s.status == 'Cancelled').length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Pending', pending.toString(), LucideIcons.hourglass, Colors.orange, isDesktop),
        _buildStatCard('Accepted', accepted.toString(), LucideIcons.checkCircle, Colors.green, isDesktop),
        _buildStatCard('Expired', expired.toString(), LucideIcons.clock, Colors.red, isDesktop),
        _buildStatCard('Cancelled', cancelled.toString(), LucideIcons.xCircle, Colors.grey, isDesktop),
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

  Widget _buildToolbar(BuildContext context, UserInvitationsState state, bool isDesktop) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isDesktop ? 300 : double.infinity,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search email, role, org...',
              prefixIcon: const Icon(LucideIcons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (val) => ref.read(userInvitationsProvider.notifier).setSearchQuery(val),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Pending', 'Accepted', 'Expired', 'Cancelled'].map((filter) {
              final isSelected = state.selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => ref.read(userInvitationsProvider.notifier).setFilter(filter),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, UserInvitationsState state, bool isDesktop) {
    final theme = Theme.of(context);
    final invitations = state.filteredInvitations;
    
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, invitations.length);
    final currentList = invitations.sublist(startIndex, endIndex);

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
            itemCount: currentList.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor.withOpacity(0.4)),
            itemBuilder: (context, index) => _buildRow(context, currentList[index], theme),
          ),
          if (invitations.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('No invitations found.')),
            ),
          const Divider(height: 1),
          _buildPagination(context, invitations.length, startIndex, endIndex, theme),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: _headerText('User & Role')),
          Expanded(flex: 2, child: _headerText('Organization')),
          Expanded(flex: 3, child: _headerText('Timeline')),
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

  Widget _buildRow(BuildContext context, UserInvitation invitation, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invitation.email, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(invitation.role, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(invitation.organization),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sent: \${DateFormat('MMM d, y').format(invitation.invitationDate)}", style: const TextStyle(fontSize: 13)),
                Text(
                  "Expires: \${DateFormat('MMM d').format(invitation.expiryDate)}", 
                  style: TextStyle(
                    color: invitation.expiryDate.isBefore(DateTime.now()) ? Colors.red : theme.colorScheme.onSurfaceVariant, 
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusBadge(invitation.status),
          ),
          SizedBox(
            width: 48,
            child: PopupMenuButton<String>(
              icon: const Icon(LucideIcons.moreVertical),
              onSelected: (val) {
                if (val == 'resend') {
                  ref.read(userInvitationsProvider.notifier).resendInvitation(invitation.id);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation resent.')));
                } else if (val == 'cancel') {
                  ref.read(userInvitationsProvider.notifier).cancelInvitation(invitation.id);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation cancelled.')));
                }
              },
              itemBuilder: (ctx) => [
                if (invitation.status == 'Pending' || invitation.status == 'Expired')
                  const PopupMenuItem(
                    value: 'resend',
                    child: Text('Resend Invitation'),
                  ),
                if (invitation.status == 'Pending')
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Text('Cancel Invitation', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Accepted': color = Colors.green; break;
      case 'Pending': color = Colors.orange; break;
      case 'Expired': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
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

// ── Create Invitation Dialog ──────────────────────────────────────────────────
class _CreateInvitationDialog extends ConsumerStatefulWidget {
  const _CreateInvitationDialog();

  @override
  ConsumerState<_CreateInvitationDialog> createState() => _CreateInvitationDialogState();
}

class _CreateInvitationDialogState extends ConsumerState<_CreateInvitationDialog> {
  final _formKey = GlobalKey<FormState>();
  
  String _email = '';
  String _role = 'Org Admin';
  String _org = 'Stellar Inc';
  int _expiryDays = 7;
  
  bool _isSending = false;
  bool _isSuccess = false;

  void _send() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSending = true);

    await ref.read(userInvitationsProvider.notifier).createInvitation(
      email: _email,
      role: _role,
      organization: _org,
      expiryDays: _expiryDays,
    );

    if (mounted) {
      setState(() {
        _isSending = false;
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return AlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.checkCircle, color: Colors.green, size: 64),
              const SizedBox(height: 24),
              const Text('Invitation Sent!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('An email has been dispatched to $_email.', textAlign: TextAlign.center),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    }

    return AlertDialog(
      title: const Text('Invite New User'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                validator: (val) => (val == null || !val.contains('@')) ? 'Enter a valid email' : null,
                onSaved: (val) => _email = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                items: ['Org Admin', 'Sales Rep', 'Operations Manager', 'Viewer'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _role = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _org,
                decoration: const InputDecoration(labelText: 'Organization', border: OutlineInputBorder()),
                items: ['Stellar Inc', 'Acme Corp', 'Global Tech'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _org = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _expiryDays,
                decoration: const InputDecoration(labelText: 'Link Expiry', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: 7, child: Text('7 days')),
                  const DropdownMenuItem(value: 14, child: Text('14 days')),
                  const DropdownMenuItem(value: 30, child: Text('30 days')),
                ],
                onChanged: (val) => setState(() => _expiryDays = val!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isSending ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: _isSending ? null : _send,
          icon: _isSending 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(LucideIcons.send, size: 18),
          label: Text(_isSending ? 'Sending...' : 'Send Invitation'),
        ),
      ],
    );
  }
}
