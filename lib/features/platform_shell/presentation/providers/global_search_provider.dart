import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/global_search_model.dart';

class CommandPaletteState {
  final String query;
  final List<CommandItem> allCommands;

  const CommandPaletteState({
    this.query = '',
    required this.allCommands,
  });

  CommandPaletteState copyWith({
    String? query,
    List<CommandItem>? allCommands,
  }) {
    return CommandPaletteState(
      query: query ?? this.query,
      allCommands: allCommands ?? this.allCommands,
    );
  }

  List<CommandItem> get filteredCommands {
    if (query.isEmpty) {
      return allCommands.where((c) => c.group == CommandGroup.recent || c.group == CommandGroup.favorites).toList()
        ..sort((a, b) => a.group.index.compareTo(b.group.index));
    }
    
    final lowerQuery = query.toLowerCase();
    return allCommands.where((r) {
      return r.title.toLowerCase().contains(lowerQuery) || 
             (r.subtitle?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList()
      ..sort((a, b) => a.group.index.compareTo(b.group.index));
  }
}

class CommandPaletteNotifier extends Notifier<CommandPaletteState> {
  @override
  CommandPaletteState build() {
    return const CommandPaletteState(
      allCommands: [
        // Recent
        CommandItem(id: 'rec-1', title: 'Go to Dashboard', subtitle: 'Platform Analytics', icon: LucideIcons.layoutDashboard, group: CommandGroup.recent, route: '/platform/dashboard'),
        CommandItem(id: 'rec-2', title: 'Generate Report', subtitle: 'Create a new analytics report', icon: LucideIcons.pieChart, group: CommandGroup.recent, actionType: 'report'),
        
        // Favorites
        CommandItem(id: 'fav-1', title: 'Open Users', subtitle: 'Manage identities and profiles', icon: LucideIcons.users, group: CommandGroup.favorites, route: '/platform/users'),
        CommandItem(id: 'fav-2', title: 'Create Workflow', subtitle: 'Design business process', icon: LucideIcons.workflow, group: CommandGroup.favorites, actionType: 'workflow'),
        
        // Navigation
        CommandItem(id: 'nav-1', title: 'Go to Dashboard', icon: LucideIcons.layoutDashboard, group: CommandGroup.navigation, route: '/platform/dashboard'),
        CommandItem(id: 'nav-2', title: 'Open Users', icon: LucideIcons.users, group: CommandGroup.navigation, route: '/platform/users'),
        CommandItem(id: 'nav-3', title: 'Open AI', icon: LucideIcons.bot, group: CommandGroup.navigation, route: '/platform/ai'),
        CommandItem(id: 'nav-4', title: 'View Documents', icon: LucideIcons.fileText, group: CommandGroup.navigation, route: '/platform/documents'),
        CommandItem(id: 'nav-5', title: 'Search Organizations', icon: LucideIcons.network, group: CommandGroup.navigation, route: '/platform/organizations'),
        CommandItem(id: 'nav-6', title: 'Settings', icon: LucideIcons.settings, group: CommandGroup.navigation, route: '/platform/settings'),
        
        // Actions
        CommandItem(id: 'act-1', title: 'Create Tenant', subtitle: 'Provision new tenant', icon: LucideIcons.building, group: CommandGroup.actions, actionType: 'tenant'),
        CommandItem(id: 'act-2', title: 'Generate Report', subtitle: 'Create new report', icon: LucideIcons.pieChart, group: CommandGroup.actions, actionType: 'report'),
        CommandItem(id: 'act-3', title: 'Create Workflow', subtitle: 'Visual workflow designer', icon: LucideIcons.workflow, group: CommandGroup.actions, actionType: 'workflow'),
        CommandItem(id: 'act-4', title: 'Logout', subtitle: 'Sign out of the platform', icon: LucideIcons.logOut, group: CommandGroup.actions, actionType: 'logout'),
      ],
    );
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }
  
  void clearQuery() {
    state = state.copyWith(query: '');
  }
}

final globalSearchProvider = NotifierProvider<CommandPaletteNotifier, CommandPaletteState>(() {
  return CommandPaletteNotifier();
});
