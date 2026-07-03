class EntityTimelineModel {
  final String entityId;
  final String entityName;
  final String entityType;
  final String status;
  final Map<String, String> summary;
  final List<TimelineEvent> events;

  const EntityTimelineModel({
    required this.entityId,
    required this.entityName,
    required this.entityType,
    required this.status,
    required this.summary,
    required this.events,
  });
}

class TimelineEvent {
  final String id;
  final String timestamp;
  final String action; // Created, Updated, Approved, Rejected, Shared, Downloaded, Deleted, Restored
  final String user;
  final String module;
  final String details;
  final Map<String, dynamic> metadata;
  final bool isExpanded;

  const TimelineEvent({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.user,
    required this.module,
    required this.details,
    this.metadata = const {},
    this.isExpanded = false,
  });
  
  TimelineEvent copyWith({
    String? id,
    String? timestamp,
    String? action,
    String? user,
    String? module,
    String? details,
    Map<String, dynamic>? metadata,
    bool? isExpanded,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      action: action ?? this.action,
      user: user ?? this.user,
      module: module ?? this.module,
      details: details ?? this.details,
      metadata: metadata ?? this.metadata,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

EntityTimelineModel generateMockEntityTimeline(String id) {
  // Use the ID to derive some mock data context
  final isDocument = id.startsWith('DOC');
  final isUser = id.startsWith('USR');
  
  String entityName = 'Financial_Report_Q3.pdf';
  String entityType = 'Document';
  String module = 'Documents';
  
  if (isUser) {
    entityName = 'john.doe';
    entityType = 'User Account';
    module = 'RBAC';
  } else if (id.startsWith('ORG')) {
    entityName = 'Acme Corp';
    entityType = 'Organization';
    module = 'Organizations';
  } else if (id.startsWith('TEN')) {
    entityName = 'US-East Production';
    entityType = 'Tenant';
    module = 'Tenants';
  }

  return EntityTimelineModel(
    entityId: id,
    entityName: entityName,
    entityType: entityType,
    status: 'Active',
    summary: {
      'Created': 'Oct 15, 2023',
      'Last Modified': 'Oct 27, 2023',
      'Total Events': '14',
      'Owner': 'admin.sys',
    },
    events: [
      TimelineEvent(
        id: 'EVT-101',
        timestamp: '2023-10-27 14:32:45',
        action: 'Shared',
        user: 'john.doe',
        module: module,
        details: 'Shared with external partner (jane.smith@partner.com).',
        metadata: {'Permission': 'View Only', 'Expiry': '7 Days'},
      ),
      TimelineEvent(
        id: 'EVT-100',
        timestamp: '2023-10-26 11:20:00',
        action: 'Updated',
        user: 'sarah.c',
        module: module,
        details: 'Modified properties and tags.',
        metadata: {'Tags Added': 'Finance, Q3, Draft'},
      ),
      TimelineEvent(
        id: 'EVT-099',
        timestamp: '2023-10-25 09:15:30',
        action: 'Approved',
        user: 'manager.bob',
        module: 'Approvals',
        details: 'Approved the pending workflow transition.',
        metadata: {'Workflow': 'WF-1092', 'Comments': 'Looks good.'},
      ),
      TimelineEvent(
        id: 'EVT-098',
        timestamp: '2023-10-22 16:45:10',
        action: 'Downloaded',
        user: 'mike.t',
        module: module,
        details: 'Downloaded copy to local device.',
        metadata: {'IP Address': '192.168.1.104', 'Device': 'MacBook Pro'},
      ),
      TimelineEvent(
        id: 'EVT-097',
        timestamp: '2023-10-20 10:10:00',
        action: 'Rejected',
        user: 'manager.bob',
        module: 'Approvals',
        details: 'Initial review rejected due to missing data.',
        metadata: {'Reason': 'Missing appendix sections.'},
      ),
      TimelineEvent(
        id: 'EVT-096',
        timestamp: '2023-10-18 14:05:00',
        action: 'Updated',
        user: 'sarah.c',
        module: module,
        details: 'New version uploaded (v1.1).',
        metadata: {'Size': '2.4 MB', 'Checksum': 'a8f52e...'},
      ),
      TimelineEvent(
        id: 'EVT-095',
        timestamp: '2023-10-15 09:00:00',
        action: 'Created',
        user: 'admin.sys',
        module: module,
        details: 'Entity originally created in system.',
        metadata: {'Initial State': 'Draft'},
      ),
    ],
  );
}
