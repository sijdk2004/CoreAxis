import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/role_form_provider.dart';

class RoleFormScreen extends ConsumerStatefulWidget {
  final String? roleId;

  const RoleFormScreen({super.key, this.roleId});

  @override
  ConsumerState<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends ConsumerState<RoleFormScreen> {
  final _basicInfoFormKey = GlobalKey<FormState>();

  String _name = '';
  String _code = '';
  String _scope = 'Tenant';
  String _description = '';
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roleFormProvider.notifier).init(widget.roleId);
    });
  }

  void _onNext(RoleFormState state) {
    if (state.currentStep == 0) {
      if (!_basicInfoFormKey.currentState!.validate()) return;
      _basicInfoFormKey.currentState!.save();
      ref.read(roleFormProvider.notifier).updateBasicInfo(
        name: _name,
        code: _code,
        scope: _scope,
        description: _description,
        status: _status,
      );
    }
    
    if (state.currentStep == 3) {
      ref.read(roleFormProvider.notifier).submit();
    } else {
      ref.read(roleFormProvider.notifier).nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(roleFormProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final isEditMode = widget.roleId != null && widget.roleId != 'new';

    // Initialize local form fields if we're on step 0 and they're empty
    if (state.currentStep == 0 && state.name.isNotEmpty && _name.isEmpty) {
      _name = state.name;
      _code = state.code;
      _scope = state.scope;
      _description = state.description;
      _status = state.status;
    }

    if (state.isSuccess) {
      return _buildSuccessScreen(context, theme, isEditMode);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/rbac/roles'),
        ),
        title: Text(isEditMode ? 'Edit Role' : 'Create New Role'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildWizardProgress(state.currentStep, theme),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: PremiumCard(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildStepContent(state, theme),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildFooterActions(state),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWizardProgress(int currentStep, ThemeData theme) {
    final steps = ['Basic Info', 'Permissions', 'Users', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isActive = index == currentStep;
          final color = isCompleted || isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.2);

          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive ? theme.colorScheme.primary : (isCompleted ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent),
                        border: Border.all(color: color, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(LucideIcons.check, size: 16, color: theme.colorScheme.primary)
                            : Text(
                                '\${index + 1}',
                                style: TextStyle(
                                  color: isActive ? theme.colorScheme.onPrimary : color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      steps[index],
                      style: TextStyle(
                        color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
                      color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(RoleFormState state, ThemeData theme) {
    switch (state.currentStep) {
      case 0: return _buildStep1BasicInfo();
      case 1: return _buildStep2Permissions(state, theme);
      case 2: return _buildStep3Users(state, theme);
      case 3: return _buildStep4Review(state, theme);
      default: return const SizedBox();
    }
  }

  Widget _buildStep1BasicInfo() {
    return Form(
      key: _basicInfoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Basic Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Role Name', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                  onSaved: (val) => _name = val!,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: _code,
                  decoration: const InputDecoration(labelText: 'Role Code', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                  onSaved: (val) => _code = val!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _scope,
                  decoration: const InputDecoration(labelText: 'Role Scope', border: OutlineInputBorder()),
                  items: ['Platform', 'Tenant', 'System', 'Custom'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _scope = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: ['Active', 'Inactive'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _status = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: _description,
            decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            maxLines: 3,
            onSaved: (val) => _description = val ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Permissions(RoleFormState state, ThemeData theme) {
    final categories = ['User Management', 'Financials', 'Inventory', 'Sales', 'System Settings', 'Reports'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Permission Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Select the permission categories this role should have access to.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        ...categories.map((category) {
          final isSelected = state.selectedPermissions.contains(category);
          return CheckboxListTile(
            title: Text(category, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Full access to \$category modules.'),
            value: isSelected,
            activeColor: theme.colorScheme.primary,
            onChanged: (val) => ref.read(roleFormProvider.notifier).togglePermission(category, val == true),
          );
        }),
      ],
    );
  }

  Widget _buildStep3Users(RoleFormState state, ThemeData theme) {
    final mockUsers = [
      {'id': 'usr_1', 'name': 'Alice Smith', 'email': 'alice@example.com'},
      {'id': 'usr_2', 'name': 'Bob Jones', 'email': 'bob@example.com'},
      {'id': 'usr_3', 'name': 'Charlie Brown', 'email': 'charlie@example.com'},
      {'id': 'usr_4', 'name': 'Diana Prince', 'email': 'diana@example.com'},
      {'id': 'usr_5', 'name': 'Evan Wright', 'email': 'evan@example.com'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assign Users', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Optional: Select users to assign to this role immediately.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search users...',
            prefixIcon: const Icon(LucideIcons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        const SizedBox(height: 16),
        ...mockUsers.map((user) {
          final isSelected = state.selectedUserIds.contains(user['id']);
          return ListTile(
            leading: CircleAvatar(child: Text(user['name']!.substring(0, 1))),
            title: Text(user['name']!),
            subtitle: Text(user['email']!),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (val) => ref.read(roleFormProvider.notifier).toggleUser(user['id']!, val == true),
            ),
            onTap: () => ref.read(roleFormProvider.notifier).toggleUser(user['id']!, !isSelected),
          );
        }),
      ],
    );
  }

  Widget _buildStep4Review(RoleFormState state, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Configuration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow('Role Name', state.name),
              const Divider(height: 24),
              _buildReviewRow('Role Code', state.code),
              const Divider(height: 24),
              _buildReviewRow('Scope', state.scope),
              const Divider(height: 24),
              _buildReviewRow('Status', state.status),
              const Divider(height: 24),
              _buildReviewRow('Description', state.description),
              const Divider(height: 24),
              _buildReviewRow('Permissions Assigned', '\${state.selectedPermissions.length} Categories selected'),
              const Divider(height: 24),
              _buildReviewRow('Users Assigned', '\${state.selectedUserIds.length} Users attached'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildFooterActions(RoleFormState state) {
    final isLastStep = state.currentStep == 3;
    final isEditMode = widget.roleId != null && widget.roleId != 'new';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (state.currentStep > 0)
          OutlinedButton(
            onPressed: state.isSaving ? null : () => ref.read(roleFormProvider.notifier).prevStep(),
            child: const Text('Previous'),
          )
        else
          const SizedBox(), // Placeholder for layout
        
        FilledButton.icon(
          onPressed: state.isSaving ? null : () => _onNext(state),
          icon: state.isSaving 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Icon(isLastStep ? LucideIcons.check : LucideIcons.arrowRight, size: 18),
          label: Text(
            state.isSaving ? 'Saving...' : (isLastStep ? (isEditMode ? 'Update Role' : 'Create Role') : 'Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen(BuildContext context, ThemeData theme, bool isEditMode) {
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
              child: const Icon(LucideIcons.checkCircle, color: Colors.green, size: 64),
            ),
            const SizedBox(height: 24),
            Text(isEditMode ? 'Role Updated Successfully!' : 'Role Created Successfully!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('The role has been saved and is now active.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.go('/platform/rbac/roles'),
              child: const Text('Back to Roles'),
            ),
          ],
        ),
      ),
    );
  }
}
