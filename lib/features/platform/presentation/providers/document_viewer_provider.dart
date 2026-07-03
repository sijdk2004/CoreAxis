import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/document_viewer_model.dart';
import 'dart:math';

// Using a family provider to fetch details for a specific document ID.
// In a real app, this would be an AsyncNotifier, but we can use a standard Notifier or just a Provider for synchronous mock data.

final documentViewerProvider = Provider.family<DocumentViewerContext, String>((ref, id) {
  final r = Random(id.hashCode); // Deterministic based on ID
  
  // Decide type deterministically or parse from ID if we had an extension
  final types = ['pdf', 'word', 'excel', 'image', 'cad'];
  final type = types[r.nextInt(types.length)];
  
  final extMap = {
    'pdf': '.pdf',
    'word': '.docx',
    'excel': '.xlsx',
    'image': '.png',
    'cad': '.dwg'
  };
  
  final names = ['Q4_Financial_Report', 'Employee_Handbook_2026', 'Project_Alpha_Architecture', 'Office_Floorplan', 'Marketing_Assets'];
  final baseName = names[r.nextInt(names.length)];
  
  final now = DateTime.now();

  return DocumentViewerContext(
    id: id,
    name: '$baseName${extMap[type]}',
    type: type,
    sizeMb: r.nextDouble() * 50 + 0.5,
    owner: 'Alice Smith',
    category: 'General',
    tags: ['important', 'review', type],
    status: 'Approved',
    createdAt: now.subtract(Duration(days: r.nextInt(365))),
    modifiedAt: now.subtract(Duration(days: r.nextInt(30))),
    version: 'v${r.nextInt(5) + 1}.0',
    description: 'This is a mock description for the requested document. It contains vital enterprise information and requires review by the compliance team.',
    versions: [
      DocumentVersion(versionNumber: 'v2.0', author: 'Alice Smith', date: now.subtract(const Duration(days: 2)), notes: 'Updated section 4.'),
      DocumentVersion(versionNumber: 'v1.1', author: 'Bob Jones', date: now.subtract(const Duration(days: 15)), notes: 'Minor typo fixes.'),
      DocumentVersion(versionNumber: 'v1.0', author: 'Alice Smith', date: now.subtract(const Duration(days: 45)), notes: 'Initial upload.'),
    ],
    comments: [
      DocumentComment(author: 'Bob Jones', text: 'Looks good to me. Approved for release.', date: now.subtract(const Duration(hours: 2))),
      DocumentComment(author: 'Charlie Davis', text: 'Can we double check the figures on page 3?', date: now.subtract(const Duration(days: 1))),
    ],
    auditLogs: [
      DocumentAuditLog(action: 'Viewed', user: 'Charlie Davis', timestamp: now.subtract(const Duration(minutes: 15)), ipAddress: '192.168.1.45'),
      DocumentAuditLog(action: 'Downloaded', user: 'Bob Jones', timestamp: now.subtract(const Duration(hours: 2)), ipAddress: '10.0.0.5'),
      DocumentAuditLog(action: 'Updated Version', user: 'Alice Smith', timestamp: now.subtract(const Duration(days: 2)), ipAddress: '192.168.1.12'),
    ],
    sharedWith: ['Bob Jones', 'Charlie Davis', 'Finance Team'],
  );
});
