import 'package:fl_chart/fl_chart.dart';

class KpiDataModel {
  final List<FlSpot> revenueData;
  final List<FlSpot> usersData;
  final List<FlSpot> ordersData;
  final List<FlSpot> productionData;

  final double totalRevenue;
  final double totalUsers;
  final double totalOrders;
  final double totalProduction;

  final double revenueGrowth;
  final double usersGrowth;
  final double ordersGrowth;
  final double productionGrowth;

  KpiDataModel({
    required this.revenueData,
    required this.usersData,
    required this.ordersData,
    required this.productionData,
    required this.totalRevenue,
    required this.totalUsers,
    required this.totalOrders,
    required this.totalProduction,
    required this.revenueGrowth,
    required this.usersGrowth,
    required this.ordersGrowth,
    required this.productionGrowth,
  });

  factory KpiDataModel.empty() {
    return KpiDataModel(
      revenueData: const [],
      usersData: const [],
      ordersData: const [],
      productionData: const [],
      totalRevenue: 0,
      totalUsers: 0,
      totalOrders: 0,
      totalProduction: 0,
      revenueGrowth: 0,
      usersGrowth: 0,
      ordersGrowth: 0,
      productionGrowth: 0,
    );
  }
}
