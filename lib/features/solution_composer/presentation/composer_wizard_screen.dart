import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/solution_composer/application/composer_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';

class ComposerWizardScreen extends ConsumerStatefulWidget {
  final String? blueprintId;
  final String? definitionId;

  const ComposerWizardScreen({super.key, this.blueprintId, this.definitionId})
      : assert(blueprintId != null || definitionId != null,
            'Must provide either blueprintId or definitionId');

  @override
  ConsumerState<ComposerWizardScreen> createState() => _ComposerWizardScreenState();
}

class _ComposerWizardScreenState extends ConsumerState<ComposerWizardScreen> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.definitionId != null) {
        ref.read(composerSessionControllerProvider.notifier).loadExistingDefinition(widget.definitionId!);
      } else if (widget.blueprintId != null) {
        ref.read(composerSessionControllerProvider.notifier).initializeFromBlueprint(widget.blueprintId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(composerSessionControllerProvider);

    if (state.isLoading && state.definition == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null && state.definition == null) {
      return Scaffold(body: Center(child: Text('Error: ${state.error}')));
    }

    final definition = state.definition;
    if (definition == null) {
      return const Scaffold(body: Center(child: Text('Definition not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Composer: ${definition.name}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {
            // Final step: Save
            ref.read(composerSessionControllerProvider.notifier).saveDefinition().then((_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solution Definition Saved!')));
                context.go('/solutions');
              }
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          Step(
            title: const Text('Basic Info'),
            content: _buildBasicInfoStep(definition),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Modules'),
            content: _buildModulesStep(definition),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Configuration'),
            content: _buildConfigurationStep(definition),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Review'),
            content: _buildReviewStep(definition),
            isActive: _currentStep >= 3,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep(SolutionDefinition definition) {
    return Column(
      children: [
        TextFormField(
          initialValue: definition.name,
          decoration: const InputDecoration(labelText: 'Solution Name'),
          onChanged: (val) => ref.read(composerSessionControllerProvider.notifier).updateName(val),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: definition.description,
          decoration: const InputDecoration(labelText: 'Description'),
          maxLines: 3,
          onChanged: (val) => ref.read(composerSessionControllerProvider.notifier).updateDescription(val),
        ),
      ],
    );
  }

  Widget _buildModulesStep(SolutionDefinition definition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Inherited Modules from Blueprint (Read-Only)'),
        const SizedBox(height: 8),
        if (definition.moduleConfigurations.isEmpty)
          const Text('No modules found in this blueprint.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: definition.moduleConfigurations.length,
            itemBuilder: (context, index) {
              final refItem = definition.moduleConfigurations[index];
              return ListTile(
                leading: const Icon(Icons.check_box, color: Colors.grey),
                title: Text(refItem.reference.moduleCode),
                subtitle: Text('Exact Version: ${refItem.reference.exactPublishedVersion}'),
              );
            },
          ),
      ],
    );
  }

  Widget _buildConfigurationStep(SolutionDefinition definition) {
    final currency = definition.solutionConfiguration['currency'] as String? ?? 'USD';
    final language = definition.solutionConfiguration['language'] as String? ?? 'en_US';

    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: currency,
          decoration: const InputDecoration(labelText: 'Default Currency'),
          items: const [
            DropdownMenuItem(value: 'USD', child: Text('USD')),
            DropdownMenuItem(value: 'EUR', child: Text('EUR')),
            DropdownMenuItem(value: 'GBP', child: Text('GBP')),
          ],
          onChanged: (val) {
            if (val != null) {
              ref.read(composerSessionControllerProvider.notifier).updateConfiguration('currency', val);
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: language,
          decoration: const InputDecoration(labelText: 'Default Language'),
          items: const [
            DropdownMenuItem(value: 'en_US', child: Text('English (US)')),
            DropdownMenuItem(value: 'es_ES', child: Text('Spanish (Spain)')),
            DropdownMenuItem(value: 'fr_FR', child: Text('French (France)')),
          ],
          onChanged: (val) {
            if (val != null) {
              ref.read(composerSessionControllerProvider.notifier).updateConfiguration('language', val);
            }
          },
        ),
      ],
    );
  }

  Widget _buildReviewStep(SolutionDefinition definition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ready to save the Solution Definition.', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Text('Name: ${definition.name}'),
        Text('Modules Included: ${definition.moduleConfigurations.length}'),
        Text('Currency: ${definition.solutionConfiguration['currency']}'),
        Text('Language: ${definition.solutionConfiguration['language']}'),
        const SizedBox.shrink(key: ValueKey(1), child: SizedBox()), // Placeholder to handle requested edits structure
      ],
    );
  }
}
