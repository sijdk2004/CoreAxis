import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/document_analytics_model.dart';

final documentAnalyticsProvider = AsyncNotifierProvider<DocumentAnalyticsNotifier, DocumentAnalyticsModel>(() {
  return DocumentAnalyticsNotifier();
});

class DocumentAnalyticsNotifier extends AsyncNotifier<DocumentAnalyticsModel> {
  @override
  FutureOr<DocumentAnalyticsModel> build() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    return generateMockDocumentAnalytics();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 800));
      return generateMockDocumentAnalytics();
    });
  }
}
