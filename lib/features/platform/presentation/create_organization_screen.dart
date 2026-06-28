import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';

class CreateOrganizationScreen extends ConsumerStatefulWidget {
  const CreateOrganizationScreen({super.key});

  @override
  ConsumerState<CreateOrganizationScreen> createState() => _CreateOrganizationScreenState();
}

class _CreateOrganizationScreenState extends ConsumerState<CreateOrganizationScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isSuccess = false;

  final List<GlobalKey<FormState>> _formKeys = List.generate(5, (index) => GlobalKey<FormState>());

  // Step 1
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  String _selectedTenant = 'Stellar Tech';
  String _selectedIndustry = 'Technology';
  String _selectedBusinessType = 'B2B';
  
  // Step 2
  final _regNumCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  DateTime _incorpDate = DateTime.now();

  // Step 3
  final _contactPersonCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  // Step 4
  final _countryCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();

  // Step 5
  String _selectedCurrency = 'USD';
  String _selectedTimeZone = 'UTC';
  String _selectedLanguage = 'English';
  String _selectedFiscalYear = 'Jan - Dec';
  String _selectedWorkingDays = 'Mon - Fri';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _regNumCtrl.dispose();
    _gstCtrl.dispose();
    _panCtrl.dispose();
    _contactPersonCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _websiteCtrl.dispose();
    _countryCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      if (_formKeys[_currentStep].currentState?.validate() ?? true) {
        setState(() => _currentStep++);
      }
    } else {
      _submit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock save
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isSuccess) {
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
              Text('Organization Created Successfully!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))
                  .animate().fade(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: 16),
              const Text('The new organization has been registered under the selected tenant.')
                  .animate().fade(delay: 400.ms),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  // Route back to organizations list
                  context.go('/platform/organizations');
                },
                child: const Text('Back to Organizations'),
              ).animate().fade(delay: 600.ms),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Create Organization'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/organizations'),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              elevation: 0,
              onStepTapped: (step) {
                if (step < _currentStep) {
                  setState(() => _currentStep = step);
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 32.0, bottom: 32.0),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        OutlinedButton(
                          onPressed: _isLoading ? null : _previousStep,
                          child: const Text('Previous'),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 16),
                      FilledButton(
                        onPressed: _isLoading ? null : _nextStep,
                        child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_currentStep == 5 ? 'Create Organization' : 'Next'),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
                _buildStep5(),
                _buildStep6(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Step _buildStep1() {
    return Step(
      title: const Text('Basic Info'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[0],
        child: PremiumCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Organization Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Organization Name', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: TextFormField(
                      controller: _codeCtrl,
                      decoration: const InputDecoration(labelText: 'Organization Code', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTenant,
                      decoration: const InputDecoration(labelText: 'Tenant', border: OutlineInputBorder()),
                      items: ['Stellar Tech', 'Acme Corp', 'Wayne Enterprises', 'Stark Industries'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedTenant = v!),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedIndustry,
                      decoration: const InputDecoration(labelText: 'Industry', border: OutlineInputBorder()),
                      items: ['Technology', 'Healthcare', 'Finance', 'Manufacturing', 'Retail', 'Service'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedIndustry = v!),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedBusinessType,
                      decoration: const InputDecoration(labelText: 'Business Type', border: OutlineInputBorder()),
                      items: ['B2B', 'B2C', 'B2B2C', 'D2C'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedBusinessType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(LucideIcons.imagePlus, size: 32),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(onPressed: () {}, child: const Text('Upload Logo')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildStep2() {
    return Step(
      title: const Text('Registration'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[1],
        child: PremiumCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registration Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _regNumCtrl,
                      decoration: const InputDecoration(labelText: 'Registration Number', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: TextFormField(
                      controller: _gstCtrl,
                      decoration: const InputDecoration(labelText: 'GST / VAT Number', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _panCtrl,
                      decoration: const InputDecoration(labelText: 'PAN / Tax ID', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(context: context, initialDate: _incorpDate, firstDate: DateTime(1900), lastDate: DateTime.now());
                        if (date != null) setState(() => _incorpDate = date);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Incorporation Date', border: OutlineInputBorder()),
                        child: Text('${_incorpDate.year}-${_incorpDate.month.toString().padLeft(2, '0')}-${_incorpDate.day.toString().padLeft(2, '0')}'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildStep3() {
    return Step(
      title: const Text('Contact'),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[2],
        child: PremiumCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contactPersonCtrl,
                      decoration: const InputDecoration(labelText: 'Contact Person Name', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                      validator: (val) => val != null && val.isNotEmpty && !val.contains('@') ? 'Invalid Email' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: TextFormField(
                      controller: _websiteCtrl,
                      decoration: const InputDecoration(labelText: 'Website URL', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildStep4() {
    return Step(
      title: const Text('Address'),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[3],
        child: PremiumCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Street Address', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: TextFormField(
                      controller: _stateCtrl,
                      decoration: const InputDecoration(labelText: 'State / Province', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _countryCtrl,
                      decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: TextFormField(
                      controller: _postalCtrl,
                      decoration: const InputDecoration(labelText: 'Postal / Zip Code', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildStep5() {
    return Step(
      title: const Text('Config'),
      isActive: _currentStep >= 4,
      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[4],
        child: PremiumCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuration', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: const InputDecoration(labelText: 'Base Currency', border: OutlineInputBorder()),
                      items: ['USD', 'EUR', 'GBP', 'INR', 'AUD'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedCurrency = v!),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTimeZone,
                      decoration: const InputDecoration(labelText: 'Time Zone', border: OutlineInputBorder()),
                      items: ['UTC', 'EST', 'PST', 'GMT', 'IST'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedTimeZone = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(labelText: 'System Language', border: OutlineInputBorder()),
                      items: ['English', 'Spanish', 'French', 'German'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedLanguage = v!),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFiscalYear,
                      decoration: const InputDecoration(labelText: 'Fiscal Year', border: OutlineInputBorder()),
                      items: ['Jan - Dec', 'Apr - Mar', 'Jul - Jun', 'Oct - Sep'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedFiscalYear = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedWorkingDays,
                      decoration: const InputDecoration(labelText: 'Working Days', border: OutlineInputBorder()),
                      items: ['Mon - Fri', 'Sun - Thu', 'Mon - Sat'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedWorkingDays = v!),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildStep6() {
    return Step(
      title: const Text('Review'),
      isActive: _currentStep >= 5,
      state: StepState.indexed,
      content: PremiumCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review Organization Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSummarySection('Basic Info', {
                  'Name': _nameCtrl.text,
                  'Code': _codeCtrl.text,
                  'Tenant': _selectedTenant,
                  'Industry': _selectedIndustry,
                  'Business Type': _selectedBusinessType,
                })),
                const SizedBox(width: 24),
                Expanded(child: _buildSummarySection('Registration', {
                  'Reg No': _regNumCtrl.text,
                  'GST/VAT': _gstCtrl.text,
                  'PAN': _panCtrl.text,
                  'Incorp. Date': '${_incorpDate.year}-${_incorpDate.month}-${_incorpDate.day}',
                })),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSummarySection('Contact', {
                  'Person': _contactPersonCtrl.text,
                  'Email': _emailCtrl.text,
                  'Phone': _phoneCtrl.text,
                  'Website': _websiteCtrl.text,
                })),
                const SizedBox(width: 24),
                Expanded(child: _buildSummarySection('Address', {
                  'Street': _addressCtrl.text,
                  'City': _cityCtrl.text,
                  'State': _stateCtrl.text,
                  'Country': _countryCtrl.text,
                })),
              ],
            ),
            const SizedBox(height: 24),
            _buildSummarySection('Configuration', {
              'Currency': _selectedCurrency,
              'Time Zone': _selectedTimeZone,
              'Language': _selectedLanguage,
              'Fiscal Year': _selectedFiscalYear,
              'Working Days': _selectedWorkingDays,
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(String title, Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...data.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 100, child: Text(e.key, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))),
              Expanded(child: Text(e.value.isEmpty ? '-' : e.value, style: const TextStyle(fontWeight: FontWeight.w500))),
            ],
          ),
        )).toList(),
      ],
    );
  }
}
