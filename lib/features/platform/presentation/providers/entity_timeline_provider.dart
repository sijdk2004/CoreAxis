import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/entity_timeline_model.dart';

final entityTimelineProvider = NotifierProvider<EntityTimelineNotifier, Map<String, AsyncValue<EntityTimelineModel>>>(() {
  return EntityTimelineNotifier();
});

class EntityTimelineNotifier extends Notifier<Map<String, AsyncValue<EntityTimelineModel>>> {
  @override
  Map<String, AsyncValue<EntityTimelineModel>> build() {
    return {};
  }

  Future<void> loadTimeline(String id) async {
    if (state.containsKey(id) && state[id] is AsyncData) return;
    
    // Using a new map instance to ensure state triggers
    final newState = Map<String, AsyncValue<EntityTimelineModel>>.from(state);
    newState[id] = const AsyncValue.loading();
    state = newState;

    await Future.delayed(const Duration(milliseconds: 600));
    final mockData = generateMockEntityTimeline(id);
    
    final finalState = Map<String, AsyncValue<EntityTimelineModel>>.from(state);
    finalState[id] = AsyncValue.data(mockData);
    state = finalState;
  }

  void toggleEventExpanded(String id, String eventId) {
    if (!state.containsKey(id)) return;
    final asyncVal = state[id]!;
    if (asyncVal.value == null) return;
    
    final currentModel = asyncVal.value!;
    final updatedEvents = currentModel.events.map((e) {
      if (e.id == eventId) {
        return e.copyWith(isExpanded: !e.isExpanded);
      }
      return e;
    }).toList();
    
    final updatedModel = EntityTimelineModel(
      entityId: currentModel.entityId,
      entityName: currentModel.entityName,
      entityType: currentModel.entityType,
      status: currentModel.status,
      summary: currentModel.summary,
      events: updatedEvents,
    );
    
    final newState = Map<String, AsyncValue<EntityTimelineModel>>.from(state);
    newState[id] = AsyncValue.data(updatedModel);
    state = newState;
  }
}
