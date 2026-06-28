import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/create_tenant_provider.dart';

class CreateTenantScreen extends ConsumerStatefulWidget {
  const CreateTenantScreen({super.key});

  @override
  ConsumerState<CreateTenantScreen> createState() => _CreateTenantScreenState();
}

class _CreateTenantScreenState extends ConsumerState<CreateTenantScreen> {
  final _formKeys = List.generate(4, (index) => GlobalKey<FormState>());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(createTenantProvider);

    if (state.isSuccess) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.checkCircle, size: 80, color: Colors.green),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text('Tenant Created Successfully!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))
                  .animate().fade(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: 16),
              const Text('The new tenant workspace is being provisioned.')
                  .animate().fade(delay: 400.ms),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  ref.read(createTenantProvider.notifier).reset();
                  // Mock navigating to the new tenant's detail page
                  context.go('/platform/tenants/TEN-NEW');
                },
                child: const Text('View Tenant Details'),
              ).animate().fade(delay: 600.ms),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Create New Tenant'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/tenants'),
        ),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: state.currentStep,
        onStepTapped: (step) {
          // Allow jumping back, but not forward without validation
          if (step < state.currentStep) {
            ref.read(createTenantProvider.notifier).setStep(step);
          }
        },
        controlsBuilder: (context, details) {
          final isLastStep = state.currentStep == 4;
          return Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Row(
              children: [
                if (state.currentStep > 0)
                  OutlinedButton(
                    onPressed: state.isLoading ? null : () => ref.read(createTenantProvider.notifier).previousStep(),
                    child: const Text('Previous'),
                  ),
                if (state.currentStep > 0) const SizedBox(width: 16),
                FilledButton(
                  onPressed: state.isLoading ? null : () {
                    if (state.currentStep < 4) {
                      if (_formKeys[state.currentStep].currentState?.validate() ?? true) {
                        _formKeys[state.currentStep].currentState?.save();
                        ref.read(createTenantProvider.notifier).nextStep();
                      }
                    } else {
                      ref.read(createTenantProvider.notifier).submit();
                    }
                  },
                  child: state.isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isLastStep ? 'Create Tenant' : 'Next'),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Basic Info'),
            isActive: state.currentStep >= 0,
            state: state.currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildBasicInfoStep(state),
          ),
          Step(
            title: const Text('Contact'),
            isActive: state.currentStep >= 1,
            state: state.currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildContactStep(state),
          ),
          Step(
            title: const Text('Address'),
            isActive: state.currentStep >= 2,
            state: state.currentStep > 2 ? StepState.complete : StepState.indexed,
            content: _buildAddressStep(state),
          ),
          Step(
            title: const Text('Subscription'),
            isActive: state.currentStep >= 3,
            state: state.currentStep > 3 ? StepState.complete : StepState.indexed,
            content: _buildSubscriptionStep(state),
          ),
          Step(
            title: const Text('Review'),
            isActive: state.currentStep == 4,
            content: _buildReviewStep(state),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep(CreateTenantState state) {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Basic Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildTextField(
                label: 'Tenant Name',
                initialValue: state.tenantName,
                onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(tenantName: val),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
              )),
              const SizedBox(width: 24),
              Expanded(child: _buildTextField(
                label: 'Tenant Code',
                initialValue: state.tenantCode,
                onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(tenantCode: val),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
              )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(
                label: 'Legal Name',
                initialValue: state.legalName,
                onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(legalName: val),
              )),
              const SizedBox(width: 24),
              Expanded(child: _buildTextField(
                label: 'Industry',
                initialValue: state.industry,
                onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(industry: val),
              )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Business Type',
            initialValue: state.businessType,
            onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(businessType: val),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.uploadCloud),
            label: const Text('Upload Logo (Mock)'),
          )
        ],
      ),
    );
  }

  Widget _buildContactStep(CreateTenantState state) {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildTextField(
                label: 'Contact Person',
                initialValue: state.contactPerson,
                onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(contactPerson: val),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
              )),
              const SizedBox(width: 24),
              Expanded(child: _buildTextField(
                label: 'Email',
                initialValue: state.email,
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(email: val),
                validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
              )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(
                label: 'Mobile',
                initialValue: state.mobile,
                keyboardType: TextInputType.phone,
                onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(mobile: val),
              )),
              const SizedBox(width: 24),
              Expanded(child: _buildTextField(
                label: 'Website',
                initialValue: state.website,
                keyboardType: TextInputType.url,
                onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(website: val),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep(CreateTenantState state) {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Address Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Address',
            initialValue: state.address,
            onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(address: val),
            validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(
                label: 'City',
                initialValue: state.city,
                onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(city: val),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
              )),
              const SizedBox(width: 24),
              Expanded(child: _buildTextField(
                label: 'State/Province',
                initialValue: state.stateProvince,
                onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(stateProvince: val),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
              )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(
                label: 'Postal Code',
                initialValue: state.postalCode,
                onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(postalCode: val),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
              )),
              const SizedBox(width: 24),
              Expanded(child: _buildTextField(
                label: 'Country',
                initialValue: state.country,
                onSaved: (val) => ref.read(createTenantProvider.notifier).updateField(country: val),
                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStep(CreateTenantState state) {
    return Form(
      key: _formKeys[3],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Subscription Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Choose a plan for the new tenant.'),
          const SizedBox(height: 24),
          FormField<String>(
            initialValue: state.subscriptionPlan,
            validator: (val) => state.subscriptionPlan.isEmpty ? 'Please select a plan' : null,
            builder: (field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildPlanCard('Trial', '14 Days Free', 'Up to 5 Users\n10GB Storage\nBasic Modules', state)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPlanCard('Basic', '\$99 / month', 'Up to 20 Users\n50GB Storage\nCore ERP Modules', state)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildPlanCard('Professional', '\$299 / month', 'Up to 100 Users\n250GB Storage\nAdvanced Analytics', state)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPlanCard('Enterprise', 'Custom Pricing', 'Unlimited Users\nUnlimited Storage\nAll Modules + Dedicated Support', state)),
                    ],
                  ),
                  if (field.hasError) 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(field.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                    )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String title, String subtitle, String features, CreateTenantState state) {
    final theme = Theme.of(context);
    final isSelected = state.subscriptionPlan == title;

    return InkWell(
      onTap: () => ref.read(createTenantProvider.notifier).updateField(subscriptionPlan: title),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (isSelected) const Icon(LucideIcons.checkCircle2, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(features, style: TextStyle(color: Colors.grey.shade600, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep(CreateTenantState state) {
    return PremiumCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildReviewRow('Tenant Name', state.tenantName),
          _buildReviewRow('Tenant Code', state.tenantCode),
          _buildReviewRow('Contact Person', state.contactPerson),
          _buildReviewRow('Email', state.email),
          _buildReviewRow('Address', '${state.address}, ${state.city}, ${state.stateProvince} ${state.country}'),
          _buildReviewRow('Subscription Plan', state.subscriptionPlan, isHighlight: true),
          if (state.error != null)
             Padding(
               padding: const EdgeInsets.only(top: 16.0),
               child: Text(state.error!, style: const TextStyle(color: Colors.red)),
             )
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: TextStyle(fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal, color: isHighlight ? Colors.blue : null))),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
