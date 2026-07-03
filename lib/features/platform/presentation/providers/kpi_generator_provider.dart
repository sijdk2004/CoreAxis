import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kpi_data_model.dart';

enum BusinessSize { small, medium, enterprise }

class KpiGeneratorState {
  final BusinessSize businessSize;
  final String industry;
  final double revenueGrowthRate;
  final double usersGrowthRate;
  final double ordersGrowthRate;
  final double productionGrowthRate;
  final bool isGenerating;
  final KpiDataModel data;

  KpiGeneratorState({
    this.businessSize = BusinessSize.medium,
    this.industry = 'Furniture',
    this.revenueGrowthRate = 0.05,
    this.usersGrowthRate = 0.08,
    this.ordersGrowthRate = 0.03,
    this.productionGrowthRate = 0.04,
    this.isGenerating = false,
    required this.data,
  });

  KpiGeneratorState copyWith({
    BusinessSize? businessSize,
    String? industry,
    double? revenueGrowthRate,
    double? usersGrowthRate,
    double? ordersGrowthRate,
    double? productionGrowthRate,
    bool? isGenerating,
    KpiDataModel? data,
  }) {
    return KpiGeneratorState(
      businessSize: businessSize ?? this.businessSize,
      industry: industry ?? this.industry,
      revenueGrowthRate: revenueGrowthRate ?? this.revenueGrowthRate,
      usersGrowthRate: usersGrowthRate ?? this.usersGrowthRate,
      ordersGrowthRate: ordersGrowthRate ?? this.ordersGrowthRate,
      productionGrowthRate: productionGrowthRate ?? this.productionGrowthRate,
      isGenerating: isGenerating ?? this.isGenerating,
      data: data ?? this.data,
    );
  }
}

class KpiGeneratorNotifier extends Notifier<KpiGeneratorState> {
  @override
  KpiGeneratorState build() {
    return KpiGeneratorState(data: KpiDataModel.empty());
  }

  void updateBusinessSize(BusinessSize size) {
    state = state.copyWith(businessSize: size);
  }

  void updateIndustry(String ind) {
    state = state.copyWith(industry: ind);
  }

  void updateGrowthRate({
    double? revenue,
    double? users,
    double? orders,
    double? production,
  }) {
    state = state.copyWith(
      revenueGrowthRate: revenue ?? state.revenueGrowthRate,
      usersGrowthRate: users ?? state.usersGrowthRate,
      ordersGrowthRate: orders ?? state.ordersGrowthRate,
      productionGrowthRate: production ?? state.productionGrowthRate,
    );
  }

  Future<void> generate() async {
    state = state.copyWith(isGenerating: true);

    // Simulate network/processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    final random = Random();
    
    double baseRev = 10000;
    double baseUsers = 500;
    double baseOrders = 200;
    double baseProd = 1000;

    switch (state.businessSize) {
      case BusinessSize.small:
        baseRev = 50000;
        baseUsers = 1000;
        baseOrders = 500;
        baseProd = 2000;
        break;
      case BusinessSize.medium:
        baseRev = 500000;
        baseUsers = 15000;
        baseOrders = 4000;
        baseProd = 15000;
        break;
      case BusinessSize.enterprise:
        baseRev = 5000000;
        baseUsers = 250000;
        baseOrders = 80000;
        baseProd = 200000;
        break;
    }

    List<FlSpot> genData(double base, double growth) {
      final List<FlSpot> points = [];
      double current = base * (0.8 + random.nextDouble() * 0.4);
      for (int i = 0; i < 12; i++) {
        points.add(FlSpot(i.toDouble(), current));
        // Add random walk with general upward trend based on growth
        current = current * (1.0 + (growth * (random.nextDouble() * 2 - 0.2)));
      }
      return points;
    }

    final revData = genData(baseRev, state.revenueGrowthRate);
    final usrData = genData(baseUsers, state.usersGrowthRate);
    final ordData = genData(baseOrders, state.ordersGrowthRate);
    final prdData = genData(baseProd, state.productionGrowthRate);

    final revGrowthActual = ((revData.last.y - revData.first.y) / revData.first.y) * 100;
    final usrGrowthActual = ((usrData.last.y - usrData.first.y) / usrData.first.y) * 100;
    final ordGrowthActual = ((ordData.last.y - ordData.first.y) / ordData.first.y) * 100;
    final prdGrowthActual = ((prdData.last.y - prdData.first.y) / prdData.first.y) * 100;

    final newData = KpiDataModel(
      revenueData: revData,
      usersData: usrData,
      ordersData: ordData,
      productionData: prdData,
      totalRevenue: revData.last.y,
      totalUsers: usrData.last.y,
      totalOrders: ordData.last.y,
      totalProduction: prdData.last.y,
      revenueGrowth: revGrowthActual,
      usersGrowth: usrGrowthActual,
      ordersGrowth: ordGrowthActual,
      productionGrowth: prdGrowthActual,
    );

    state = state.copyWith(isGenerating: false, data: newData);
  }
}

final kpiGeneratorProvider = NotifierProvider<KpiGeneratorNotifier, KpiGeneratorState>(KpiGeneratorNotifier.new);
