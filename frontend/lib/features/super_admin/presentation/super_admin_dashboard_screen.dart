import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/npts_logo.dart';

import '../../../core/models/registered_shop_item.dart';
import '../../../core/repositories/shop_repository.dart';
import 'widgets/register_shop_wizard.dart';
import 'pages/subscriptions_page.dart';
import 'pages/payments_billing_page.dart';
import 'pages/platform_management_pages.dart';
class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  // Controllers for shop registration form
  late final TextEditingController nameCtrl;
  late final TextEditingController ownerCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController phoneCtrl;
  // Selected values for dropdowns
  String selectedPlan = 'Standard';
  String selectedShopType = 'Retail';
  // Existing state variables
  int _selectedNavIndex = 0;
  String _shopSearchQuery = '';
  String _selectedStatusFilter = 'All';
  String _selectedPlanFilter = 'All';
  String _sortBy = 'Newest';
  String _selectedTimeframe = 'This Month';

  List<RegisteredShopItem> _shops = [];
  List<PlanTier> _plans = [];
  List<PaymentReminderItem> _reminders = [];
  List<SubscriptionItem> _subscriptions = [];
  Map<String, dynamic> _revenueReport = {};
  bool _isLoadingShops = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    nameCtrl = TextEditingController();
    ownerCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    _loadShops();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    nameCtrl.dispose();
    ownerCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadShops() async {
    setState(() {
      _isLoadingShops = true;
      _loadError = null;
    });
    try {
      final repo = ShopRepository();
      final fetched = await repo.fetchAllShops();
      final fetchedPlans = await repo.fetchPlans();
      final fetchedReminders = await repo.fetchReminders();
      final fetchedSubs = await repo.fetchSubscriptions();
      final fetchedReport = await repo.fetchRevenueReports();
      if (!mounted) return;
      setState(() {
        _shops = fetched;
        _plans = fetchedPlans;
        _reminders = fetchedReminders;
        _subscriptions = fetchedSubs;
        _revenueReport = fetchedReport;
        _isLoadingShops = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoadingShops = false;
      });
    }
  }

  int get _totalShopsCount => _shops.length;
  int get _activeShopsCount => _shops.where((s) => s.status == 'Active').length;

  int _planMonthlyPrice(String plan) {
    final upper = plan.toUpperCase();
    for (final p in _plans) {
      if (p.slug == upper || p.name.toUpperCase().startsWith(upper)) {
        return p.monthlyPrice;
      }
    }
    switch (plan.toLowerCase()) {
      case 'basic':
        return 2500;
      case 'standard':
        return 5000;
      case 'premium':
        return 10000;
      default:
        return 0;
    }
  }

  String _formatCurrency(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return 'Rs. $buf';
  }

  int get _monthlyRevenue => _shops
      .where((s) => s.status == 'Active')
      .fold<int>(0, (sum, s) => sum + _planMonthlyPrice(s.plan));

  List<RegisteredShopItem> get _filteredShops {
    final list = _shops.where((s) {
      final q = _shopSearchQuery.toLowerCase();
      final matchesQuery = s.shopName.toLowerCase().contains(q) ||
          s.owner.toLowerCase().contains(q) ||
          s.plan.toLowerCase().contains(q) ||
          s.tenantId.toLowerCase().contains(q);
      final matchesStatus = _selectedStatusFilter == 'All' || s.status == _selectedStatusFilter;
      final matchesPlan = _selectedPlanFilter == 'All' || s.plan.toLowerCase() == _selectedPlanFilter.toLowerCase();
      return matchesQuery && matchesStatus && matchesPlan;
    }).toList();

    if (_sortBy == 'Name A-Z') {
      list.sort((a, b) => a.shopName.toLowerCase().compareTo(b.shopName.toLowerCase()));
    } else if (_sortBy == 'Status') {
      list.sort((a, b) => a.status.compareTo(b.status));
    }
    return list;
  }

  Future<void> _toggleShopStatus(RegisteredShopItem shop) async {
    final nextActive = shop.status != 'Active';
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await ShopRepository().toggleShopStatus(shop.id, nextActive);
      if (!mounted) return;
      setState(() {
        shop.status = updated.status;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text('${shop.shopName} status changed to ${shop.status}'),
          backgroundColor: shop.status == 'Active' ? AppColors.success : AppColors.danger,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showShopDetailsDialog(RegisteredShopItem shop) {
    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder<ShopDetailsBundle>(
        future: ShopRepository().fetchShopDetails(shop.id),
        builder: (ctx, snapshot) {
          final details = snapshot.data;
          final current = details?.shop ?? shop;
          return DefaultTabController(
            length: 4,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: const Icon(Icons.storefront, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(current.shopName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '${current.shopType}${current.tenantId.isNotEmpty ? ' • ${current.tenantId}' : ''}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                height: 310,
                child: Column(
                  children: [
                    const TabBar(
                      isScrollable: true,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      tabs: [
                        Tab(text: 'Overview'),
                        Tab(text: 'Branches'),
                        Tab(text: 'Users'),
                        Tab(text: 'Reminders'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildDetailRow('Owner', current.owner),
                                _buildDetailRow('Email', current.email),
                                _buildDetailRow('Phone', current.phone),
                                _buildDetailRow('Location', current.city.isNotEmpty ? '${current.city}, ${current.country}' : current.country),
                                _buildDetailRow('Plan', '${current.plan} (${current.billingCycle})'),
                                _buildDetailRow('Quotas', '${current.branches} Branches • ${current.maxUsers} Users • ${current.maxPosTerminals} POS'),
                                _buildDetailRow('Joined / Expires', '${current.joined} → ${current.expiresAt}'),
                                _buildDetailRow('Current Status', current.status, isStatus: true),
                              ],
                            ),
                          ),
                          if (snapshot.connectionState == ConnectionState.waiting)
                            const Center(child: CircularProgressIndicator())
                          else if (details == null || details.branches.isEmpty)
                            const Center(child: Text('No branches found.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)))
                          else
                            ListView.builder(
                              itemCount: details.branches.length,
                              itemBuilder: (_, i) {
                                final b = details.branches[i];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.store_mall_directory_outlined, size: 18),
                                  title: Text('${b['name'] ?? 'Branch'} (${b['code'] ?? ''})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  subtitle: Text('${b['city'] ?? ''} ${b['address'] ?? ''}'.trim(), style: const TextStyle(fontSize: 11)),
                                  trailing: Text((b['isMainBranch'] == true) ? 'Main' : 'Branch', style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
                                );
                              },
                            ),
                          if (snapshot.connectionState == ConnectionState.waiting)
                            const Center(child: CircularProgressIndicator())
                          else if (details == null || details.users.isEmpty)
                            const Center(child: Text('No assigned shop users found.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)))
                          else
                            ListView.builder(
                              itemCount: details.users.length,
                              itemBuilder: (_, i) {
                                final ur = details.users[i];
                                final u = ur['userId'] as Map<String, dynamic>?;
                                final r = ur['roleId'] as Map<String, dynamic>?;
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.person_outline, size: 18),
                                  title: Text('${u?['fullName'] ?? 'User'}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  subtitle: Text('${u?['email'] ?? ''}', style: const TextStyle(fontSize: 11)),
                                  trailing: Text('${r?['name'] ?? ''}', style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                                );
                              },
                            ),
                          if (snapshot.connectionState == ConnectionState.waiting)
                            const Center(child: CircularProgressIndicator())
                          else if (details == null || details.reminders.isEmpty)
                            const Center(child: Text('No reminders sent to this shop.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)))
                          else
                            ListView.builder(
                              itemCount: details.reminders.length,
                              itemBuilder: (_, i) {
                                final r = details.reminders[i];
                                return ListTile(
                                  dense: true,
                                  leading: Icon(r.channel == 'EMAIL' ? Icons.email_outlined : Icons.sms_outlined, size: 18),
                                  title: Text('${r.channel} → ${r.recipient}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  subtitle: Text(r.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                                  trailing: Text(r.sentAt, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openEditShopDialog(current);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 15),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openChangeShopPlanDialog(current);
                      },
                      icon: const Icon(Icons.card_membership_outlined, size: 15),
                      label: const Text('Plan'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _extendShopSubscription(current, 30);
                      },
                      icon: const Icon(Icons.update, size: 15),
                      label: const Text('+30 Days'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openResetPasswordDialog(current);
                      },
                      icon: const Icon(Icons.lock_reset, size: 15),
                      label: const Text('Reset Pass'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(ctx);
                        try {
                          final res = await ShopRepository().impersonateShopAdmin(current.id);
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Audited impersonation started for ${res['shopName']} (${res['tenantId']})'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(SnackBar(content: Text('Impersonation failed: $e'), backgroundColor: AppColors.danger));
                        }
                      },
                      icon: const Icon(Icons.login, size: 15),
                      label: const Text('Login as Admin'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openSendReminderDialog(current);
                      },
                      icon: const Icon(Icons.notifications_active_outlined, size: 15),
                      label: const Text('Remind'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _toggleShopStatus(current);
                        Navigator.pop(ctx);
                      },
                      child: Text(current.status == 'Active' ? 'Suspend' : 'Activate'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _confirmDeleteShop(current);
                      },
                      child: const Text('Delete'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Close', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _extendShopSubscription(RegisteredShopItem shop, int days) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await ShopRepository().updateShopPlan(shop.id, shop.plan, extendDays: days);
      if (!mounted) return;
      setState(() {
        final idx = _shops.indexWhere((s) => s.id == shop.id);
        if (idx != -1) _shops[idx] = updated;
      });
      messenger.showSnackBar(
        SnackBar(content: Text('Extended ${shop.shopName} by $days days (expires ${updated.expiresAt}).'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to extend: $e'), backgroundColor: AppColors.danger));
    }
  }

  void _openEditShopDialog(RegisteredShopItem shop) {
    final nameCtrl = TextEditingController(text: shop.shopName);
    final ownerCtrl = TextEditingController(text: shop.owner);
    final emailCtrl = TextEditingController(text: shop.email);
    final phoneCtrl = TextEditingController(text: shop.phone);
    final cityCtrl = TextEditingController(text: shop.city);
    final addrCtrl = TextEditingController(text: shop.address);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Shop - ${shop.shopName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Business Name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: ownerCtrl, decoration: const InputDecoration(labelText: 'Owner Name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),
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
                final updated = await ShopRepository().updateShop(shop.id, {
                  'shopName': nameCtrl.text.trim(),
                  'owner': ownerCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'city': cityCtrl.text.trim(),
                  'address': addrCtrl.text.trim(),
                });
                if (!mounted) return;
                setState(() {
                  final idx = _shops.indexWhere((s) => s.id == shop.id);
                  if (idx != -1) _shops[idx] = updated;
                });
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('${updated.shopName} updated!'), backgroundColor: AppColors.success),
                );
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Failed to update: $e'), backgroundColor: AppColors.danger));
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openResetPasswordDialog(RegisteredShopItem shop) {
    final passCtrl = TextEditingController(text: 'Pass@123');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reset Owner Password (${shop.shopName})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New Password (min 6 chars)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ShopRepository().resetOwnerPassword(shop.id, passCtrl.text);
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Owner password reset successfully!'), backgroundColor: AppColors.success),
                );
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Reset failed: $e'), backgroundColor: AppColors.danger));
              }
            },
            child: const Text('Reset Password', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteShop(RegisteredShopItem shop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Shop?', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to permanently delete "${shop.shopName}" and its branches? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ShopRepository().deleteShop(shop.id);
                if (!mounted) return;
                setState(() {
                  _shops.removeWhere((s) => s.id == shop.id);
                });
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('${shop.shopName} deleted.'), backgroundColor: AppColors.danger),
                );
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppColors.danger));
              }
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openChangeShopPlanDialog(RegisteredShopItem shop) {
    String nextPlan = shop.plan;
    final branchesCtrl = TextEditingController(text: '${shop.branches}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Change Plan - ${shop.shopName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: ['Trial', 'Basic', 'Standard', 'Premium'].contains(nextPlan) ? nextPlan : 'Standard',
              decoration: const InputDecoration(labelText: 'Subscription Plan', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Trial', child: Text('Trial')),
                DropdownMenuItem(value: 'Basic', child: Text('Basic')),
                DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                DropdownMenuItem(value: 'Premium', child: Text('Premium')),
              ],
              onChanged: (v) => nextPlan = v ?? shop.plan,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: branchesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Max Branches', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final updated = await ShopRepository().updateShopPlan(
                  shop.id,
                  nextPlan,
                  branches: int.tryParse(branchesCtrl.text.trim()),
                );
                if (!mounted) return;
                setState(() {
                  final idx = _shops.indexWhere((s) => s.id == shop.id);
                  if (idx != -1) _shops[idx] = updated;
                });
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('${shop.shopName} plan updated to ${updated.plan}!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to update plan: $e'), backgroundColor: AppColors.danger),
                );
              }
            },
            child: const Text('Save Plan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openSendReminderDialog(RegisteredShopItem shop) {
    String channel = 'EMAIL';
    final recipientCtrl = TextEditingController(text: shop.email.isNotEmpty ? shop.email : shop.phone);
    final subjectCtrl = TextEditingController(text: 'Payment Reminder - ${shop.shopName}');
    final priceText = _formatCurrency(_planMonthlyPrice(shop.plan));
    final messageCtrl = TextEditingController(
      text: 'Dear ${shop.owner}, your ${shop.plan} plan payment ($priceText) for ${shop.shopName} is due. Please clear your payment to avoid service interruption.',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: AppColors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Send Payment Reminder (${shop.shopName})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: channel,
                    decoration: const InputDecoration(labelText: 'Channel', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'EMAIL', child: Text('Email')),
                      DropdownMenuItem(value: 'SMS', child: Text('SMS')),
                      DropdownMenuItem(value: 'WHATSAPP', child: Text('WhatsApp')),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        channel = val ?? 'EMAIL';
                        recipientCtrl.text = channel == 'EMAIL' ? shop.email : shop.phone;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: recipientCtrl,
                    decoration: InputDecoration(
                      labelText: channel == 'EMAIL' ? 'Recipient Email' : 'Recipient Phone',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subjectCtrl,
                    decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.receipt_long, color: AppColors.secondary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'NPTS Payment Reminder • ${shop.shopName}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextField(
                            controller: messageCtrl,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              labelText: 'Template Message',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              icon: const Icon(Icons.send, size: 16, color: Colors.white),
              label: const Text('Send Reminder', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final saved = await ShopRepository().sendPaymentReminder(
                    shopId: shop.id,
                    channel: channel,
                    recipient: recipientCtrl.text.trim(),
                    subject: subjectCtrl.text.trim(),
                    message: messageCtrl.text.trim(),
                  );
                  if (!mounted) return;
                  setState(() {
                    _reminders.insert(0, saved);
                  });
                  navigator.pop();
                  if (saved.whatsappUrl.isNotEmpty) {
                    final uri = Uri.parse(saved.whatsappUrl);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                  final note = saved.deliveryNote.isNotEmpty ? ' (${saved.deliveryNote})' : '';
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('$channel reminder processed for ${saved.recipient}$note'),
                      backgroundColor: saved.deliveryNote.isNotEmpty ? Colors.orange : AppColors.success,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to send reminder: $e'), backgroundColor: AppColors.danger),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openEditPlanDialog(PlanTier? plan) {
    final isCreate = plan == null;
    final slugCtrl = TextEditingController(text: plan?.slug ?? '');
    final nameCtrl = TextEditingController(text: plan?.name ?? '');
    final priceCtrl = TextEditingController(text: '${plan?.monthlyPrice ?? 2500}');
    final yearlyCtrl = TextEditingController(text: '${plan?.yearlyPrice ?? 25000}');
    final branchesCtrl = TextEditingController(text: '${plan?.maxBranches ?? 1}');
    final usersCtrl = TextEditingController(text: '${plan?.maxUsers ?? 3}');
    final posCtrl = TextEditingController(text: '${plan?.maxPosTerminals ?? 1}');
    final prodCtrl = TextEditingController(text: '${plan?.maxProducts ?? 1000}');
    final storageCtrl = TextEditingController(text: '${plan?.storageLimitMb ?? 500}');
    final trialCtrl = TextEditingController(text: '${plan?.trialDays ?? 0}');
    final descCtrl = TextEditingController(text: plan?.description ?? '');
    bool dedicatedSupport = plan?.dedicatedSupport ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isCreate ? 'Create Subscription Plan' : 'Edit ${plan.slug} Plan Price & Quota', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCreate) ...[
                    TextField(controller: slugCtrl, decoration: const InputDecoration(labelText: 'Plan Code (e.g. GOLD)', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                  ],
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Plan Title', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly Price (Rs.)', border: OutlineInputBorder()))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: yearlyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Yearly Price (Rs.)', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: branchesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Branches', border: OutlineInputBorder()))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: usersCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Users', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: posCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max POS Terminals', border: OutlineInputBorder()))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: prodCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Products', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: storageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Storage (MB)', border: OutlineInputBorder()))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: trialCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Trial Days', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description / Quota Summary', border: OutlineInputBorder())),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dedicated Support Included', style: TextStyle(fontSize: 13)),
                    value: dedicatedSupport,
                    onChanged: (v) => setDialogState(() => dedicatedSupport = v),
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
                  if (isCreate) {
                    final created = await ShopRepository().createPlan({
                      'slug': slugCtrl.text.trim(),
                      'name': nameCtrl.text.trim(),
                      'monthlyPrice': int.tryParse(priceCtrl.text.trim()) ?? 0,
                      'yearlyPrice': int.tryParse(yearlyCtrl.text.trim()) ?? 0,
                      'maxBranches': int.tryParse(branchesCtrl.text.trim()) ?? 1,
                      'maxUsers': int.tryParse(usersCtrl.text.trim()) ?? 3,
                      'maxPosTerminals': int.tryParse(posCtrl.text.trim()) ?? 1,
                      'maxProducts': int.tryParse(prodCtrl.text.trim()) ?? 1000,
                      'storageLimitMb': int.tryParse(storageCtrl.text.trim()) ?? 500,
                      'trialDays': int.tryParse(trialCtrl.text.trim()) ?? 0,
                      'dedicatedSupport': dedicatedSupport,
                      'description': descCtrl.text.trim(),
                    });
                    if (!mounted) return;
                    setState(() => _plans.add(created));
                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(content: Text('Plan "${created.name}" created!'), backgroundColor: AppColors.success),
                    );
                  } else {
                    final updated = await ShopRepository().updatePlan(
                      plan.slug,
                      name: nameCtrl.text.trim(),
                      monthlyPrice: int.tryParse(priceCtrl.text.trim()) ?? plan.monthlyPrice,
                      yearlyPrice: int.tryParse(yearlyCtrl.text.trim()) ?? plan.yearlyPrice,
                      maxBranches: int.tryParse(branchesCtrl.text.trim()) ?? plan.maxBranches,
                      maxUsers: int.tryParse(usersCtrl.text.trim()) ?? plan.maxUsers,
                      maxPosTerminals: int.tryParse(posCtrl.text.trim()) ?? plan.maxPosTerminals,
                      maxProducts: int.tryParse(prodCtrl.text.trim()) ?? plan.maxProducts,
                      storageLimitMb: int.tryParse(storageCtrl.text.trim()) ?? plan.storageLimitMb,
                      trialDays: int.tryParse(trialCtrl.text.trim()) ?? plan.trialDays,
                      dedicatedSupport: dedicatedSupport,
                      description: descCtrl.text.trim(),
                    );
                    if (!mounted) return;
                    setState(() {
                      final idx = _plans.indexWhere((p) => p.slug == plan.slug);
                      if (idx != -1) _plans[idx] = updated;
                    });
                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('${updated.name} updated (${_formatCurrency(updated.monthlyPrice)}/mo)!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to save plan: $e'), backgroundColor: AppColors.danger),
                  );
                }
              },
              child: Text(isCreate ? 'Create Plan' : 'Save Changes', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          if (!isStatus)
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: value == 'Active' ? AppColors.successLight : AppColors.dangerLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: value == 'Active' ? AppColors.success : AppColors.danger,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;
        final isMobile = constraints.maxWidth < 650;

        final sidebarContent = Container(
          width: 250,
          color: const Color(0xFF101C30),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF1E2F4A))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NptsLogo(height: 38, isDark: true),
                    const SizedBox(height: 6),
                    const Text(
                      'Platform SaaS Control',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    _buildSidebarSectionHeader('OVERVIEW'),
                    _buildSidebarItem(0, 'Dashboard', Icons.dashboard_outlined, isDesktop: isDesktop),
                    _buildSidebarSectionHeader('TENANT MANAGEMENT'),
                    _buildSidebarItem(1, 'Shops & Tenants', Icons.storefront_outlined, isDesktop: isDesktop),
                    _buildSidebarItem(10, 'Branches Overview', Icons.store_mall_directory_outlined, isDesktop: isDesktop),
                    _buildSidebarItem(11, 'Tenant Users', Icons.group_outlined, isDesktop: isDesktop),
                    _buildSidebarSectionHeader('SUBSCRIPTIONS & REVENUE'),
                    _buildSidebarItem(2, 'Subscriptions', Icons.autorenew, isDesktop: isDesktop),
                    _buildSidebarItem(4, 'Plans & Pricing', Icons.monetization_on_outlined, isDesktop: isDesktop),
                    _buildSidebarItem(6, 'Payments & Billing', Icons.receipt_long_outlined, isDesktop: isDesktop),
                    _buildSidebarItem(15, 'Coupons & Discounts', Icons.confirmation_number_outlined, isDesktop: isDesktop),
                    _buildSidebarSectionHeader('PLATFORM MANAGEMENT'),
                    _buildSidebarItem(3, 'Platform Users & Roles', Icons.admin_panel_settings_outlined, isDesktop: isDesktop),
                    _buildSidebarItem(7, 'Support Tickets', Icons.support_agent_outlined, isDesktop: isDesktop),
                    _buildSidebarItem(12, 'Analytics & Reports', Icons.analytics_outlined, isDesktop: isDesktop),
                    _buildSidebarItem(13, 'Leads & Sales CRM', Icons.handshake_outlined, isDesktop: isDesktop),
                    _buildSidebarItem(9, 'Audit Logs', Icons.history_outlined, isDesktop: isDesktop),
                    _buildSidebarItem(8, 'Notifications', Icons.notifications_outlined, isDesktop: isDesktop),
                    _buildSidebarSectionHeader('SYSTEM'),
                    _buildSidebarItem(5, 'System Settings', Icons.settings_outlined, isDesktop: isDesktop),
                    _buildSidebarItem(16, 'Backups & Maintenance', Icons.storage_outlined, isDesktop: isDesktop),
                    const Divider(color: Color(0xFF1E2F4A), height: 24),
                    _buildSidebarItem(14, 'Super Admin Profile', Icons.account_circle_outlined, isDesktop: isDesktop),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0B1424),
                  border: Border(top: BorderSide(color: Color(0xFF1E2F4A))),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.secondary,
                      child: Text('SA', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Super Admin',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Platform Owner',
                            style: TextStyle(color: AppColors.secondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, size: 18, color: AppColors.textMuted),
                      onPressed: () => AuthService().logout(),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        // Content Widget based on selected tab
        Widget contentBody;
        switch (_selectedNavIndex) {
          case 1:
            contentBody = _buildShopsPage(isMobile);
            break;
          case 2:
            contentBody = SubscriptionsPage(
              shops: _shops,
              plans: _plans,
              onChanged: _loadShops,
            );
            break;
          case 3:
            contentBody = const PlatformUsersPage();
            break;
          case 4:
            contentBody = _buildPlansPricingPage(isMobile);
            break;
          case 5:
            contentBody = const SystemSettingsAndBackupPage();
            break;
          case 6:
            contentBody = PaymentsBillingPage(shops: _shops, plans: _plans);
            break;
          case 7:
            contentBody = SupportTicketsPage(shops: _shops);
            break;
          case 8:
            contentBody = const NotificationsPage();
            break;
          case 9:
            contentBody = const AuditLogsPage();
            break;
          case 10:
            contentBody = const BranchesOverviewPage();
            break;
          case 11:
            contentBody = const TenantUsersOverviewPage();
            break;
          case 12:
            contentBody = const AnalyticsReportsPage();
            break;
          case 13:
            contentBody = const LeadsCrmPage();
            break;
          case 14:
            contentBody = const SuperAdminProfilePage();
            break;
          case 15:
            contentBody = PaymentsBillingPage(shops: _shops, plans: _plans, initialTabIndex: 1);
            break;
          case 16:
            contentBody = const BackupsMaintenancePage();
            break;
          case 0:
          default:
            contentBody = _buildDashboardOverviewPage(isMobile);
            break;
        }

        // MOBILE APP LAYOUT (With Native App Bar & Bottom Navigation Bar)
        if (!isDesktop) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              centerTitle: false,
              titleSpacing: 0,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.primary),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const NptsLogo(height: 22),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SUPER ADMIN',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_business, color: AppColors.secondary, size: 22),
                  tooltip: 'Register Shop',
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: () => _openRegisterShopDialog(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedNavIndex = 3),
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.secondary,
                      child: Text('SA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
            drawer: Drawer(child: sidebarContent),
            body: contentBody,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedNavIndex == 6
                  ? 3
                  : (_selectedNavIndex == 5
                      ? 4
                      : (_selectedNavIndex > 2 ? 0 : _selectedNavIndex)),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.secondary,
              unselectedItemColor: AppColors.textSecondary,
              selectedFontSize: 11,
              unselectedFontSize: 10,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
              onTap: (idx) {
                const map = [0, 1, 2, 6, 5];
                setState(() => _selectedNavIndex = map[idx]);
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Overview'),
                BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Shops'),
                BottomNavigationBarItem(icon: Icon(Icons.card_membership_outlined), activeIcon: Icon(Icons.card_membership), label: 'Subs'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Billing'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
            floatingActionButton: _selectedNavIndex == 1
                ? FloatingActionButton.extended(
                    onPressed: () => _openRegisterShopDialog(context),
                    backgroundColor: AppColors.secondary,
                    icon: const Icon(Icons.add_business, color: Colors.white),
                    label: const Text('New Shop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                : null,
          );
        }

        // DESKTOP LAYOUT (Docked Sidebar + Global Header)
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [
              sidebarContent,
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                _getTitleForNavIndex(_selectedNavIndex),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'PLATFORM SUPER ADMIN',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _openRegisterShopDialog(context),
                            icon: const Icon(Icons.add_business, size: 18),
                            label: const Text('Register New Shop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: contentBody),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTitleForNavIndex(int idx) {
    switch (idx) {
      case 1: return 'Shops & Tenants Management';
      case 2: return 'Subscriptions & Quotas';
      case 3: return 'Platform Users & Roles';
      case 4: return 'Subscription Plans & Pricing';
      case 5: return 'System Settings & Backups';
      case 6: return 'Payments, Billing & Coupons';
      case 7: return 'Support & Ticket Management';
      case 8: return 'Notifications & Expiry Alerts';
      case 9: return 'Audit Logs & Security';
      case 10: return 'Branches Overview';
      case 11: return 'Tenant Users Overview';
      case 12: return 'Analytics & Usage Reports';
      case 13: return 'Leads & Sales CRM';
      case 14: return 'Super Admin Profile';
      case 15: return 'Coupons & Discounts';
      case 16: return 'Backups & Maintenance';
      default: return 'SaaS Platform Overview & Tenant Provisioning';
    }
  }

  Widget _buildSidebarSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index, String title, IconData icon, {bool isDesktop = true}) {
    final isSelected = _selectedNavIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        onTap: () {
          setState(() => _selectedNavIndex = index);
          if (!isDesktop && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 19, color: isSelected ? Colors.white : const Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- PAGE 0: DASHBOARD OVERVIEW ---
  int get _trialShopsCount => _shops.where((s) => s.subscriptionStatus == 'TRIAL' || s.plan.toLowerCase() == 'trial').length;
  int get _suspendedShopsCount => _shops.where((s) => s.subscriptionStatus == 'SUSPENDED' || s.status == 'Inactive').length;
  int get _expiredShopsCount => _shops.where((s) => s.subscriptionStatus == 'EXPIRED').length;
  int get _activeSubscriptionsCount => _subscriptions.where((s) => s.status == 'ACTIVE').length;
  int get _paidSubsCount => _subscriptions.where((s) => s.paymentStatus == 'PAID').length;
  int get _unpaidSubsCount => _subscriptions.where((s) => s.paymentStatus != 'PAID').length;

  Widget _buildDashboardOverviewPage(bool isMobile) {
    final monthlyCollected = (_revenueReport['monthlyCollected'] as num?)?.toInt() ?? 0;
    final yearlyCollected = (_revenueReport['yearlyCollected'] as num?)?.toInt() ?? 0;
    final pendingDue = (_revenueReport['pendingDue'] as num?)?.toInt() ?? 0;
    final displayMonthlyRev = monthlyCollected > 0 ? monthlyCollected : _monthlyRevenue;
    final displayYearlyRev = yearlyCollected > 0 ? yearlyCollected : (_monthlyRevenue * 12);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12.0 : 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions Bar (horizontal scroll on mobile, wrap on desktop)
          if (isMobile)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                    onPressed: () => _openRegisterShopDialog(context),
                    icon: const Icon(Icons.add_business, size: 15, color: Colors.white),
                    label: const Text('Register Shop', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _openEditPlanDialog(null),
                    icon: const Icon(Icons.add_card, size: 15),
                    label: const Text('Create Plan', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _selectedNavIndex = 6),
                    icon: const Icon(Icons.receipt_long_outlined, size: 15),
                    label: const Text('Payments', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _selectedNavIndex = 2),
                    icon: const Icon(Icons.event_available_outlined, size: 15),
                    label: const Text('Subscriptions', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _selectedNavIndex = 3),
                    icon: const Icon(Icons.people_outline, size: 15),
                    label: const Text('Users', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                  onPressed: () => _openRegisterShopDialog(context),
                  icon: const Icon(Icons.add_business, size: 15, color: Colors.white),
                  label: const Text('Register New Shop', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openEditPlanDialog(null),
                  icon: const Icon(Icons.add_card, size: 15),
                  label: const Text('Create Plan', style: TextStyle(fontSize: 12)),
                ),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _selectedNavIndex = 6),
                  icon: const Icon(Icons.receipt_long_outlined, size: 15),
                  label: const Text('View Payments', style: TextStyle(fontSize: 12)),
                ),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _selectedNavIndex = 2),
                  icon: const Icon(Icons.event_available_outlined, size: 15),
                  label: const Text('Subscriptions', style: TextStyle(fontSize: 12)),
                ),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _selectedNavIndex = 3),
                  icon: const Icon(Icons.people_outline, size: 15),
                  label: const Text('Platform Users', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Timeframe filter pills
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              const Text('Platform Statistics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['Today', 'This Month', 'This Year'].map((t) {
                  final isSelected = _selectedTimeframe == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedTimeframe = t);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // All Platform KPI Cards (2 cols on mobile, 3 on tablet, 5 on desktop)
          LayoutBuilder(
            builder: (ctx, kpiConstraints) {
              final width = kpiConstraints.maxWidth;
              int crossAxisCount = width < 650 ? 2 : (width < 1150 ? 3 : 5);
              double childAspectRatio = width < 400 ? 1.45 : (width < 650 ? 1.65 : (width < 1150 ? 2.0 : 1.85));

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildKpiCard('Total Shops', '$_totalShopsCount', Icons.store_outlined, AppColors.primary),
                  _buildKpiCard('Active Shops', '$_activeShopsCount', Icons.check_circle_outline, AppColors.success),
                  _buildKpiCard('Trial Shops', '$_trialShopsCount', Icons.hourglass_bottom_outlined, Colors.blue),
                  _buildKpiCard('Suspended Shops', '$_suspendedShopsCount', Icons.pause_circle_outline, AppColors.danger),
                  _buildKpiCard('Expired Shops', '$_expiredShopsCount', Icons.cancel_outlined, Colors.deepOrange),
                  _buildKpiCard('Active Subscriptions', '$_activeSubscriptionsCount', Icons.card_membership_outlined, AppColors.secondary),
                  _buildKpiCard('Monthly Revenue', _formatCurrency(displayMonthlyRev), Icons.payments_outlined, const Color(0xFF7C3AED)),
                  _buildKpiCard('Yearly Revenue', _formatCurrency(displayYearlyRev), Icons.trending_up, Colors.teal),
                  _buildKpiCard('Pending Payments', _formatCurrency(pendingDue), Icons.pending_actions_outlined, Colors.amber.shade800),
                  _buildKpiCard('Paid vs Unpaid', '$_paidSubsCount / $_unpaidSubsCount', Icons.pie_chart_outline, Colors.indigo),
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          // Charts
          LayoutBuilder(
            builder: (ctx, chartConstraints) {
              if (chartConstraints.maxWidth < 780) {
                return Column(
                  children: [
                    _buildShopGrowthCard(),
                    const SizedBox(height: 16),
                    _buildSubscriptionPlansCard(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildShopGrowthCard()),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildSubscriptionPlansCard()),
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          // Recent Shops & Payments
          LayoutBuilder(
            builder: (ctx, rowConstraints) {
              if (rowConstraints.maxWidth < 780) {
                return Column(
                  children: [
                    _buildRecentShopsTableCard(isMobile),
                    const SizedBox(height: 16),
                    _buildRecentPaymentsCard(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildRecentShopsTableCard(isMobile)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildRecentPaymentsCard()),
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          // Upcoming Expirations & Shop Activity Overview
          LayoutBuilder(
            builder: (ctx, extraConstraints) {
              if (extraConstraints.maxWidth < 780) {
                return Column(
                  children: [
                    _buildUpcomingExpirationsCard(),
                    const SizedBox(height: 16),
                    _buildShopActivityOverviewCard(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildUpcomingExpirationsCard()),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildShopActivityOverviewCard()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- PAGE 1: SHOPS & TENANTS FULL MANAGEMENT ---
  Widget _buildShopsPage(bool isMobile) {
    final filtered = _filteredShops;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12.0 : 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Search Header
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search shops by name, owner, or plan...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onChanged: (val) => setState(() => _shopSearchQuery = val),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...['All', 'Active', 'Inactive'].map((status) {
                        final isSelected = _selectedStatusFilter == status;
                        return ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                          onSelected: (val) {
                            if (val) setState(() => _selectedStatusFilter = status);
                          },
                        );
                      }),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedPlanFilter,
                        underline: const SizedBox.shrink(),
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        items: ['All', 'Trial', 'Basic', 'Standard', 'Premium']
                            .map((p) => DropdownMenuItem(value: p, child: Text('Plan: $p')))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedPlanFilter = v ?? 'All'),
                      ),
                      DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox.shrink(),
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        items: ['Newest', 'Name A-Z', 'Status']
                            .map((s) => DropdownMenuItem(value: s, child: Text('Sort: $s')))
                            .toList(),
                        onChanged: (v) => setState(() => _sortBy = v ?? 'Newest'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Shop Cards List
          if (_isLoadingShops)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_loadError != null)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.danger)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text('Could not load shops from database: $_loadError', style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: _loadShops, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No shops found in database.', style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (ctx, idx) {
              final shop = filtered[idx];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryLight,
                        child: const Icon(Icons.storefront, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(shop.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text('Owner: ${shop.owner} • ${shop.shopType}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                  child: Text(shop.plan, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                                ),
                                const SizedBox(width: 6),
                                Text('${shop.branches} Branches', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () => _toggleShopStatus(shop),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: shop.status == 'Active' ? AppColors.successLight : AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                shop.status,
                                style: TextStyle(
                                  color: shop.status == 'Active' ? AppColors.success : AppColors.danger,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_active_outlined, size: 20, color: AppColors.secondary),
                                onPressed: () => _openSendReminderDialog(shop),
                                tooltip: 'Send Payment Reminder',
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                                onPressed: () => _showShopDetailsDialog(shop),
                                tooltip: 'Shop Details',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- PAGE 2: SUBSCRIPTIONS & PLANS ---
  Color _accentForSlug(String slug) {
    switch (slug) {
      case 'BASIC':
        return AppColors.primary;
      case 'STANDARD':
        return AppColors.secondary;
      case 'PREMIUM':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildSubscriptionsPage(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12.0 : 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subscription Plans & Platform Tiers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Create, duplicate, activate/deactivate plans, and track payment reminders.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                onPressed: () => _openEditPlanDialog(null),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Create Plan', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_plans.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No plans loaded from database.', style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            ..._plans.map((plan) {
              final count = _shops.where((s) => s.plan.toUpperCase() == plan.slug).length;
              final priceStr = plan.monthlyPrice == 0 ? 'Free' : '${_formatCurrency(plan.monthlyPrice)}/mo';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildPlanTierCard(plan, priceStr, '$count Shops', _accentForSlug(plan.slug)),
              );
            }),
          const SizedBox(height: 20),
          const Text('Recent Payment Reminders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (_reminders.isEmpty)
            const Card(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No payment reminders sent yet.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
            )
          else
            ..._reminders.take(10).map((r) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                      child: Icon(
                        r.channel == 'EMAIL' ? Icons.email_outlined : Icons.sms_outlined,
                        color: AppColors.secondary,
                        size: 18,
                      ),
                    ),
                    title: Text('${r.shopName} (${r.channel})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('To: ${r.recipient}\n${r.message}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                    trailing: Text(r.sentAt, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildPlanTierCard(PlanTier plan, String price, String subscribers, Color accent) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(price, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: accent)),
              ],
            ),
            const SizedBox(height: 6),
            Text(plan.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Divider(height: 20, color: AppColors.borderLight),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          subscribers,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    TextButton.icon(
                      onPressed: () => _openEditPlanDialog(plan),
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Edit', style: TextStyle(fontSize: 11)),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final copy = await ShopRepository().duplicatePlan(plan.slug);
                          if (!mounted) return;
                          setState(() => _plans.add(copy));
                          messenger.showSnackBar(SnackBar(content: Text('Duplicated as ${copy.name}'), backgroundColor: AppColors.success));
                        } catch (e) {
                          messenger.showSnackBar(SnackBar(content: Text('Duplicate failed: $e'), backgroundColor: AppColors.danger));
                        }
                      },
                      icon: const Icon(Icons.copy_outlined, size: 14),
                      label: const Text('Duplicate', style: TextStyle(fontSize: 11)),
                    ),
                    TextButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final updated = await ShopRepository().togglePlanStatus(plan.slug, !plan.isActive);
                          if (!mounted) return;
                          setState(() {
                            final idx = _plans.indexWhere((p) => p.slug == plan.slug);
                            if (idx != -1) _plans[idx] = updated;
                          });
                        } catch (e) {
                          messenger.showSnackBar(SnackBar(content: Text('Status update failed: $e'), backgroundColor: AppColors.danger));
                        }
                      },
                      child: Text(
                        plan.isActive ? 'Deactivate' : 'Activate',
                        style: TextStyle(fontSize: 11, color: plan.isActive ? AppColors.danger : AppColors.success),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- PAGE 4: PLANS & PRICING ---
  Widget _buildPlansPricingPage(bool isMobile) => _buildSubscriptionsPage(isMobile);

  // --- CARDS ON DASHBOARD OVERVIEW ---
  Widget _buildShopGrowthCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                  child: Text(
                    'Shop Registrations',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('Monthly Growth', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(
                painter: _ShopGrowthChartPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlansCard() {
    final total = _shops.length;
    String pct(String plan) {
      if (total == 0) return '0%';
      final count = _shops.where((s) => s.plan.toLowerCase() == plan).length;
      return '${((count * 100) / total).round()}%';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subscription Plans',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CustomPaint(
                    painter: _SubscriptionDonutPainter(
                      premium: _shops.where((s) => s.plan.toLowerCase() == 'premium').length,
                      standard: _shops.where((s) => s.plan.toLowerCase() == 'standard').length,
                      basic: _shops.where((s) => s.plan.toLowerCase() == 'basic').length,
                      trial: _shops.where((s) => s.plan.toLowerCase() == 'trial').length,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildDonutLegend('Premium', pct('premium'), AppColors.primary),
                      const SizedBox(height: 6),
                      _buildDonutLegend('Standard', pct('standard'), AppColors.secondary),
                      const SizedBox(height: 6),
                      _buildDonutLegend('Basic', pct('basic'), const Color(0xFF00C49F)),
                      const SizedBox(height: 6),
                      _buildDonutLegend('Trial', pct('trial'), const Color(0xFFFFBB28)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentShopsTableCard(bool isMobile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Shops',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedNavIndex = 1),
                  child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_isLoadingShops)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_shops.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No shops registered in database yet.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              )
            else
              ..._shops.take(4).map((shop) => InkWell(
                  onTap: () => _showShopDetailsDialog(shop),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryLight,
                          child: const Icon(Icons.storefront, color: AppColors.primary, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(shop.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(shop.owner, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                          child: Text(shop.plan, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: shop.status == 'Active' ? AppColors.successLight : AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            shop.status,
                            style: TextStyle(color: shop.status == 'Active' ? AppColors.success : AppColors.danger, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPaymentsCard() {
    final recentPaid = _shops.take(4).toList();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Platform Subscriptions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            if (recentPaid.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No subscription activity in database yet.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              )
            else
              for (int i = 0; i < recentPaid.length; i++) ...[
                if (i > 0) const Divider(height: 16, color: AppColors.borderLight),
                _buildPaymentRow(
                  recentPaid[i].shopName,
                  _formatCurrency(_planMonthlyPrice(recentPaid[i].plan)),
                  recentPaid[i].joined,
                ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingExpirationsCard() {
    final expiring = _subscriptions.where((s) => s.status == 'ACTIVE' || s.status == 'TRIAL').take(5).toList();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Subscription Expirations',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedNavIndex = 2),
                  child: const Text('Manage', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (expiring.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('No active subscriptions expiring soon.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              )
            else
              ...expiring.map((sub) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.event_note_outlined, size: 18, color: AppColors.secondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sub.shopName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text('${sub.planName} • ${sub.billingCycle}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text('Exp: ${sub.expiresAt}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildShopActivityOverviewCard() {
    final total = _totalShopsCount == 0 ? 1 : _totalShopsCount;
    Widget bar(String label, int count, Color color) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: count / total,
                minHeight: 7,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shop Activity Overview',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            bar('Active Shops', _activeShopsCount, AppColors.success),
            bar('Trial Shops', _trialShopsCount, Colors.blue),
            bar('Suspended Shops', _suspendedShopsCount, AppColors.danger),
            bar('Expired Shops', _expiredShopsCount, Colors.deepOrange),
          ],
        ),
      ),
    );
  }

  static Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDonutLegend(String plan, String percent, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(plan, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const Spacer(),
        Text(percent, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  static Widget _buildPaymentRow(String shop, String amount, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(shop, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
              Text(date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
      ],
    );
  }

  void _openRegisterShopDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => RegisterShopWizardDialog(
        plans: _plans,
        onShopCreated: (newShop) {
          setState(() {
            _shops.insert(0, newShop);
          });
        },
      ),
    );
  }
}

class _ShopGrowthChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.secondary.withValues(alpha: 0.25), AppColors.secondary.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.85);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.7, size.width * 0.4, size.height * 0.65);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.6, size.width * 0.75, size.height * 0.35);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.25, size.width, size.height * 0.15);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SubscriptionDonutPainter extends CustomPainter {
  final int premium;
  final int standard;
  final int basic;
  final int trial;

  _SubscriptionDonutPainter({
    required this.premium,
    required this.standard,
    required this.basic,
    required this.trial,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const stroke = 18.0;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final total = premium + standard + basic + trial;
    if (total == 0) {
      paint.color = AppColors.border;
      canvas.drawArc(rect, 0, 6.283, false, paint);
      return;
    }

    double startAngle = -1.5708;
    final segments = [
      (premium, AppColors.primary),
      (standard, AppColors.secondary),
      (basic, const Color(0xFF00C49F)),
      (trial, const Color(0xFFFFBB28)),
    ];

    for (final (count, color) in segments) {
      if (count <= 0) continue;
      final sweep = (count / total) * 6.283185;
      paint.color = color;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _SubscriptionDonutPainter old) =>
      old.premium != premium || old.standard != standard || old.basic != basic || old.trial != trial;
}
