import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_provider_model.dart';

class AiModelCenterState {
  final List<AiProviderModel> providers;

  const AiModelCenterState({
    this.providers = const [],
  });

  AiModelCenterState copyWith({
    List<AiProviderModel>? providers,
  }) {
    return AiModelCenterState(
      providers: providers ?? this.providers,
    );
  }
}

class AiModelCenterNotifier extends Notifier<AiModelCenterState> {
  @override
  AiModelCenterState build() {
    return AiModelCenterState(
      providers: _generateMockProviders(),
    );
  }

  void updateProvider(AiProviderModel updatedProvider) {
    final newProviders = state.providers.map((p) {
      if (p.id == updatedProvider.id) return updatedProvider;
      return p;
    }).toList();
    state = state.copyWith(providers: newProviders);
  }

  Future<bool> testConnection(String id) async {
    // Simulate network delay for connection test
    await Future.delayed(const Duration(seconds: 2));
    
    // Toggle status to Active if it was something else, just for mock purposes
    final provider = state.providers.firstWhere((p) => p.id == id);
    if (provider.status != 'Active') {
       updateProvider(provider.copyWith(status: 'Active', latencyMs: 120));
    }
    return true; 
  }

  void toggleStatus(String id) {
    final provider = state.providers.firstWhere((p) => p.id == id);
    final newStatus = provider.status == 'Active' ? 'Inactive' : 'Active';
    updateProvider(provider.copyWith(status: newStatus));
  }

  List<AiProviderModel> _generateMockProviders() {
    return const [
      AiProviderModel(
        id: 'p1',
        providerName: 'OpenAI',
        modelName: 'gpt-4-turbo',
        status: 'Active',
        latencyMs: 142,
        totalRequests: 45210,
        costUsd: 125.40,
        icon: 'cpu',
        apiEndpoint: 'https://api.openai.com/v1/chat/completions',
        temperature: 0.7,
        maxTokens: 4096,
      ),
      AiProviderModel(
        id: 'p2',
        providerName: 'Azure OpenAI',
        modelName: 'gpt-35-turbo',
        status: 'Active',
        latencyMs: 98,
        totalRequests: 89032,
        costUsd: 89.20,
        icon: 'cloud',
        apiEndpoint: 'https://azure.microsoft.com/openai/deployments/gpt35',
        temperature: 0.5,
        maxTokens: 2048,
      ),
      AiProviderModel(
        id: 'p3',
        providerName: 'Google Gemini',
        modelName: 'gemini-1.5-pro',
        status: 'Inactive',
        latencyMs: 0,
        totalRequests: 1200,
        costUsd: 5.10,
        icon: 'globe',
        apiEndpoint: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro',
        temperature: 0.8,
        maxTokens: 8192,
      ),
      AiProviderModel(
        id: 'p4',
        providerName: 'Anthropic',
        modelName: 'claude-3-opus',
        status: 'Active',
        latencyMs: 210,
        totalRequests: 15400,
        costUsd: 65.80,
        icon: 'box',
        apiEndpoint: 'https://api.anthropic.com/v1/messages',
        temperature: 0.6,
        maxTokens: 4096,
      ),
      AiProviderModel(
        id: 'p5',
        providerName: 'Local Model',
        modelName: 'llama-3-8b-instruct',
        status: 'Error',
        latencyMs: 0,
        totalRequests: 540,
        costUsd: 0.0,
        icon: 'server',
        apiEndpoint: 'http://localhost:11434/api/generate',
        temperature: 0.4,
        maxTokens: 2048,
      ),
    ];
  }
}

final aiModelCenterProvider = NotifierProvider<AiModelCenterNotifier, AiModelCenterState>(() {
  return AiModelCenterNotifier();
});
