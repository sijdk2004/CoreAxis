import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/system_status_model.dart';

class SystemStatusState {
  final List<SystemServiceModel> services;
  final SystemMetricsModel metrics;
  final List<ChartDataPoint> performanceData;
  final List<ChartDataPoint> volumeData;
  final bool isLoading;

  const SystemStatusState({
    required this.services,
    required this.metrics,
    required this.performanceData,
    required this.volumeData,
    this.isLoading = false,
  });

  SystemStatusState copyWith({
    List<SystemServiceModel>? services,
    SystemMetricsModel? metrics,
    List<ChartDataPoint>? performanceData,
    List<ChartDataPoint>? volumeData,
    bool? isLoading,
  }) {
    return SystemStatusState(
      services: services ?? this.services,
      metrics: metrics ?? this.metrics,
      performanceData: performanceData ?? this.performanceData,
      volumeData: volumeData ?? this.volumeData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SystemStatusNotifier extends Notifier<SystemStatusState> {
  Timer? _timer;
  final _random = Random();

  @override
  SystemStatusState build() {
    final now = DateTime.now();
    final initialPerformance = List.generate(20, (index) => 
      ChartDataPoint(now.subtract(Duration(minutes: 20 - index)), 50.0 + _random.nextDouble() * 20));
    final initialVolume = List.generate(20, (index) => 
      ChartDataPoint(now.subtract(Duration(minutes: 20 - index)), 1000.0 + _random.nextDouble() * 500));

    final initialState = SystemStatusState(
      services: const [
        SystemServiceModel(id: 's-1', name: 'Application Health', status: ServiceStatus.healthy, description: 'Core ERP Web Services', icon: LucideIcons.appWindow, uptime: '99.99%', latency: '45ms'),
        SystemServiceModel(id: 's-2', name: 'Notification Service', status: ServiceStatus.healthy, description: 'Email, SMS, Push Notifications', icon: LucideIcons.bell, uptime: '99.95%', latency: '120ms'),
        SystemServiceModel(id: 's-3', name: 'Workflow Engine', status: ServiceStatus.degraded, description: 'Business Process Automation', icon: LucideIcons.workflow, uptime: '98.50%', latency: '450ms'),
        SystemServiceModel(id: 's-4', name: 'AI Service', status: ServiceStatus.healthy, description: 'ML Models & AI Copilot', icon: LucideIcons.brainCircuit, uptime: '99.90%', latency: '85ms'),
        SystemServiceModel(id: 's-5', name: 'Document Service', status: ServiceStatus.healthy, description: 'File Storage & Processing', icon: LucideIcons.fileText, uptime: '99.99%', latency: '60ms'),
        SystemServiceModel(id: 's-6', name: 'Storage', status: ServiceStatus.maintenance, description: 'Object Storage & Blobs', icon: LucideIcons.database, uptime: '99.00%', latency: '--'),
        SystemServiceModel(id: 's-7', name: 'Database (Mock)', status: ServiceStatus.healthy, description: 'Primary Relational Database', icon: LucideIcons.server, uptime: '99.99%', latency: '15ms'),
        SystemServiceModel(id: 's-8', name: 'Queue', status: ServiceStatus.healthy, description: 'Message Broker & Workers', icon: LucideIcons.listOrdered, uptime: '99.98%', latency: '25ms'),
      ],
      metrics: const SystemMetricsModel(
        cpuUsage: 45.2,
        memoryUsage: 68.5,
        activeConnections: 12450,
        requestRate: 850,
        errorRate: 0.12,
      ),
      performanceData: initialPerformance,
      volumeData: initialVolume,
    );

    // Simulate real-time updates
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _updateMetrics();
    });

    ref.onDispose(() {
      _timer?.cancel();
    });

    return initialState;
  }

  void _updateMetrics() {
    final now = DateTime.now();
    
    // Generate new data point for performance (latency)
    var perfData = List<ChartDataPoint>.from(state.performanceData);
    if (perfData.length >= 20) perfData.removeAt(0);
    perfData.add(ChartDataPoint(now, 50.0 + _random.nextDouble() * 20));

    // Generate new data point for volume
    var volData = List<ChartDataPoint>.from(state.volumeData);
    if (volData.length >= 20) volData.removeAt(0);
    volData.add(ChartDataPoint(now, 1000.0 + _random.nextDouble() * 500));

    // Update global metrics slightly
    final newMetrics = SystemMetricsModel(
      cpuUsage: (state.metrics.cpuUsage + (_random.nextDouble() * 4 - 2)).clamp(0.0, 100.0),
      memoryUsage: (state.metrics.memoryUsage + (_random.nextDouble() * 2 - 1)).clamp(0.0, 100.0),
      activeConnections: (state.metrics.activeConnections + (_random.nextInt(200) - 100)).clamp(0.0, 50000.0),
      requestRate: (state.metrics.requestRate + (_random.nextInt(50) - 25)).clamp(0.0, 2000.0),
      errorRate: (state.metrics.errorRate + (_random.nextDouble() * 0.04 - 0.02)).clamp(0.0, 5.0),
    );

    state = state.copyWith(
      metrics: newMetrics,
      performanceData: perfData,
      volumeData: volData,
    );
  }
  
  void simulateServiceRestart(String id) async {
    final index = state.services.indexWhere((s) => s.id == id);
    if (index != -1) {
      final services = List<SystemServiceModel>.from(state.services);
      services[index] = SystemServiceModel(
        id: services[index].id,
        name: services[index].name,
        status: ServiceStatus.maintenance,
        description: services[index].description,
        icon: services[index].icon,
        uptime: services[index].uptime,
        latency: '--',
      );
      state = state.copyWith(services: services);
      
      await Future.delayed(const Duration(seconds: 2));
      
      final restoredServices = List<SystemServiceModel>.from(state.services);
      restoredServices[index] = SystemServiceModel(
        id: services[index].id,
        name: services[index].name,
        status: ServiceStatus.healthy,
        description: services[index].description,
        icon: services[index].icon,
        uptime: services[index].uptime,
        latency: '30ms', // New latency
      );
      state = state.copyWith(services: restoredServices);
    }
  }
}

final systemStatusProvider = NotifierProvider<SystemStatusNotifier, SystemStatusState>(() {
  return SystemStatusNotifier();
});
