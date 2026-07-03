import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/roadmap_model.dart';

final roadmapProvider = Provider<List<RoadmapItemModel>>((ref) {
  return [
    // Completed
    const RoadmapItemModel(
      id: 'r1',
      title: 'CoreAxis Foundation V1',
      description: 'Initial release of the core platform architecture including identity management and unified navigation shell.',
      phase: RoadmapPhase.completed,
      track: RoadmapTrack.platform,
      date: 'Q1 2026',
      icon: LucideIcons.layoutTemplate,
    ),
    const RoadmapItemModel(
      id: 'r2',
      title: 'FurniFlow Integration',
      description: 'Successfully migrated the legacy Furniture ERP into the new CoreAxis unified platform.',
      phase: RoadmapPhase.completed,
      track: RoadmapTrack.furniture,
      date: 'Q2 2026',
      icon: LucideIcons.armchair,
    ),
    const RoadmapItemModel(
      id: 'r3',
      title: 'Global Search',
      description: 'Unified search capabilities across all connected ERP modules with rich preview.',
      phase: RoadmapPhase.completed,
      track: RoadmapTrack.platform,
      date: 'Q2 2026',
      icon: LucideIcons.search,
    ),
    
    // Current
    const RoadmapItemModel(
      id: 'r4',
      title: 'SteelFlow Beta',
      description: 'Rolling out the heavy manufacturing and steel processing ERP module to select early adopters.',
      phase: RoadmapPhase.current,
      track: RoadmapTrack.steel,
      date: 'Q3 2026',
      icon: LucideIcons.factory,
    ),
    const RoadmapItemModel(
      id: 'r5',
      title: 'CoreAxis AI Assistant',
      description: 'Context-aware AI assistant integrated directly into workflows for intelligent suggestions.',
      phase: RoadmapPhase.current,
      track: RoadmapTrack.ai,
      date: 'Q3 2026',
      icon: LucideIcons.bot,
    ),
    const RoadmapItemModel(
      id: 'r6',
      title: 'Salesforce Integration',
      description: 'Native bi-directional sync with Salesforce CRM for unified customer data.',
      phase: RoadmapPhase.current,
      track: RoadmapTrack.integrations,
      icon: LucideIcons.cloud,
    ),

    // Next
    const RoadmapItemModel(
      id: 'r7',
      title: 'GarmentFlow Alpha',
      description: 'Initiating development of the textile and garment manufacturing ERP module.',
      phase: RoadmapPhase.next,
      track: RoadmapTrack.garment,
      date: 'Q4 2026',
      icon: LucideIcons.scissors,
    ),
    const RoadmapItemModel(
      id: 'r8',
      title: 'Mobile Companion App',
      description: 'Native iOS and Android application for on-the-go approvals and KPI monitoring.',
      phase: RoadmapPhase.next,
      track: RoadmapTrack.mobile,
      date: 'Q4 2026',
      icon: LucideIcons.smartphone,
    ),
    const RoadmapItemModel(
      id: 'r9',
      title: 'Predictive Inventory',
      description: 'AI-driven models to predict stockouts and automate reordering processes.',
      phase: RoadmapPhase.next,
      track: RoadmapTrack.ai,
      icon: LucideIcons.sparkles,
    ),

    // Future
    const RoadmapItemModel(
      id: 'r10',
      title: 'Marketplace Ecosystem',
      description: 'Open API and marketplace for third-party developers to build CoreAxis extensions.',
      phase: RoadmapPhase.future,
      track: RoadmapTrack.platform,
      date: '2027',
      icon: LucideIcons.shoppingBag,
    ),
    const RoadmapItemModel(
      id: 'r11',
      title: 'IoT Machine Integration',
      description: 'Direct sensor integration for real-time factory floor monitoring in Steel and Garment modules.',
      phase: RoadmapPhase.future,
      track: RoadmapTrack.integrations,
      icon: LucideIcons.radioReceiver,
    ),
  ];
});
