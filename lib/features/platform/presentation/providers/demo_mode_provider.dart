import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/demo_profile_model.dart';

final demoModeProvider = NotifierProvider<DemoModeNotifier, List<DemoProfileModel>>(() {
  return DemoModeNotifier();
});

class DemoModeNotifier extends Notifier<List<DemoProfileModel>> {
  @override
  List<DemoProfileModel> build() {
    return [
      DemoProfileModel(
        id: '1',
        name: 'Small Furniture Factory',
        industry: 'Furniture Manufacturing',
        size: 'Small (1-50)',
        description: 'A boutique furniture maker with custom orders and local supply chains.',
        icon: LucideIcons.sofa,
        isActive: true,
        lastActivated: DateTime.now(),
      ),
      DemoProfileModel(
        id: '2',
        name: 'Medium Manufacturer',
        industry: 'General Manufacturing',
        size: 'Medium (50-250)',
        description: 'Standard manufacturing with structured procurement and regional sales.',
        icon: LucideIcons.factory,
        lastActivated: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DemoProfileModel(
        id: '3',
        name: 'Enterprise Manufacturing',
        industry: 'Heavy Manufacturing',
        size: 'Enterprise (250+)',
        description: 'Complex multi-branch production with international logistics.',
        icon: LucideIcons.building2,
        lastActivated: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DemoProfileModel(
        id: '4',
        name: 'Retail Company',
        industry: 'Retail & E-Commerce',
        size: 'Medium (50-250)',
        description: 'High-volume transactions, multi-warehouse inventory, and direct-to-consumer sales.',
        icon: LucideIcons.store,
        lastActivated: DateTime.now().subtract(const Duration(days: 3)),
      ),
      DemoProfileModel(
        id: '5',
        name: 'Steel Manufacturer',
        industry: 'Steel & Metallurgy',
        size: 'Enterprise (250+)',
        description: 'Continuous process manufacturing with strict quality and compliance workflows.',
        icon: LucideIcons.anvil,
        lastActivated: DateTime.now().subtract(const Duration(days: 4)),
      ),
      DemoProfileModel(
        id: '6',
        name: 'Garment Factory',
        industry: 'Textiles & Apparel',
        size: 'Medium (50-250)',
        description: 'Fast-paced production with seasonal variations and bulk raw material handling.',
        icon: LucideIcons.scissors,
        lastActivated: DateTime.now().subtract(const Duration(days: 5)),
      ),
      DemoProfileModel(
        id: '7',
        name: 'Construction Company',
        industry: 'Construction & Real Estate',
        size: 'Enterprise (250+)',
        description: 'Project-based accounting, heavy machinery tracking, and site management.',
        icon: LucideIcons.hardHat,
        lastActivated: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
  }

  void activateProfile(String id) {
    state = state.map((profile) {
      if (profile.id == id) {
        return profile.copyWith(isActive: true, lastActivated: DateTime.now());
      } else if (profile.isActive) {
        return profile.copyWith(isActive: false);
      }
      return profile;
    }).toList();
  }

  void duplicateProfile(String id) {
    final profileToDuplicate = state.firstWhere((p) => p.id == id);
    final newProfile = profileToDuplicate.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${profileToDuplicate.name} (Copy)',
      isActive: false,
      lastActivated: DateTime.now(),
    );
    state = [...state, newProfile];
  }

  void resetProfile(String id) {
    // In a real app, this would reset the underlying mock DB for this profile.
    // For this UI demo, we'll just update the lastActivated timestamp as a placeholder.
    state = state.map((profile) {
      if (profile.id == id) {
        return profile.copyWith(lastActivated: DateTime.now());
      }
      return profile;
    }).toList();
  }

  DemoProfileModel? get activeProfile {
    try {
      return state.firstWhere((p) => p.isActive);
    } catch (e) {
      return null;
    }
  }
}
