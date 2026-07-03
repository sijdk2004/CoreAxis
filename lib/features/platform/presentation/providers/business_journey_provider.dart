import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/business_journey_step_model.dart';

final businessJourneySteps = <BusinessJourneyStepModel>[
  const BusinessJourneyStepModel(
    id: 'step_1',
    title: 'Customer Inquiry',
    description: 'A prospective customer reaches out or submits a request for quotation (RFQ) through the portal.',
    businessValue: 'Capturing leads early ensures accurate requirement gathering and prevents lost opportunities.',
    platformModule: 'CRM Core',
    industryModule: 'Universal',
    route: '/inquiries',
    icon: LucideIcons.messageSquare,
  ),
  const BusinessJourneyStepModel(
    id: 'step_2',
    title: 'Quotation',
    description: 'Sales generates a dynamic quotation based on real-time inventory and pricing tiers.',
    businessValue: 'Rapid, accurate quoting increases win rates and protects margins.',
    platformModule: 'Sales & Quoting',
    industryModule: 'Universal',
    route: '/quotations',
    icon: LucideIcons.fileText,
  ),
  const BusinessJourneyStepModel(
    id: 'step_3',
    title: 'Sales Order',
    description: 'The quote is approved and converted into a binding Sales Order, locking in demand.',
    businessValue: 'Seamless conversion eliminates data entry errors and triggers demand planning automatically.',
    platformModule: 'Order Management',
    industryModule: 'Universal',
    route: '/sales-orders',
    icon: LucideIcons.shoppingCart,
  ),
  const BusinessJourneyStepModel(
    id: 'step_4',
    title: 'Production',
    description: 'Manufacturing executes the production order against the BOM (Bill of Materials) and routing instructions.',
    businessValue: 'Live tracking of work-in-progress (WIP) ensures delivery deadlines are met without bottlenecks.',
    platformModule: 'Manufacturing',
    industryModule: 'FurniFlow / GarmentFlow',
    route: '/production',
    icon: LucideIcons.factory,
  ),
  const BusinessJourneyStepModel(
    id: 'step_5',
    title: 'Inventory',
    description: 'Finished goods are received into inventory, triggering quality control and put-away rules.',
    businessValue: 'Real-time stock visibility prevents stockouts and optimizes warehouse space utilization.',
    platformModule: 'Warehouse Management',
    industryModule: 'Universal',
    route: '/inventory',
    icon: LucideIcons.packageSearch,
  ),
  const BusinessJourneyStepModel(
    id: 'step_6',
    title: 'Delivery',
    description: 'Logistics plans the route, packs the goods, and dispatches the delivery to the customer.',
    businessValue: 'Efficient routing and proof-of-delivery tracking boosts customer satisfaction.',
    platformModule: 'Logistics',
    industryModule: 'Universal',
    route: '/delivery',
    icon: LucideIcons.truck,
  ),
  const BusinessJourneyStepModel(
    id: 'step_7',
    title: 'Invoice',
    description: 'Finance automatically generates and issues an invoice matched against the delivery note.',
    businessValue: 'Automated 3-way matching speeds up the billing cycle and reduces manual overhead.',
    platformModule: 'Finance Core',
    industryModule: 'Universal',
    route: '/invoices',
    icon: LucideIcons.receipt,
  ),
  const BusinessJourneyStepModel(
    id: 'step_8',
    title: 'Payment',
    description: 'Customer payment is received, reconciled, and the ledger is updated in real-time.',
    businessValue: 'Faster cash conversion cycle (CCC) improves liquidity and financial health.',
    platformModule: 'Treasury & Ledger',
    industryModule: 'Universal',
    route: '/financial-overview',
    icon: LucideIcons.creditCard,
  ),
  const BusinessJourneyStepModel(
    id: 'step_9',
    title: 'Reports',
    description: 'Management reviews the financial and operational performance of the lifecycle.',
    businessValue: 'Data-driven insights highlight process inefficiencies and revenue drivers.',
    platformModule: 'Analytics',
    industryModule: 'Universal',
    route: '/platform/reports/catalog',
    icon: LucideIcons.barChart2,
  ),
  const BusinessJourneyStepModel(
    id: 'step_10',
    title: 'AI Summary',
    description: 'CoreAxis AI synthesizes the transaction data to predict future demand and recommend process improvements.',
    businessValue: 'Proactive AI recommendations turn historical data into forward-looking strategic advantages.',
    platformModule: 'CoreAxis AI',
    industryModule: 'Platform AI',
    route: '/platform/ai/reports',
    icon: LucideIcons.sparkles,
  ),
];

class BusinessJourneyState {
  final int activeStepIndex;

  const BusinessJourneyState({
    required this.activeStepIndex,
  });
}

class BusinessJourneyNotifier extends Notifier<BusinessJourneyState> {
  @override
  BusinessJourneyState build() {
    return const BusinessJourneyState(activeStepIndex: 0);
  }

  void setActiveStep(int index) {
    if (index >= 0 && index < businessJourneySteps.length) {
      state = BusinessJourneyState(activeStepIndex: index);
    }
  }

  void nextStep() {
    if (state.activeStepIndex < businessJourneySteps.length - 1) {
      setActiveStep(state.activeStepIndex + 1);
    }
  }

  void previousStep() {
    if (state.activeStepIndex > 0) {
      setActiveStep(state.activeStepIndex - 1);
    }
  }
}

final businessJourneyProvider = NotifierProvider<BusinessJourneyNotifier, BusinessJourneyState>(
  BusinessJourneyNotifier.new,
);
