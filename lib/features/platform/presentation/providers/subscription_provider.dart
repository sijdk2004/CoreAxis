import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/tenant.dart';
import 'tenant_provider.dart';

class Invoice {
  final String id;
  final DateTime date;
  final double amount;
  final String status; // Paid, Pending, Overdue
  final String pdfLink;

  Invoice({required this.id, required this.date, required this.amount, required this.status, required this.pdfLink});
}

class BillingHistory {
  final String id;
  final DateTime date;
  final String description;
  final double amount;

  BillingHistory({required this.id, required this.date, required this.description, required this.amount});
}

class SubscriptionState {
  final Tenant tenant;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool autoRenewal;
  final int usedLicenses;
  final int maxLicenses;
  final int usedStorageGb;
  final int maxStorageGb;
  final int apiCalls;
  final int maxApiCalls;
  final List<Invoice> invoices;
  final List<BillingHistory> history;
  final Map<String, dynamic> charts;

  SubscriptionState({
    required this.tenant,
    required this.startDate,
    required this.expiryDate,
    required this.autoRenewal,
    required this.usedLicenses,
    required this.maxLicenses,
    required this.usedStorageGb,
    required this.maxStorageGb,
    required this.apiCalls,
    required this.maxApiCalls,
    required this.invoices,
    required this.history,
    required this.charts,
  });
}

final subscriptionProvider = FutureProvider.family<SubscriptionState, String>((ref, id) async {
  await Future.delayed(const Duration(milliseconds: 600));

  final repo = ref.read(tenantRepositoryProvider);
  final allTenants = await repo.getTenants();
  
  final tenant = allTenants.firstWhere(
    (t) => t.id == id,
    orElse: () => Tenant(
      id: id,
      name: 'Newly Created Tenant',
      code: 'NEW-TEN',
      logoUrl: 'https://ui-avatars.com/api/?name=New+Tenant&background=random',
      organizationCount: 0,
      userCount: 1,
      subscriptionPlan: 'Trial',
      status: 'Active',
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
    ),
  );

  final invoices = [
    Invoice(id: 'INV-1044', date: DateTime.now().subtract(const Duration(days: 5)), amount: 299.00, status: 'Paid', pdfLink: '#'),
    Invoice(id: 'INV-1031', date: DateTime.now().subtract(const Duration(days: 35)), amount: 299.00, status: 'Paid', pdfLink: '#'),
    Invoice(id: 'INV-1018', date: DateTime.now().subtract(const Duration(days: 65)), amount: 299.00, status: 'Paid', pdfLink: '#'),
  ];

  final history = [
    BillingHistory(id: 'TXN-9821', date: DateTime.now().subtract(const Duration(days: 5)), description: 'Monthly Subscription - Professional', amount: 299.00),
    BillingHistory(id: 'TXN-9122', date: DateTime.now().subtract(const Duration(days: 35)), description: 'Monthly Subscription - Professional', amount: 299.00),
    BillingHistory(id: 'TXN-8541', date: DateTime.now().subtract(const Duration(days: 65)), description: 'Monthly Subscription - Professional', amount: 299.00),
    BillingHistory(id: 'TXN-8012', date: DateTime.now().subtract(const Duration(days: 95)), description: 'Plan Upgrade (Basic -> Pro)', amount: 200.00),
  ];

  return SubscriptionState(
    tenant: tenant,
    startDate: DateTime.now().subtract(const Duration(days: 120)),
    expiryDate: DateTime.now().add(const Duration(days: 25)),
    autoRenewal: true,
    usedLicenses: tenant.userCount,
    maxLicenses: tenant.subscriptionPlan == 'Enterprise' ? 1000 : (tenant.subscriptionPlan == 'Professional' ? 100 : 20),
    usedStorageGb: 12,
    maxStorageGb: tenant.subscriptionPlan == 'Enterprise' ? 1000 : (tenant.subscriptionPlan == 'Professional' ? 250 : 50),
    apiCalls: 120500,
    maxApiCalls: 500000,
    invoices: invoices,
    history: history,
    charts: {
      'user_usage': [
        {'label': 'Week 1', 'value': 20},
        {'label': 'Week 2', 'value': 45},
        {'label': 'Week 3', 'value': 75},
        {'label': 'Week 4', 'value': 90},
      ],
      'storage_usage': [
        {'label': 'Database', 'value': 40},
        {'label': 'Files', 'value': 35},
        {'label': 'Backups', 'value': 15},
        {'label': 'Free', 'value': 10},
      ],
    }
  );
});
