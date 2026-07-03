import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/broadcast_campaign_model.dart';
import 'dart:math';

class BroadcastCampaignState {
  final List<BroadcastCampaign> campaigns;
  final String searchQuery;
  final String selectedTypeFilter;
  final bool isLoading;

  BroadcastCampaignState({
    required this.campaigns,
    this.searchQuery = '',
    this.selectedTypeFilter = 'All',
    this.isLoading = false,
  });

  BroadcastCampaignState copyWith({
    List<BroadcastCampaign>? campaigns,
    String? searchQuery,
    String? selectedTypeFilter,
    bool? isLoading,
  }) {
    return BroadcastCampaignState(
      campaigns: campaigns ?? this.campaigns,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTypeFilter: selectedTypeFilter ?? this.selectedTypeFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<BroadcastCampaign> get filteredCampaigns {
    return campaigns.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesType = selectedTypeFilter == 'All' || c.type == selectedTypeFilter;
      return matchesSearch && matchesType;
    }).toList();
  }
}

class BroadcastCampaignNotifier extends Notifier<BroadcastCampaignState> {
  @override
  BroadcastCampaignState build() {
    return BroadcastCampaignState(
      campaigns: _generateMockCampaigns(),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setTypeFilter(String type) {
    state = state.copyWith(selectedTypeFilter: type);
  }

  void addCampaign(BroadcastCampaign campaign) {
    state = state.copyWith(campaigns: [campaign, ...state.campaigns]);
  }

  void deleteCampaign(String id) {
    state = state.copyWith(campaigns: state.campaigns.where((c) => c.id != id).toList());
  }

  List<BroadcastCampaign> _generateMockCampaigns() {
    return [
      BroadcastCampaign(
        id: 'CMP_001',
        name: 'Q3 Financial Reporting Reminder',
        type: 'Reminder',
        audience: ['Department Based', 'Role Based'],
        channel: 'Email',
        status: 'Sent',
        priority: 'High',
        message: 'Please submit all expense reports before Friday.',
        recipients: 450,
        delivered: 445,
        opened: 410,
        failed: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      BroadcastCampaign(
        id: 'CMP_002',
        name: 'System Maintenance Downtime',
        type: 'Maintenance',
        audience: ['Platform Users'],
        channel: 'Push',
        status: 'Scheduled',
        priority: 'Critical',
        message: 'System will be down for maintenance on Saturday from 2AM to 4AM UTC.',
        scheduleDate: DateTime.now().add(const Duration(days: 3)),
        recipients: 12500,
        delivered: 0,
        opened: 0,
        failed: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      BroadcastCampaign(
        id: 'CMP_003',
        name: 'New Feature Release: AI Insights',
        type: 'Announcement',
        audience: ['Platform Users'],
        channel: 'In-App',
        status: 'Sent',
        priority: 'Normal',
        message: 'Check out our new AI-powered analytics dashboard!',
        recipients: 12500,
        delivered: 12400,
        opened: 8500,
        failed: 100,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      BroadcastCampaign(
        id: 'CMP_004',
        name: 'Urgent Security Patch',
        type: 'Emergency',
        audience: ['Tenant Users'],
        channel: 'SMS',
        status: 'Sent',
        priority: 'Critical',
        message: 'Important: Please update your password immediately due to a security policy change.',
        recipients: 2500,
        delivered: 2480,
        opened: 2400,
        failed: 20,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BroadcastCampaign(
        id: 'CMP_005',
        name: 'Holiday Discount Promo',
        type: 'Marketing',
        audience: ['Organization Users'],
        channel: 'Email',
        status: 'Draft',
        priority: 'Low',
        message: 'Get 20% off annual subscriptions this holiday season.',
        recipients: 0,
        delivered: 0,
        opened: 0,
        failed: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }
}

final broadcastCampaignProvider = NotifierProvider<BroadcastCampaignNotifier, BroadcastCampaignState>(() {
  return BroadcastCampaignNotifier();
});
