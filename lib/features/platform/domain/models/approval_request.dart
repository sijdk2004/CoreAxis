class ApprovalRequest {
  final String id;
  final String requestType;
  final String workflow;
  final String requestedBy;
  final String currentStep;
  final String assignedTo;
  final String priority;
  final DateTime submittedDate;
  final DateTime dueDate;
  final String status;

  // Detail Drawer data
  final String summary;
  final List<TimelineEvent> timeline;
  final List<Comment> comments;
  final List<Attachment> attachments;
  final List<HistoryEvent> history;

  ApprovalRequest({
    required this.id,
    required this.requestType,
    required this.workflow,
    required this.requestedBy,
    required this.currentStep,
    required this.assignedTo,
    required this.priority,
    required this.submittedDate,
    required this.dueDate,
    required this.status,
    required this.summary,
    required this.timeline,
    required this.comments,
    required this.attachments,
    required this.history,
  });

  ApprovalRequest copyWith({
    String? id,
    String? requestType,
    String? workflow,
    String? requestedBy,
    String? currentStep,
    String? assignedTo,
    String? priority,
    DateTime? submittedDate,
    DateTime? dueDate,
    String? status,
    String? summary,
    List<TimelineEvent>? timeline,
    List<Comment>? comments,
    List<Attachment>? attachments,
    List<HistoryEvent>? history,
  }) {
    return ApprovalRequest(
      id: id ?? this.id,
      requestType: requestType ?? this.requestType,
      workflow: workflow ?? this.workflow,
      requestedBy: requestedBy ?? this.requestedBy,
      currentStep: currentStep ?? this.currentStep,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      submittedDate: submittedDate ?? this.submittedDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      timeline: timeline ?? this.timeline,
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
      history: history ?? this.history,
    );
  }
}

class TimelineEvent {
  final String title;
  final String subtitle;
  final DateTime time;
  final bool isCompleted;
  final bool isCurrent;

  TimelineEvent({
    required this.title,
    required this.subtitle,
    required this.time,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class Comment {
  final String user;
  final String text;
  final DateTime time;

  Comment({
    required this.user,
    required this.text,
    required this.time,
  });
}

class Attachment {
  final String fileName;
  final String fileSize;
  final String fileType;

  Attachment({
    required this.fileName,
    required this.fileSize,
    required this.fileType,
  });
}

class HistoryEvent {
  final String action;
  final String user;
  final DateTime time;

  HistoryEvent({
    required this.action,
    required this.user,
    required this.time,
  });
}
