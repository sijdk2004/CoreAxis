import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/document_upload_model.dart';
import 'dart:async';
import 'dart:math';

class DocumentUploadState {
  final List<UploadTaskItem> queue;

  DocumentUploadState({
    required this.queue,
  });

  DocumentUploadState copyWith({
    List<UploadTaskItem>? queue,
  }) {
    return DocumentUploadState(
      queue: queue ?? this.queue,
    );
  }

  List<UploadTaskItem> get pending => queue.where((i) => i.status == UploadTaskStatus.pending).toList();
  List<UploadTaskItem> get uploading => queue.where((i) => i.status == UploadTaskStatus.uploading).toList();
  List<UploadTaskItem> get completed => queue.where((i) => i.status == UploadTaskStatus.completed).toList();
  List<UploadTaskItem> get failed => queue.where((i) => i.status == UploadTaskStatus.failed).toList();
  List<UploadTaskItem> get cancelled => queue.where((i) => i.status == UploadTaskStatus.cancelled).toList();
}

class DocumentUploadNotifier extends Notifier<DocumentUploadState> {
  final Map<String, Timer> _activeTimers = {};

  @override
  DocumentUploadState build() {
    return DocumentUploadState(queue: []);
  }

  void startMockUpload(UploadTaskItem item, {bool forceFail = false}) {
    final newItem = item.copyWith(status: UploadTaskStatus.uploading, progress: 0.0);
    state = state.copyWith(queue: [newItem, ...state.queue]);

    _simulateUploadProgress(newItem.id, forceFail: forceFail);
  }

  void retryUpload(String id) {
    final updated = state.queue.map((item) {
      if (item.id == id) {
        return item.copyWith(status: UploadTaskStatus.uploading, progress: 0.0, clearError: true);
      }
      return item;
    }).toList();
    state = state.copyWith(queue: updated);
    _simulateUploadProgress(id, forceFail: false);
  }

  void cancelUpload(String id) {
    _activeTimers[id]?.cancel();
    _activeTimers.remove(id);

    final updated = state.queue.map((item) {
      if (item.id == id) {
        return item.copyWith(status: UploadTaskStatus.cancelled);
      }
      return item;
    }).toList();
    state = state.copyWith(queue: updated);
  }

  void clearCompleted() {
    final updated = state.queue.where((item) => item.status != UploadTaskStatus.completed).toList();
    state = state.copyWith(queue: updated);
  }

  void _simulateUploadProgress(String id, {bool forceFail = false}) {
    _activeTimers[id]?.cancel();

    final totalSteps = 20; // 2 seconds total roughly
    int currentStep = 0;

    _activeTimers[id] = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      currentStep++;
      final progress = currentStep / totalSteps;

      // Fail condition midway
      if (forceFail && currentStep == 10) {
        timer.cancel();
        _activeTimers.remove(id);
        _updateTaskStatus(id, UploadTaskStatus.failed, progress, 'Network timeout occurred.');
        return;
      }

      if (currentStep >= totalSteps) {
        timer.cancel();
        _activeTimers.remove(id);
        _updateTaskStatus(id, UploadTaskStatus.completed, 1.0, null);
      } else {
        _updateTaskStatus(id, UploadTaskStatus.uploading, progress, null);
      }
    });
  }

  void _updateTaskStatus(String id, UploadTaskStatus status, double progress, String? errorMessage) {
    final updated = state.queue.map((item) {
      if (item.id == id) {
        return item.copyWith(status: status, progress: progress, errorMessage: errorMessage);
      }
      return item;
    }).toList();
    state = state.copyWith(queue: updated);
  }
}

final documentUploadProvider = NotifierProvider<DocumentUploadNotifier, DocumentUploadState>(() {
  return DocumentUploadNotifier();
});
