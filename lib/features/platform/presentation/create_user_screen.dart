import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../domain/models/platform_user.dart';
import 'providers/create_user_provider.dart';

class CreateUserScreen extends ConsumerStatefulWidget {
  const CreateUserScreen({super.key});

  @override
  ConsumerState<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends ConsumerState<CreateUserScreen> {
  final _formKeys = List.generate(5, (index) => GlobalKey<FormState>());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(createUserProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    if (state.isSuccess) {
      return _buildSuccessView(context, theme);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Create New User'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/users'),
        ),
      ),
      body: Stepper(
        type: isDesktop ? StepperType.horizontal : StepperType.vertical,
        currentStep: state.currentStep,
        onStepTapped: (step) {
          // Allow jumping back, but not forward without validation
          if (step < state.currentStep) {
            ref.read(createUserProvider.notifier).setStep(step);
          }
        },
        controlsBuilder: (context, details) {
          final isLastStep = state.currentStep == 5;
          return Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Row(
              children: [
                if (state.currentStep > 0)
                  OutlinedButton(
                    onPressed: state.isLoading ? null : () => ref.read(createUserProvider.notifier).previousStep(),
                    child: const Text('Previous'),
                  ),
                if (state.currentStep > 0) const SizedBox(width: 16),
                FilledButton(
                  onPressed: state.isLoading ? null : () {
                    if (state.currentStep < 5) {
                      if (_formKeys[state.currentStep].currentState?.validate() ?? true) {
                        _formKeys[state.currentStep].currentState?.save();
                        ref.read(createUserProvider.notifier).nextStep();
                      }
                    } else {
                      ref.read(createUserProvider.notifier).submit();
                    }
                  },
                  child: state.isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isLastStep ? 'Create User' : 'Next'),
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
            title: const Text('Organization'),
            isActive: state.currentStep >= 2,
            state: state.currentStep > 2 ? StepState.complete : StepState.indexed,
            content: _buildOrganizationStep(state),
          ),
          Step(
            title: const Text('Security'),
            isActive: state.currentStep >= 3,
            state: state.currentStep > 3 ? StepState.complete : StepState.indexed,
            content: _buildSecurityStep(state),
          ),
          Step(
            title: const Text('Roles'),
            isActive: state.currentStep >= 4,
            state: state.currentStep > 4 ? StepState.complete : StepState.indexed,
            content: _buildRolesStep(state, theme),
          ),
          Step(
            title: const Text('Review'),
            isActive: state.currentStep == 5,
            content: _buildReviewStep(state, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, ThemeData theme) {
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
            Text('User Created Successfully!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))
                .animate().fade(delay: 200.ms).slideY(begin: 0.2),
            const SizedBox(height: 16),
            const Text('The new user account has been provisioned and an invitation email has been sent.')
                .animate().fade(delay: 400.ms),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                ref.read(createUserProvider.notifier).reset();
                context.go('/platform/users');
              },
              child: const Text('Back to Users List'),
            ).animate().fade(delay: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep(CreateUserState state) {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: state.firstName,
                  decoration: const InputDecoration(labelText: 'First Name', prefixIcon: Icon(LucideIcons.user)),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => ref.read(createUserProvider.notifier).updateBasicInfo(firstName: value, lastName: state.lastName, employeeId: state.employeeId, gender: state.gender, dob: state.dob),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: state.lastName,
                  decoration: const InputDecoration(labelText: 'Last Name', prefixIcon: Icon(LucideIcons.user)),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => ref.read(createUserProvider.notifier).updateBasicInfo(firstName: state.firstName, lastName: value, employeeId: state.employeeId, gender: state.gender, dob: state.dob),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: state.employeeId,
                  decoration: const InputDecoration(labelText: 'Employee ID', prefixIcon: Icon(LucideIcons.badgeCheck)),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => ref.read(createUserProvider.notifier).updateBasicInfo(firstName: state.firstName, lastName: state.lastName, employeeId: value, gender: state.gender, dob: state.dob),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(LucideIcons.users)),
                  value: state.gender,
                  items: ['Male', 'Female', 'Other', 'Prefer not to say']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) => ref.read(createUserProvider.notifier).updateBasicInfo(firstName: state.firstName, lastName: state.lastName, employeeId: state.employeeId, gender: value, dob: state.dob),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactStep(CreateUserState state) {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: state.email,
            decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(LucideIcons.mail)),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
            onSaved: (value) => ref.read(createUserProvider.notifier).updateContactInfo(email: value, mobile: state.mobile, altMobile: state.altMobile),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: state.mobile,
                  decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(LucideIcons.smartphone)),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => ref.read(createUserProvider.notifier).updateContactInfo(email: state.email, mobile: value, altMobile: state.altMobile),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: state.altMobile,
                  decoration: const InputDecoration(labelText: 'Alternate Mobile (Optional)', prefixIcon: Icon(LucideIcons.phone)),
                  onSaved: (value) => ref.read(createUserProvider.notifier).updateContactInfo(email: state.email, mobile: state.mobile, altMobile: value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationStep(CreateUserState state) {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Tenant', prefixIcon: Icon(LucideIcons.building)),
            value: state.tenantId,
            items: const [
              DropdownMenuItem(value: 'TN-100', child: Text('Acme Corp')),
              DropdownMenuItem(value: 'TN-101', child: Text('Globex')),
            ],
            onChanged: (value) => ref.read(createUserProvider.notifier).updateOrganization(tenantId: value, orgId: state.orgId, branchId: state.branchId, departmentId: state.departmentId, designation: state.designation),
            validator: (value) => value == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Organization', prefixIcon: Icon(LucideIcons.network)),
            value: state.orgId,
            items: const [
              DropdownMenuItem(value: 'ORG-100', child: Text('Acme North America')),
              DropdownMenuItem(value: 'ORG-200', child: Text('Acme Europe')),
            ],
            onChanged: (value) => ref.read(createUserProvider.notifier).updateOrganization(tenantId: state.tenantId, orgId: value, branchId: state.branchId, departmentId: state.departmentId, designation: state.designation),
            validator: (value) => value == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(LucideIcons.users)),
                  value: state.departmentId,
                  items: const [
                    DropdownMenuItem(value: 'Engineering', child: Text('Engineering')),
                    DropdownMenuItem(value: 'Sales', child: Text('Sales')),
                    DropdownMenuItem(value: 'HR', child: Text('HR')),
                  ],
                  onChanged: (value) => ref.read(createUserProvider.notifier).updateOrganization(tenantId: state.tenantId, orgId: state.orgId, branchId: state.branchId, departmentId: value, designation: state.designation),
                  validator: (value) => value == null ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: state.designation,
                  decoration: const InputDecoration(labelText: 'Designation', prefixIcon: Icon(LucideIcons.briefcase)),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => ref.read(createUserProvider.notifier).updateOrganization(tenantId: state.tenantId, orgId: state.orgId, branchId: state.branchId, departmentId: state.departmentId, designation: value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStep(CreateUserState state) {
    return Form(
      key: _formKeys[3],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: state.username,
            decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(LucideIcons.userCheck)),
            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            onSaved: (value) => ref.read(createUserProvider.notifier).updateSecurity(username: value, tempPassword: state.tempPassword, requirePasswordChange: state.requirePasswordChange, enableMfa: state.enableMfa, status: state.status),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: state.tempPassword,
            decoration: const InputDecoration(labelText: 'Temporary Password', prefixIcon: Icon(LucideIcons.lock)),
            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            onSaved: (value) => ref.read(createUserProvider.notifier).updateSecurity(username: state.username, tempPassword: value, requirePasswordChange: state.requirePasswordChange, enableMfa: state.enableMfa, status: state.status),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Require Password Change'),
            subtitle: const Text('User must change password on first login'),
            value: state.requirePasswordChange,
            onChanged: (value) => ref.read(createUserProvider.notifier).updateSecurity(username: state.username, tempPassword: state.tempPassword, requirePasswordChange: value, enableMfa: state.enableMfa, status: state.status),
          ),
          SwitchListTile(
            title: const Text('Enable MFA'),
            subtitle: const Text('Require Multi-Factor Authentication'),
            value: state.enableMfa,
            onChanged: (value) => ref.read(createUserProvider.notifier).updateSecurity(username: state.username, tempPassword: state.tempPassword, requirePasswordChange: state.requirePasswordChange, enableMfa: value, status: state.status),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesStep(CreateUserState state, ThemeData theme) {
    return Form(
      key: _formKeys[4],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: PlatformUserRole.values.map((role) {
          final isSelected = state.selectedRoles.contains(role);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant),
            ),
            child: CheckboxListTile(
              title: Text(_getRoleName(role), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_getRoleDescription(role)),
              value: isSelected,
              onChanged: (_) {
                ref.read(createUserProvider.notifier).toggleRole(role);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewStep(CreateUserState state, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.error != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.alertCircle, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Expanded(child: Text(state.error!, style: TextStyle(color: theme.colorScheme.error))),
              ],
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummarySection(theme, 'Basic Info', [
                  _buildSummaryRow('Name', '${state.firstName} ${state.lastName}'),
                  _buildSummaryRow('Employee ID', state.employeeId),
                  _buildSummaryRow('Gender', state.gender),
                ]),
                const Divider(height: 32),
                _buildSummarySection(theme, 'Contact Info', [
                  _buildSummaryRow('Email', state.email),
                  _buildSummaryRow('Mobile', state.mobile),
                ]),
                const Divider(height: 32),
                _buildSummarySection(theme, 'Organization', [
                  _buildSummaryRow('Tenant', state.tenantId ?? 'Not selected'),
                  _buildSummaryRow('Organization', state.orgId ?? 'Not selected'),
                  _buildSummaryRow('Department', state.departmentId ?? 'Not selected'),
                  _buildSummaryRow('Designation', state.designation),
                ]),
                const Divider(height: 32),
                _buildSummarySection(theme, 'Security', [
                  _buildSummaryRow('Username', state.username),
                  _buildSummaryRow('Require Password Change', state.requirePasswordChange ? 'Yes' : 'No'),
                  _buildSummaryRow('MFA Enabled', state.enableMfa ? 'Yes' : 'No'),
                ]),
                const Divider(height: 32),
                _buildSummarySection(theme, 'Roles', [
                  Text(
                    state.selectedRoles.isEmpty 
                        ? 'No roles selected'
                        : state.selectedRoles.map((r) => _getRoleName(r)).join(', '),
                    style: theme.textTheme.bodyMedium,
                  ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  String _getRoleName(PlatformUserRole role) {
    switch (role) {
      case PlatformUserRole.systemAdmin: return 'System Admin';
      case PlatformUserRole.tenantAdmin: return 'Tenant Admin';
      case PlatformUserRole.organizationAdmin: return 'Organization Admin';
      case PlatformUserRole.manager: return 'Manager';
      case PlatformUserRole.user: return 'Standard User';
    }
  }

  String _getRoleDescription(PlatformUserRole role) {
    switch (role) {
      case PlatformUserRole.systemAdmin: return 'Full access to all tenants and platform settings.';
      case PlatformUserRole.tenantAdmin: return 'Manage all organizations within a single tenant.';
      case PlatformUserRole.organizationAdmin: return 'Manage specific organization settings and users.';
      case PlatformUserRole.manager: return 'Manage specific departments and view reports.';
      case PlatformUserRole.user: return 'Basic access to assigned applications and tasks.';
    }
  }
}
