import 'package:flutter/material.dart';
import '../../../../core/models/registered_shop_item.dart';
import '../../../../core/repositories/shop_repository.dart';
import '../../../../core/theme/app_colors.dart';

class SubscriptionsPage extends StatefulWidget {
  final List<RegisteredShopItem> shops;
  final List<PlanTier> plans;
  final VoidCallback onChanged;

  const SubscriptionsPage({
    super.key,
    required this.shops,
    required this.plans,
    required this.onChanged,
  });

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  List<SubscriptionItem> _subs = [];
  bool _loading = true;
  String _statusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ShopRepository().fetchSubscriptions(status: _statusFilter);
      if (!mounted) return;
      setState(() {
        _subs = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _runAction(SubscriptionItem sub, Map<String, dynamic> payload, String successMsg) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ShopRepository().updateSubscriptionLifecycle(sub.id, payload);
      await _load();
      widget.onChanged();
      messenger.showSnackBar(SnackBar(content: Text(successMsg), backgroundColor: AppColors.success));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Action failed: $e'), backgroundColor: AppColors.danger));
    }
  }

  void _openAssignDialog() {
    if (widget.shops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register a shop first before assigning a subscription.')),
      );
      return;
    }
    String selectedShopId = widget.shops.first.id;
    String selectedPlan = widget.plans.isNotEmpty ? widget.plans.first.slug : 'STANDARD';
    String billingCycle = 'MONTHLY';
    String status = 'ACTIVE';
    final discountCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Assign Subscription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedShopId,
                  decoration: const InputDecoration(labelText: 'Shop', border: OutlineInputBorder()),
                  items: widget.shops.map((s) => DropdownMenuItem(value: s.id, child: Text(s.shopName))).toList(),
                  onChanged: (v) => selectedShopId = v ?? selectedShopId,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedPlan,
                  decoration: const InputDecoration(labelText: 'Plan', border: OutlineInputBorder()),
                  items: widget.plans.map((p) => DropdownMenuItem(value: p.slug, child: Text('${p.name} (Rs. ${p.monthlyPrice}/mo)'))).toList(),
                  onChanged: (v) => selectedPlan = v ?? selectedPlan,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: billingCycle,
                  decoration: const InputDecoration(labelText: 'Billing Cycle', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
                    DropdownMenuItem(value: 'YEARLY', child: Text('Yearly')),
                  ],
                  onChanged: (v) => billingCycle = v ?? 'MONTHLY',
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Initial Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                    DropdownMenuItem(value: 'TRIAL', child: Text('Trial')),
                    DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                  ],
                  onChanged: (v) => status = v ?? 'ACTIVE',
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: discountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Discount (Rs.)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ShopRepository().assignSubscription({
                  'shopId': selectedShopId,
                  'planSlug': selectedPlan,
                  'billingCycle': billingCycle,
                  'status': status,
                  'discount': int.tryParse(discountCtrl.text.trim()) ?? 0,
                });
                navigator.pop();
                await _load();
                widget.onChanged();
                messenger.showSnackBar(const SnackBar(content: Text('Subscription assigned!'), backgroundColor: AppColors.success));
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.danger));
              }
            },
            child: const Text('Assign', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openChangePlanOrDiscount(SubscriptionItem sub) {
    String nextPlan = sub.planSlug;
    String cycle = sub.billingCycle;
    final discountCtrl = TextEditingController(text: '${sub.discount}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update ${sub.shopName} Subscription', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: widget.plans.any((p) => p.slug == nextPlan) ? nextPlan : (widget.plans.isNotEmpty ? widget.plans.first.slug : 'STANDARD'),
              decoration: const InputDecoration(labelText: 'Plan', border: OutlineInputBorder()),
              items: widget.plans.map((p) => DropdownMenuItem(value: p.slug, child: Text(p.name))).toList(),
              onChanged: (v) => nextPlan = v ?? nextPlan,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: cycle,
              decoration: const InputDecoration(labelText: 'Billing Cycle', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
                DropdownMenuItem(value: 'YEARLY', child: Text('Yearly')),
              ],
              onChanged: (v) => cycle = v ?? cycle,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: discountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Discount (Rs.)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () async {
              Navigator.pop(ctx);
              await _runAction(sub, {'action': 'CHANGE_PLAN', 'planSlug': nextPlan}, 'Plan updated to $nextPlan');
              await _runAction(sub, {'action': 'CHANGE_CYCLE', 'billingCycle': cycle}, 'Billing cycle updated');
              await _runAction(sub, {'action': 'APPLY_DISCOUNT', 'discount': int.tryParse(discountCtrl.text.trim()) ?? 0}, 'Discount applied');
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return AppColors.success;
      case 'TRIAL':
        return AppColors.primary;
      case 'PENDING':
        return Colors.orange;
      default:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subscriptions Lifecycle Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Assign, renew, extend, upgrade/downgrade, or suspend tenant subscriptions.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                onPressed: _openAssignDialog,
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Assign Subscription', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['ALL', 'ACTIVE', 'TRIAL', 'PENDING', 'EXPIRED', 'SUSPENDED', 'CANCELLED'].map((st) {
              final selected = _statusFilter == st;
              return ChoiceChip(
                label: Text(st, style: const TextStyle(fontSize: 11)),
                selected: selected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold),
                onSelected: (v) {
                  if (v) {
                    setState(() => _statusFilter = st);
                    _load();
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
          else if (_subs.isEmpty)
            const Card(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No subscriptions found for this filter.', style: TextStyle(color: AppColors.textSecondary))),
              ),
            )
          else
            ..._subs.map((sub) {
              final color = _statusColor(sub.status);
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${sub.shopName}${sub.tenantId.isNotEmpty ? ' (${sub.tenantId})' : ''}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('${sub.planName} • ${sub.billingCycle} • Rs. ${sub.amount} (Discount: Rs. ${sub.discount})',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text('Start: ${sub.startDate}  →  Expires: ${sub.expiresAt}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                            child: Text(sub.status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                      const Divider(height: 18, color: AppColors.borderLight),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          OutlinedButton(
                            onPressed: () => _openChangePlanOrDiscount(sub),
                            child: const Text('Upgrade / Discount', style: TextStyle(fontSize: 11)),
                          ),
                          OutlinedButton(
                            onPressed: () => _runAction(sub, {'action': 'RENEW'}, '${sub.shopName} renewed!'),
                            child: const Text('Renew', style: TextStyle(fontSize: 11)),
                          ),
                          OutlinedButton(
                            onPressed: () => _runAction(sub, {'action': 'EXTEND', 'extendDays': 30}, 'Extended by 30 days'),
                            child: const Text('Extend +30d', style: TextStyle(fontSize: 11)),
                          ),
                          OutlinedButton(
                            onPressed: () => _runAction(
                              sub,
                              {'action': sub.status == 'SUSPENDED' ? 'ACTIVATE' : 'SUSPEND'},
                              sub.status == 'SUSPENDED' ? 'Activated' : 'Suspended',
                            ),
                            child: Text(sub.status == 'SUSPENDED' ? 'Activate' : 'Suspend', style: const TextStyle(fontSize: 11)),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                            onPressed: () => _runAction(sub, {'action': 'CANCEL'}, 'Subscription cancelled'),
                            child: const Text('Cancel', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
