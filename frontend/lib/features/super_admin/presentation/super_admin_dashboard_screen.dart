import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/npts_logo.dart';

import '../../../core/models/registered_shop_item.dart';
import '../../../core/repositories/shop_repository.dart';
class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  int _selectedNavIndex = 0;
  String _shopSearchQuery = '';
  String _selectedStatusFilter = 'All';
  String _selectedTimeframe = 'This Month';

  List<RegisteredShopItem> _shops = [];

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    final repo = ShopRepository();
    final fetched = await repo.fetchAllShops();
    setState(() {
      _shops = fetched;
    });
  }





  int get _totalShopsCount => 124 + _shops.length;
  int get _activeShopsCount => 108 + _shops.where((s) => s.status == 'Active').length;
  int get _inactiveShopsCount => 16 + _shops.where((s) => s.status == 'Inactive').length;

  List<RegisteredShopItem> get _filteredShops {
    return _shops.where((s) {
      final matchesQuery = s.shopName.toLowerCase().contains(_shopSearchQuery.toLowerCase()) ||
          s.owner.toLowerCase().contains(_shopSearchQuery.toLowerCase()) ||
          s.plan.toLowerCase().contains(_shopSearchQuery.toLowerCase());
      final matchesStatus = _selectedStatusFilter == 'All' || s.status == _selectedStatusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  void _toggleShopStatus(RegisteredShopItem shop) {
    setState(() {
      shop.status = (shop.status == 'Active') ? 'Inactive' : 'Active';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${shop.shopName} status changed to ${shop.status}'),
        backgroundColor: shop.status == 'Active' ? AppColors.success : AppColors.danger,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showShopDetailsDialog(RegisteredShopItem shop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
                  Text(shop.shopName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(shop.shopType, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Owner', shop.owner),
            _buildDetailRow('Email', shop.email),
            _buildDetailRow('Phone', shop.phone),
            _buildDetailRow('Plan', shop.plan),
            _buildDetailRow('Branches', '${shop.branches} Branches'),
            _buildDetailRow('Joined Date', shop.joined),
            _buildDetailRow('Current Status', shop.status, isStatus: true),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _toggleShopStatus(shop);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: shop.status == 'Active' ? AppColors.danger : AppColors.success,
              side: BorderSide(color: shop.status == 'Active' ? AppColors.danger : AppColors.success),
            ),
            child: Text(shop.status == 'Active' ? 'Deactivate Shop' : 'Activate Shop'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    _buildSidebarItem(0, 'Dashboard', Icons.dashboard_outlined),
                    _buildSidebarItem(1, 'Shops & Tenants', Icons.storefront_outlined),
                    _buildSidebarItem(2, 'Subscriptions & Plans', Icons.card_membership_outlined),
                    _buildSidebarItem(3, 'Platform Users', Icons.people_alt_outlined),
                    _buildSidebarItem(4, 'Plans & Pricing', Icons.monetization_on_outlined),
                    _buildSidebarItem(5, 'System Settings', Icons.settings_outlined),
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
            contentBody = _buildSubscriptionsPage(isMobile);
            break;
          case 3:
            contentBody = _buildPlatformUsersPage(isMobile);
            break;
          case 4:
            contentBody = _buildPlansPricingPage(isMobile);
            break;
          case 5:
            contentBody = _buildSystemSettingsPage(isMobile);
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
              currentIndex: _selectedNavIndex > 3 ? 0 : _selectedNavIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.secondary,
              unselectedItemColor: AppColors.textSecondary,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
              onTap: (idx) => setState(() => _selectedNavIndex = idx),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Overview'),
                BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Shops'),
                BottomNavigationBarItem(icon: Icon(Icons.card_membership_outlined), activeIcon: Icon(Icons.card_membership), label: 'Plans'),
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
      case 5: return 'System & Database Settings';
      default: return 'SaaS Platform Overview & Tenant Provisioning';
    }
  }

  Widget _buildSidebarItem(int index, String title, IconData icon) {
    final isSelected = _selectedNavIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        onTap: () => setState(() => _selectedNavIndex = index),
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
  Widget _buildDashboardOverviewPage(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12.0 : 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // 4 KPI Cards
          LayoutBuilder(
            builder: (ctx, kpiConstraints) {
              final width = kpiConstraints.maxWidth;
              int crossAxisCount = width < 480 ? 1 : (width < 800 ? 2 : (width < 1150 ? 2 : 4));
              double childAspectRatio = width < 480 ? 3.0 : (width < 800 ? 2.1 : 1.7);

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
                  _buildKpiCard('Inactive Shops', '$_inactiveShopsCount', Icons.pause_circle_outline, AppColors.danger),
                  _buildKpiCard('Monthly Revenue', 'Rs. 450,000', Icons.payments_outlined, const Color(0xFF7C3AED)),
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
                  Row(
                    children: ['All', 'Active', 'Inactive'].map((status) {
                      final isSelected = _selectedStatusFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                          onSelected: (val) {
                            if (val) setState(() => _selectedStatusFilter = status);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Shop Cards List
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
                          IconButton(
                            icon: const Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                            onPressed: () => _showShopDetailsDialog(shop),
                            tooltip: 'Shop Details',
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
  Widget _buildSubscriptionsPage(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12.0 : 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subscription Plans & Platform Tiers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Manage tenant quotas, limits, and recurring pricing.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          _buildPlanTierCard('Basic Retail', 'Rs. 2,500/mo', '1 Branch • 3 Users • 1 POS Terminal', '42 Active Shops', AppColors.primary),
          const SizedBox(height: 12),
          _buildPlanTierCard('Standard Multi-Branch', 'Rs. 5,000/mo', '3 Branches • 10 Users • 3 POS Terminals', '58 Active Shops', AppColors.secondary),
          const SizedBox(height: 12),
          _buildPlanTierCard('Premium Enterprise', 'Rs. 10,000/mo', 'Unlimited Branches • 50 Users • Dedicated Support', '18 Active Shops', const Color(0xFF7C3AED)),
          const SizedBox(height: 12),
          _buildPlanTierCard('Trial Plan', 'Free (30 Days)', '1 Branch • 2 Users • Core POS Only', '10 Trial Shops', const Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildPlanTierCard(String name, String price, String quota, String subscribers, Color accent) {
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
                    name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(price, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: accent)),
              ],
            ),
            const SizedBox(height: 6),
            Text(quota, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                TextButton(
                  onPressed: () {},
                  child: const Text('Edit Tier Quota', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- PAGE 3: PLATFORM USERS ---
  Widget _buildPlatformUsersPage(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12.0 : 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Platform Administrators & Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          _buildPlatformUserTile('Super Admin', 'superadmin@nextplanners.com', 'Super Admin (Full Root Access)', 'Active'),
          const SizedBox(height: 10),
          _buildPlatformUserTile('Support Agent 1', 'support@nextplanners.com', 'Support Admin (Read & Impersonate)', 'Active'),
          const SizedBox(height: 10),
          _buildPlatformUserTile('Billing Admin', 'billing@nextplanners.com', 'Financial & Subscriptions Only', 'Active'),
        ],
      ),
    );
  }

  Widget _buildPlatformUserTile(String name, String email, String role, String status) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
              child: const Icon(Icons.shield_outlined, color: AppColors.secondary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(email, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(role, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- PAGE 4: PLANS & PRICING ---
  Widget _buildPlansPricingPage(bool isMobile) => _buildSubscriptionsPage(isMobile);

  // --- PAGE 5: SYSTEM SETTINGS ---
  Widget _buildSystemSettingsPage(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12.0 : 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Architecture & Health', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          _buildSettingStatusTile('MongoDB Multi-Tenant DB', 'Connected • 12ms latency', Icons.storage, AppColors.success),
          const SizedBox(height: 10),
          _buildSettingStatusTile('Node.js REST Backend', 'Online • Port 5000', Icons.dns, AppColors.success),
          const SizedBox(height: 10),
          _buildSettingStatusTile('Tenant Data Isolation', 'Strict Enforced (shopId Scoped)', Icons.lock, AppColors.primary),
          const SizedBox(height: 10),
          _buildSettingStatusTile('Audit Logging Engine', 'Active • 1,420 events logged', Icons.history, AppColors.secondary),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => AuthService().logout(),
            icon: const Icon(Icons.logout, size: 18, color: Colors.white),
            label: const Text('Log Out of Super Admin', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingStatusTile(String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }

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
                    painter: _SubscriptionDonutPainter(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildDonutLegend('Premium', '45%', AppColors.primary),
                      const SizedBox(height: 6),
                      _buildDonutLegend('Standard', '30%', AppColors.secondary),
                      const SizedBox(height: 6),
                      _buildDonutLegend('Basic', '15%', const Color(0xFF00C49F)),
                      const SizedBox(height: 6),
                      _buildDonutLegend('Trial', '10%', const Color(0xFFFFBB28)),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Platform Payments',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            _buildPaymentRow('ABC Supermarket', 'Rs. 12,000', '12 Dec 2024'),
            const Divider(height: 16, color: AppColors.borderLight),
            _buildPaymentRow('City Mart', 'Rs. 8,500', '11 Dec 2024'),
            const Divider(height: 16, color: AppColors.borderLight),
            _buildPaymentRow('Kashish Hub', 'Rs. 15,000', '10 Dec 2024'),
            const Divider(height: 16, color: AppColors.borderLight),
            _buildPaymentRow('Northern Pharmacy', 'Rs. 9,000', '08 Dec 2024'),
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
    final nameCtrl = TextEditingController();
    final ownerCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: 'Pass@123');
    final addressCtrl = TextEditingController();
    String selectedShopType = 'Supermarket';
    String selectedPlan = 'Standard';

    showDialog(
      context: context,
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 480,
              maxHeight: screenHeight * 0.88,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const NptsLogo(height: 38),
                    const SizedBox(height: 12),
                    const Text(
                      'Create Shop Account',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Super Admin Tenant Provisioning',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 18),
                    _buildFormField('Full Name', ownerCtrl, 'e.g. Ali Khan', Icons.person_outline),
                    const SizedBox(height: 12),
                    _buildFormField('Shop Name', nameCtrl, 'e.g. ABC Supermarket', Icons.storefront_outlined),
                    const SizedBox(height: 12),
                    _buildFormField('Email Address', emailCtrl, 'e.g. owner@abc.com', Icons.email_outlined),
                    const SizedBox(height: 12),
                    _buildFormField('Mobile Number', phoneCtrl, '+92 300 1234567', Icons.phone_outlined),
                    const SizedBox(height: 12),
                    _buildFormField('Default Password', passwordCtrl, 'Assign password', Icons.lock_outline),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Shop Type', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      initialValue: selectedShopType,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        prefixIcon: const Icon(Icons.category_outlined, size: 18, color: AppColors.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Retail', child: Text('Retail Store')),
                        DropdownMenuItem(value: 'Supermarket', child: Text('Supermarket / Hypermarket')),
                        DropdownMenuItem(value: 'Wholesaler', child: Text('Wholesaler / Distributor')),
                        DropdownMenuItem(value: 'Pharmacy', child: Text('Pharmacy & Health')),
                        DropdownMenuItem(value: 'Restaurant', child: Text('Restaurant / Cafe')),
                      ],
                      onChanged: (val) => selectedShopType = val ?? 'Supermarket',
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Subscription Plan', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPlan,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        prefixIcon: const Icon(Icons.card_membership_outlined, size: 18, color: AppColors.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Trial', child: Text('Trial Plan (30 Days)')),
                        DropdownMenuItem(value: 'Basic', child: Text('Basic Plan (1 Branch)')),
                        DropdownMenuItem(value: 'Standard', child: Text('Standard Plan (3 Branches)')),
                        DropdownMenuItem(value: 'Premium', child: Text('Premium Enterprise')),
                      ],
                      onChanged: (val) => selectedPlan = val ?? 'Standard',
                    ),
                    const SizedBox(height: 12),
                    _buildFormField('Business Address', addressCtrl, 'e.g. Main Bazar, Skardu', Icons.location_on_outlined),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                            onPressed: () {
                              if (nameCtrl.text.isNotEmpty && ownerCtrl.text.isNotEmpty) {
                                setState(() {
                                  _shops.insert(
                                    0,
                                    RegisteredShopItem(
                                      id: 'shp_${DateTime.now().millisecondsSinceEpoch}',
                                      shopName: nameCtrl.text.trim(),
                                      owner: ownerCtrl.text.trim(),
                                      email: emailCtrl.text.trim().isNotEmpty
                                          ? emailCtrl.text.trim()
                                          : 'owner@${nameCtrl.text.toLowerCase().replaceAll(' ', '')}.com',
                                      phone: phoneCtrl.text.trim().isNotEmpty
                                          ? phoneCtrl.text.trim()
                                          : '+92 300 0000000',
                                      plan: selectedPlan,
                                      status: 'Active',
                                      joined: 'Today',
                                      shopType: selectedShopType,
                                      branches: selectedPlan == 'Premium' ? 5 : (selectedPlan == 'Standard' ? 3 : 1),
                                    ),
                                  );
                                });
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Shop "${nameCtrl.text}" successfully registered and provisioned!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                            child: const Text('Register Shop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField(String label, TextEditingController ctrl, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
      ],
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
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const stroke = 18.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    paint.color = AppColors.primary;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - stroke / 2), -1.57, 2.8, false, paint);

    paint.color = AppColors.secondary;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - stroke / 2), 1.23, 1.88, false, paint);

    paint.color = const Color(0xFF00C49F);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - stroke / 2), 3.11, 0.94, false, paint);

    paint.color = const Color(0xFFFFBB28);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - stroke / 2), 4.05, 0.63, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
