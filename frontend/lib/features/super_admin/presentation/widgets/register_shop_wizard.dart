import 'package:flutter/material.dart';
import '../../../../core/models/registered_shop_item.dart';
import '../../../../core/repositories/shop_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/npts_logo.dart';

class RegisterShopWizardDialog extends StatefulWidget {
  final List<PlanTier> plans;
  final void Function(RegisteredShopItem created) onShopCreated;

  const RegisterShopWizardDialog({
    super.key,
    required this.plans,
    required this.onShopCreated,
  });

  @override
  State<RegisterShopWizardDialog> createState() => _RegisterShopWizardDialogState();
}

class _RegisterShopWizardDialogState extends State<RegisterShopWizardDialog> {
  int _step = 0;
  bool _submitting = false;

  // Step 1: Business
  final _shopNameCtrl = TextEditingController();
  String _shopType = 'Supermarket';
  final _bizPhoneCtrl = TextEditingController();
  final _bizEmailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'Pakistan');

  // Step 2: Owner
  final _ownerNameCtrl = TextEditingController();
  final _ownerUsernameCtrl = TextEditingController();
  final _ownerEmailCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(text: 'Pass@123');
  final _confirmPassCtrl = TextEditingController(text: 'Pass@123');

  // Step 3: Subscription
  late String _selectedPlanSlug;
  String _billingCycle = 'MONTHLY';
  bool _isTrial = false;
  final _discountCtrl = TextEditingController(text: '0');
  final _initialPaymentCtrl = TextEditingController(text: '0');

  // Step 4: Main Branch
  final _branchNameCtrl = TextEditingController(text: 'Main Branch');
  final _branchCodeCtrl = TextEditingController(text: 'BR-001');
  final _branchAddressCtrl = TextEditingController();
  final _branchPhoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final activePlans = widget.plans.where((p) => p.isActive).toList();
    _selectedPlanSlug = activePlans.isNotEmpty ? activePlans.first.slug : 'STANDARD';
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _bizPhoneCtrl.dispose();
    _bizEmailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _ownerNameCtrl.dispose();
    _ownerUsernameCtrl.dispose();
    _ownerEmailCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    _discountCtrl.dispose();
    _initialPaymentCtrl.dispose();
    _branchNameCtrl.dispose();
    _branchCodeCtrl.dispose();
    _branchAddressCtrl.dispose();
    _branchPhoneCtrl.dispose();
    super.dispose();
  }

  String? _validateCurrentStep() {
    if (_step == 0 && _shopNameCtrl.text.trim().isEmpty) {
      return 'Please enter Business Name.';
    }
    if (_step == 1) {
      if (_ownerNameCtrl.text.trim().isEmpty) return 'Please enter Owner Full Name.';
      if (_passwordCtrl.text.length < 6) return 'Password must be at least 6 characters.';
      if (_passwordCtrl.text != _confirmPassCtrl.text) return 'Passwords do not match.';
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final created = await ShopRepository().createShopFromWizard({
        'shopName': _shopNameCtrl.text.trim(),
        'shopType': _shopType,
        'phone': _bizPhoneCtrl.text.trim(),
        'email': _bizEmailCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'owner': _ownerNameCtrl.text.trim(),
        'ownerUsername': _ownerUsernameCtrl.text.trim(),
        'ownerEmail': _ownerEmailCtrl.text.trim(),
        'ownerPhone': _ownerPhoneCtrl.text.trim(),
        'password': _passwordCtrl.text,
        'plan': _selectedPlanSlug,
        'billingCycle': _billingCycle,
        'isTrial': _isTrial || _selectedPlanSlug == 'TRIAL',
        'discount': int.tryParse(_discountCtrl.text.trim()) ?? 0,
        'initialPayment': int.tryParse(_initialPaymentCtrl.text.trim()) ?? 0,
        'branchName': _branchNameCtrl.text.trim(),
        'branchCode': _branchCodeCtrl.text.trim(),
        'branchAddress': _branchAddressCtrl.text.trim().isNotEmpty
            ? _branchAddressCtrl.text.trim()
            : _addressCtrl.text.trim(),
        'branchPhone': _branchPhoneCtrl.text.trim(),
      });
      if (!mounted) return;
      widget.onShopCreated(created);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Shop "${created.shopName}" (${created.tenantId}) provisioned!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Registration failed: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  Widget _field(TextEditingController ctrl, String label, {String? hint, bool obscure = false, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planItems = widget.plans.where((p) => p.isActive).toList();
    final isMobile = MediaQuery.of(context).size.width < 560;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: EdgeInsets.all(isMobile ? 10 : 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640, maxHeight: isMobile ? 640 : 680),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const NptsLogo(height: 26),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Register New Shop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('5-Step SaaS Provisioning', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Expanded(
              child: Stepper(
                type: isMobile ? StepperType.vertical : StepperType.horizontal,
                currentStep: _step,
                onStepTapped: (i) {
                  if (i < _step) setState(() => _step = i);
                },
                controlsBuilder: (ctx, details) => Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      if (_step > 0)
                        OutlinedButton(
                          onPressed: _submitting ? null : () => setState(() => _step--),
                          child: const Text('Back'),
                        ),
                      const Spacer(),
                      if (_step < 4)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                          onPressed: () {
                            final err = _validateCurrentStep();
                            if (err != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(err), backgroundColor: AppColors.danger),
                              );
                              return;
                            }
                            setState(() => _step++);
                          },
                          child: const Text('Next', style: TextStyle(color: Colors.white)),
                        )
                      else
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          onPressed: _submitting ? null : _submit,
                          icon: _submitting
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check, size: 16, color: Colors.white),
                          label: Text(_submitting ? 'Provisioning...' : 'Confirm & Register', style: const TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                ),
                steps: [
                  Step(
                    title: const Text('Business', style: TextStyle(fontSize: 11)),
                    isActive: _step >= 0,
                    content: Column(
                      children: [
                        _field(_shopNameCtrl, 'Business Name *', hint: 'e.g. ABC Supermarket'),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DropdownButtonFormField<String>(
                            initialValue: _shopType,
                            decoration: const InputDecoration(labelText: 'Business Type', isDense: true, border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'Retail', child: Text('Retail Store')),
                              DropdownMenuItem(value: 'Supermarket', child: Text('Supermarket / Hypermarket')),
                              DropdownMenuItem(value: 'Wholesaler', child: Text('Wholesaler / Distributor')),
                              DropdownMenuItem(value: 'Pharmacy', child: Text('Pharmacy & Health')),
                              DropdownMenuItem(value: 'Restaurant', child: Text('Restaurant / Cafe')),
                            ],
                            onChanged: (v) => _shopType = v ?? 'Supermarket',
                          ),
                        ),
                        _field(_bizPhoneCtrl, 'Business Phone', hint: '+92 300 1234567'),
                        _field(_bizEmailCtrl, 'Business Email', hint: 'info@shop.com'),
                        _field(_addressCtrl, 'Address'),
                        Row(
                          children: [
                            Expanded(child: _field(_cityCtrl, 'City')),
                            const SizedBox(width: 10),
                            Expanded(child: _field(_countryCtrl, 'Country')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Step(
                    title: const Text('Owner', style: TextStyle(fontSize: 11)),
                    isActive: _step >= 1,
                    content: Column(
                      children: [
                        _field(_ownerNameCtrl, 'Owner Full Name *', hint: 'e.g. Ali Khan'),
                        _field(_ownerUsernameCtrl, 'Username', hint: 'e.g. alikhan'),
                        _field(_ownerEmailCtrl, 'Owner Email', hint: 'owner@shop.com'),
                        _field(_ownerPhoneCtrl, 'Mobile Number', hint: '+92 300 1234567'),
                        _field(_passwordCtrl, 'Password *', obscure: true),
                        _field(_confirmPassCtrl, 'Confirm Password *', obscure: true),
                      ],
                    ),
                  ),
                  Step(
                    title: const Text('Plan', style: TextStyle(fontSize: 11)),
                    isActive: _step >= 2,
                    content: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DropdownButtonFormField<String>(
                            initialValue: planItems.any((p) => p.slug == _selectedPlanSlug)
                                ? _selectedPlanSlug
                                : (planItems.isNotEmpty ? planItems.first.slug : 'STANDARD'),
                            decoration: const InputDecoration(labelText: 'Subscription Plan', isDense: true, border: OutlineInputBorder()),
                            items: planItems.isNotEmpty
                                ? planItems
                                    .map((p) => DropdownMenuItem(value: p.slug, child: Text('${p.name} (Rs. ${p.monthlyPrice}/mo)')))
                                    .toList()
                                : const [
                                    DropdownMenuItem(value: 'BASIC', child: Text('Basic Retail')),
                                    DropdownMenuItem(value: 'STANDARD', child: Text('Standard Multi-Branch')),
                                    DropdownMenuItem(value: 'PREMIUM', child: Text('Premium Enterprise')),
                                    DropdownMenuItem(value: 'TRIAL', child: Text('Trial Plan')),
                                  ],
                            onChanged: (v) => setState(() => _selectedPlanSlug = v ?? 'STANDARD'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DropdownButtonFormField<String>(
                            initialValue: _billingCycle,
                            decoration: const InputDecoration(labelText: 'Billing Cycle', isDense: true, border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
                              DropdownMenuItem(value: 'YEARLY', child: Text('Yearly')),
                            ],
                            onChanged: (v) => setState(() => _billingCycle = v ?? 'MONTHLY'),
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Start as 30-Day Trial', style: TextStyle(fontSize: 13)),
                          value: _isTrial,
                          onChanged: (v) => setState(() => _isTrial = v),
                        ),
                        Row(
                          children: [
                            Expanded(child: _field(_discountCtrl, 'Discount (Rs.)', type: TextInputType.number)),
                            const SizedBox(width: 10),
                            Expanded(child: _field(_initialPaymentCtrl, 'Initial Payment (Rs.)', type: TextInputType.number)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Step(
                    title: const Text('Branch', style: TextStyle(fontSize: 11)),
                    isActive: _step >= 3,
                    content: Column(
                      children: [
                        _field(_branchNameCtrl, 'Main Branch Name'),
                        _field(_branchCodeCtrl, 'Branch Code'),
                        _field(_branchAddressCtrl, 'Branch Address (optional, defaults to Business Address)'),
                        _field(_branchPhoneCtrl, 'Branch Contact Number'),
                      ],
                    ),
                  ),
                  Step(
                    title: const Text('Review', style: TextStyle(fontSize: 11)),
                    isActive: _step >= 4,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _reviewRow('Business Name', _shopNameCtrl.text),
                        _reviewRow('Business Type', _shopType),
                        _reviewRow('City / Country', '${_cityCtrl.text.isEmpty ? '-' : _cityCtrl.text}, ${_countryCtrl.text}'),
                        _reviewRow('Owner Name', _ownerNameCtrl.text),
                        _reviewRow('Owner Email', _ownerEmailCtrl.text.isEmpty ? _bizEmailCtrl.text : _ownerEmailCtrl.text),
                        _reviewRow('Selected Plan', '$_selectedPlanSlug ($_billingCycle)${_isTrial ? ' • TRIAL' : ''}'),
                        _reviewRow('Main Branch', '${_branchNameCtrl.text} (${_branchCodeCtrl.text})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(val.isEmpty ? '-' : val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
