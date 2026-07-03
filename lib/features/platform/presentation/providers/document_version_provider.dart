import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/document_version_model.dart';
import 'dart:math';

class DocumentVersionState {
  final String documentId;
  final List<DetailedDocumentVersion> versions;
  final String currentVersion;
  final int previousCount;
  final int draftCount;
  final int publishedCount;

  DocumentVersionState({
    required this.documentId,
    required this.versions,
    required this.currentVersion,
    required this.previousCount,
    required this.draftCount,
    required this.publishedCount,
  });
}

final documentVersionProvider = Provider.family<DocumentVersionState, String>((ref, id) {
  final r = Random(id.hashCode);
  final now = DateTime.now();

  final numVersions = r.nextInt(10) + 5;
  List<DetailedDocumentVersion> versions = [];

  final authors = ['Alice Smith', 'Bob Jones', 'Charlie Davis', 'Dana White'];

  for (int i = numVersions; i > 0; i--) {
    String status = 'Archived';
    String versionLabel = 'v$i.0';
    
    if (i == numVersions) {
      status = 'Current';
    } else if (i == numVersions - 1 && r.nextBool()) {
      status = 'Draft';
      versionLabel = 'v$i.1-draft';
    } else if (i == numVersions - 1) {
      status = 'Published';
    }

    versions.add(DetailedDocumentVersion(
      id: '${id}_$i',
      version: versionLabel,
      uploadedBy: authors[r.nextInt(authors.length)],
      date: now.subtract(Duration(days: (numVersions - i) * 5 + r.nextInt(5))),
      changes: i == 1 ? 'Initial document upload' : 'Updated content based on review comments (Sprint $i).',
      status: status,
      sizeMb: 2.0 + r.nextDouble() * 10,
    ));
  }

  return DocumentVersionState(
    documentId: id,
    versions: versions,
    currentVersion: versions.firstWhere((v) => v.status == 'Current', orElse: () => versions.first).version,
    previousCount: versions.length - 1,
    draftCount: versions.where((v) => v.status == 'Draft').length,
    publishedCount: versions.where((v) => v.status == 'Published' || v.status == 'Current').length,
  );
});
