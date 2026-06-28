import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/tenant.dart';

class CreateTenantState {
  final int currentStep;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  // Step 1: Basic
  final String tenantName;
  final String tenantCode;
  final String legalName;
  final String industry;
  final String businessType;
  final String logoUrl;

  // Step 2: Contact
  final String contactPerson;
  final String email;
  final String mobile;
  final String website;

  // Step 3: Address
  final String country;
  final String stateProvince;
  final String city;
  final String address;
  final String postalCode;

  // Step 4: Subscription
  final String subscriptionPlan;

  CreateTenantState({
    this.currentStep = 0,
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.tenantName = '',
    this.tenantCode = '',
    this.legalName = '',
    this.industry = '',
    this.businessType = '',
    this.logoUrl = '',
    this.contactPerson = '',
    this.email = '',
    this.mobile = '',
    this.website = '',
    this.country = '',
    this.stateProvince = '',
    this.city = '',
    this.address = '',
    this.postalCode = '',
    this.subscriptionPlan = '',
  });

  CreateTenantState copyWith({
    int? currentStep,
    bool? isLoading,
    bool? isSuccess,
    String? error,
    String? tenantName,
    String? tenantCode,
    String? legalName,
    String? industry,
    String? businessType,
    String? logoUrl,
    String? contactPerson,
    String? email,
    String? mobile,
    String? website,
    String? country,
    String? stateProvince,
    String? city,
    String? address,
    String? postalCode,
    String? subscriptionPlan,
  }) {
    return CreateTenantState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      tenantName: tenantName ?? this.tenantName,
      tenantCode: tenantCode ?? this.tenantCode,
      legalName: legalName ?? this.legalName,
      industry: industry ?? this.industry,
      businessType: businessType ?? this.businessType,
      logoUrl: logoUrl ?? this.logoUrl,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      website: website ?? this.website,
      country: country ?? this.country,
      stateProvince: stateProvince ?? this.stateProvince,
      city: city ?? this.city,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
    );
  }
}

class CreateTenantNotifier extends Notifier<CreateTenantState> {
  @override
  CreateTenantState build() {
    return CreateTenantState();
  }

  void updateField({
    String? tenantName, String? tenantCode, String? legalName, String? industry, String? businessType, String? logoUrl,
    String? contactPerson, String? email, String? mobile, String? website,
    String? country, String? stateProvince, String? city, String? address, String? postalCode,
    String? subscriptionPlan,
  }) {
    state = state.copyWith(
      tenantName: tenantName,
      tenantCode: tenantCode,
      legalName: legalName,
      industry: industry,
      businessType: businessType,
      logoUrl: logoUrl,
      contactPerson: contactPerson,
      email: email,
      mobile: mobile,
      website: website,
      country: country,
      stateProvince: stateProvince,
      city: city,
      address: address,
      postalCode: postalCode,
      subscriptionPlan: subscriptionPlan,
    );
  }

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step);
    }
  }

  Future<void> submit() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network request
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create tenant: $e');
    }
  }

  void reset() {
    state = CreateTenantState();
  }
}

final createTenantProvider = NotifierProvider<CreateTenantNotifier, CreateTenantState>(() {
  return CreateTenantNotifier();
});
