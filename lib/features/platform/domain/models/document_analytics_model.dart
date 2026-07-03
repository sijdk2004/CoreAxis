import 'package:flutter/foundation.dart';

class DocumentAnalyticsModel {
  final Map<String, String> kpis;
  final List<ChartDataPoint> storageTrend;
  final List<ChartDataPoint> downloadTrend;
  final List<PieChartDataPoint> categoryUsage;
  final List<BarChartDataPoint> organizationComparison;
  final List<DocumentItem> mostViewedDocuments;
  final List<DocumentItem> largestFiles;
  final List<DocumentItem> mostShared;
  final List<DocumentItem> recentlyArchived;
  final List<String> aiRecommendations;

  const DocumentAnalyticsModel({
    required this.kpis,
    required this.storageTrend,
    required this.downloadTrend,
    required this.categoryUsage,
    required this.organizationComparison,
    required this.mostViewedDocuments,
    required this.largestFiles,
    required this.mostShared,
    required this.recentlyArchived,
    required this.aiRecommendations,
  });
}

class ChartDataPoint {
  final String label;
  final double value;
  const ChartDataPoint(this.label, this.value);
}

class PieChartDataPoint {
  final String category;
  final double percentage;
  const PieChartDataPoint(this.category, this.percentage);
}

class BarChartDataPoint {
  final String label;
  final double value1;
  final double value2;
  const BarChartDataPoint(this.label, this.value1, this.value2);
}

class DocumentItem {
  final String id;
  final String name;
  final String metric;
  const DocumentItem(this.id, this.name, this.metric);
}

// Mock Data Generator
DocumentAnalyticsModel generateMockDocumentAnalytics() {
  return DocumentAnalyticsModel(
    kpis: {
      'Documents': '14,250',
      'Storage': '2.4 TB',
      'Downloads': '8,421',
      'Shares': '3,104',
      'Versions': '28,100',
      'Archive Rate': '12.5%',
    },
    storageTrend: [
      const ChartDataPoint('Jan', 1.8),
      const ChartDataPoint('Feb', 1.9),
      const ChartDataPoint('Mar', 2.0),
      const ChartDataPoint('Apr', 2.1),
      const ChartDataPoint('May', 2.3),
      const ChartDataPoint('Jun', 2.4),
    ],
    downloadTrend: [
      const ChartDataPoint('Jan', 1200),
      const ChartDataPoint('Feb', 1500),
      const ChartDataPoint('Mar', 1100),
      const ChartDataPoint('Apr', 2100),
      const ChartDataPoint('May', 1900),
      const ChartDataPoint('Jun', 2500),
    ],
    categoryUsage: [
      const PieChartDataPoint('Invoices', 35),
      const PieChartDataPoint('Contracts', 25),
      const PieChartDataPoint('Reports', 20),
      const PieChartDataPoint('Manuals', 15),
      const PieChartDataPoint('Other', 5),
    ],
    organizationComparison: [
      const BarChartDataPoint('Acme Corp', 450, 200),
      const BarChartDataPoint('Global Tech', 300, 150),
      const BarChartDataPoint('Stark Ind', 600, 300),
      const BarChartDataPoint('Wayne Ent', 400, 180),
    ],
    mostViewedDocuments: [
      const DocumentItem('DOC-101', 'Q2 Financial Report', '1,204 views'),
      const DocumentItem('DOC-202', 'Employee Handbook 2026', '950 views'),
      const DocumentItem('DOC-303', 'Architecture Guidelines', '840 views'),
      const DocumentItem('DOC-404', 'Marketing Assets ZIP', '710 views'),
      const DocumentItem('DOC-505', 'Vendor Contracts', '650 views'),
    ],
    largestFiles: [
      const DocumentItem('DOC-901', 'Promo_Video_Final.mp4', '1.2 GB'),
      const DocumentItem('DOC-902', 'Database_Backup.sql', '850 MB'),
      const DocumentItem('DOC-903', 'Design_Assets_Pack.zip', '620 MB'),
      const DocumentItem('DOC-904', 'Raw_Analytics_Dump.csv', '450 MB'),
      const DocumentItem('DOC-905', 'Company_Presentation.pptx', '120 MB'),
    ],
    mostShared: [
      const DocumentItem('DOC-111', 'Onboarding Template', '45 shares'),
      const DocumentItem('DOC-222', 'Q1 Roadmap', '38 shares'),
      const DocumentItem('DOC-333', 'Security Policy', '30 shares'),
      const DocumentItem('DOC-444', 'Holiday Schedule', '25 shares'),
      const DocumentItem('DOC-555', 'Client NDA', '22 shares'),
    ],
    recentlyArchived: [
      const DocumentItem('DOC-801', '2024 Tax Returns', 'Archived 2h ago'),
      const DocumentItem('DOC-802', 'Old Logo Assets', 'Archived 5h ago'),
      const DocumentItem('DOC-803', 'Legacy API Docs', 'Archived 1d ago'),
      const DocumentItem('DOC-804', 'Draft Proposals', 'Archived 2d ago'),
      const DocumentItem('DOC-805', 'Project Alpha Specs', 'Archived 3d ago'),
    ],
    aiRecommendations: [
      'Storage usage increased 18% this month due to large video uploads.',
      'Duplicate documents detected in Marketing and Sales folders.',
      'Large unused files identified (DOC-901, DOC-902) saving up to 2GB if archived.',
      'High sharing velocity on "Q2 Financial Report". Consider checking permissions.',
    ],
  );
}
