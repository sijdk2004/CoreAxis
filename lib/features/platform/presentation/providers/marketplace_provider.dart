import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/marketplace_pack_model.dart';

class MarketplaceState {
  final List<MarketplacePackModel> packs;
  final String searchQuery;
  final String selectedIndustry;
  final bool isLoading;

  const MarketplaceState({
    required this.packs,
    this.searchQuery = '',
    this.selectedIndustry = 'All',
    this.isLoading = false,
  });

  MarketplaceState copyWith({
    List<MarketplacePackModel>? packs,
    String? searchQuery,
    String? selectedIndustry,
    bool? isLoading,
  }) {
    return MarketplaceState(
      packs: packs ?? this.packs,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIndustry: selectedIndustry ?? this.selectedIndustry,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<MarketplacePackModel> get filteredPacks {
    return packs.where((pack) {
      final matchesSearch = pack.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          pack.description.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesIndustry = selectedIndustry == 'All' || pack.industry == selectedIndustry;
      return matchesSearch && matchesIndustry;
    }).toList();
  }
}

class MarketplaceNotifier extends Notifier<MarketplaceState> {
  @override
  MarketplaceState build() {
    return const MarketplaceState(
      packs: [
        MarketplacePackModel(
          id: 'pack-furni',
          name: 'FurniFlow',
          description: 'Complete ERP solution tailored for furniture manufacturing and retail.',
          industry: 'Manufacturing',
          iconName: 'sofa',
          status: 'Installed',
          modules: ['Inventory', 'Production', 'Sales', 'Logistics'],
          version: '2.4.1',
          developer: 'CoreAxis',
        ),
        MarketplacePackModel(
          id: 'pack-steel',
          name: 'SteelFlow',
          description: 'Heavy industry ERP for steel manufacturing, metallurgy, and distribution.',
          industry: 'Manufacturing',
          iconName: 'anvil',
          status: 'Coming Soon',
          modules: ['Procurement', 'Quality Control', 'Fleet Management'],
          version: '1.0.0-beta',
          developer: 'CoreAxis',
        ),
        MarketplacePackModel(
          id: 'pack-garment',
          name: 'GarmentFlow',
          description: 'Textile and apparel manufacturing management system with multi-tier BOMs.',
          industry: 'Manufacturing',
          iconName: 'shirt',
          status: 'Coming Soon',
          modules: ['Design Management', 'Production', 'Supply Chain'],
          version: '1.0.0-beta',
          developer: 'CoreAxis',
        ),
        MarketplacePackModel(
          id: 'pack-kitchen',
          name: 'KitchenFlow',
          description: 'Specialized for modular kitchen manufacturing and installation tracking.',
          industry: 'Construction',
          iconName: 'chefHat',
          status: 'Coming Soon',
          modules: ['CAD Integration', 'Project Management', 'Installation'],
          version: '1.0.0-beta',
          developer: 'CoreAxis',
        ),
        MarketplacePackModel(
          id: 'pack-construct',
          name: 'ConstructionFlow',
          description: 'End-to-end project management for real estate and construction firms.',
          industry: 'Construction',
          iconName: 'hardHat',
          status: 'Coming Soon',
          modules: ['Estimating', 'Site Management', 'Subcontractor Hub'],
          version: '1.0.0-beta',
          developer: 'CoreAxis',
        ),
        MarketplacePackModel(
          id: 'pack-retail',
          name: 'RetailFlow',
          description: 'Omnichannel retail management with advanced POS and CRM capabilities.',
          industry: 'Retail',
          iconName: 'shoppingBag',
          status: 'Coming Soon',
          modules: ['POS', 'E-Commerce', 'Loyalty Program'],
          version: '1.0.0-beta',
          developer: 'CoreAxis',
        ),
        MarketplacePackModel(
          id: 'pack-food',
          name: 'FoodFlow',
          description: 'F&B industry pack with recipe management and perishable inventory.',
          industry: 'Healthcare',
          iconName: 'utensils',
          status: 'Coming Soon',
          modules: ['Recipe Costing', 'Batch Tracking', 'Compliance'],
          version: '1.0.0-beta',
          developer: 'CoreAxis',
        ),
        MarketplacePackModel(
          id: 'pack-pharma',
          name: 'PharmaFlow',
          description: 'Strict regulatory compliant ERP for pharmaceutical manufacturing.',
          industry: 'Healthcare',
          iconName: 'pill',
          status: 'Coming Soon',
          modules: ['Quality Assurance', 'Traceability', 'FDA Compliance'],
          version: '1.0.0-beta',
          developer: 'CoreAxis',
        ),
      ],
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setIndustryFilter(String industry) {
    state = state.copyWith(selectedIndustry: industry);
  }

  Future<void> installPack(String packId) async {
    state = state.copyWith(isLoading: true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    final updatedPacks = state.packs.map((pack) {
      if (pack.id == packId) {
        return pack.copyWith(status: 'Installed');
      }
      return pack;
    }).toList();

    state = state.copyWith(packs: updatedPacks, isLoading: false);
  }
}

final marketplaceProvider = NotifierProvider<MarketplaceNotifier, MarketplaceState>(() {
  return MarketplaceNotifier();
});
