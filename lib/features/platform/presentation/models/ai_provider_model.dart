import 'package:flutter/foundation.dart';

@immutable
class AiProviderModel {
  final String id;
  final String providerName;
  final String modelName;
  final String status; // 'Active', 'Inactive', 'Error', 'Testing'
  final int latencyMs;
  final int totalRequests;
  final double costUsd;
  final String icon;
  final String apiEndpoint;
  final double temperature;
  final int maxTokens;

  const AiProviderModel({
    required this.id,
    required this.providerName,
    required this.modelName,
    required this.status,
    required this.latencyMs,
    required this.totalRequests,
    required this.costUsd,
    required this.icon,
    required this.apiEndpoint,
    required this.temperature,
    required this.maxTokens,
  });

  AiProviderModel copyWith({
    String? id,
    String? providerName,
    String? modelName,
    String? status,
    int? latencyMs,
    int? totalRequests,
    double? costUsd,
    String? icon,
    String? apiEndpoint,
    double? temperature,
    int? maxTokens,
  }) {
    return AiProviderModel(
      id: id ?? this.id,
      providerName: providerName ?? this.providerName,
      modelName: modelName ?? this.modelName,
      status: status ?? this.status,
      latencyMs: latencyMs ?? this.latencyMs,
      totalRequests: totalRequests ?? this.totalRequests,
      costUsd: costUsd ?? this.costUsd,
      icon: icon ?? this.icon,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }
}
