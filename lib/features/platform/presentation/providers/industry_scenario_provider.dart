import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/industry_scenario_model.dart';

class IndustryScenarioState {
  final List<IndustryScenarioModel> availableScenarios;
  final IndustryScenarioModel? activeScenario;
  final IndustryScenarioModel? previewScenario;

  const IndustryScenarioState({
    required this.availableScenarios,
    this.activeScenario,
    this.previewScenario,
  });

  IndustryScenarioState copyWith({
    List<IndustryScenarioModel>? availableScenarios,
    IndustryScenarioModel? activeScenario,
    IndustryScenarioModel? previewScenario,
    bool clearPreview = false,
  }) {
    return IndustryScenarioState(
      availableScenarios: availableScenarios ?? this.availableScenarios,
      activeScenario: activeScenario ?? this.activeScenario,
      previewScenario: clearPreview ? null : (previewScenario ?? this.previewScenario),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IndustryScenarioState &&
      other.activeScenario == activeScenario &&
      other.previewScenario == previewScenario;
  }

  @override
  int get hashCode => Object.hash(activeScenario, previewScenario);
}

final industryScenarioProvider = NotifierProvider<IndustryScenarioNotifier, IndustryScenarioState>(() {
  return IndustryScenarioNotifier();
});

class IndustryScenarioNotifier extends Notifier<IndustryScenarioState> {
  @override
  IndustryScenarioState build() {
    return const IndustryScenarioState(
      availableScenarios: _mockScenarios,
      activeScenario: null, // null means default ERP configuration
    );
  }

  void activateScenario(IndustryScenarioModel scenario) {
    state = state.copyWith(activeScenario: scenario, clearPreview: true);
  }

  void resetScenario() {
    // We cannot easily pass null to copyWith if we want to nullify it, 
    // so we'll just reconstruct the state or handle it carefully.
    state = IndustryScenarioState(
      availableScenarios: state.availableScenarios,
      activeScenario: null,
      previewScenario: null,
    );
  }

  void previewScenario(IndustryScenarioModel scenario) {
    state = state.copyWith(previewScenario: scenario);
  }

  void stopPreview() {
    state = state.copyWith(clearPreview: true);
  }

  static const List<IndustryScenarioModel> _mockScenarios = [
    IndustryScenarioModel(
      id: 'furniture',
      name: 'Furniture',
      description: 'Optimized for wood sourcing, large-item warehousing, and B2B wholesale distribution.',
      icon: LucideIcons.sofa,
      primaryColor: Colors.brown,
      features: ['BOM for Upholstery', 'Warehouse Zone Mapping', 'Retail Showroom Sync'],
    ),
    IndustryScenarioModel(
      id: 'steel',
      name: 'Steel',
      description: 'Heavy manufacturing focus with real-time furnace temperature tracking and batch yield analytics.',
      icon: LucideIcons.anvil,
      primaryColor: Colors.blueGrey,
      features: ['Furnace Integration', 'Batch Yield Metrics', 'Weight-based Pricing'],
    ),
    IndustryScenarioModel(
      id: 'garments',
      name: 'Garments',
      description: 'Apparel production management featuring color-size matrix routing and seasonal catalog planning.',
      icon: LucideIcons.shirt,
      primaryColor: Colors.pink,
      features: ['Color-Size Matrix', 'Season Planning', 'Fabric Consumption AI'],
    ),
    IndustryScenarioModel(
      id: 'construction',
      name: 'Construction',
      description: 'Project-based ERP for managing subcontractors, site materials, and heavy equipment rentals.',
      icon: LucideIcons.hardHat,
      primaryColor: Colors.amber,
      features: ['Site Material Tracking', 'Subcontractor Portals', 'Equipment Rentals'],
    ),
    IndustryScenarioModel(
      id: 'retail',
      name: 'Retail',
      description: 'Omnichannel inventory management with high-volume POS sync and loyalty program integrations.',
      icon: LucideIcons.shoppingBag,
      primaryColor: Colors.deepOrange,
      features: ['Omnichannel Sync', 'POS Integration', 'Loyalty Tracking'],
    ),
    IndustryScenarioModel(
      id: 'healthcare',
      name: 'Healthcare',
      description: 'HIPAA-compliant data handling for medical supplies, pharmaceuticals, and clinic procurement.',
      icon: LucideIcons.stethoscope,
      primaryColor: Colors.teal,
      features: ['HIPAA Compliance', 'Pharma Traceability', 'Clinic Procurement'],
    ),
    IndustryScenarioModel(
      id: 'education',
      name: 'Education',
      description: 'Campus asset management, facility scheduling, and academic supply procurement.',
      icon: LucideIcons.graduationCap,
      primaryColor: Colors.indigo,
      features: ['Campus Assets', 'Facility Scheduling', 'Academic Procurement'],
    ),
    IndustryScenarioModel(
      id: 'food',
      name: 'Food & Bev',
      description: 'Strict batch traceability, expiration tracking, and cold-chain logistics management.',
      icon: LucideIcons.utensilsCrossed,
      primaryColor: Colors.red,
      features: ['Cold-chain Logistics', 'Expiration Tracking', 'Batch Traceability'],
    ),
  ];
}
