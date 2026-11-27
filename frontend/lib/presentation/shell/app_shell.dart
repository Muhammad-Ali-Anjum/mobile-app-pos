import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/npts_logo.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/pos/presentation/pos_billing_screen.dart';
import '../../features/products/presentation/product_management_screen.dart';
import '../../features/inventory/presentation/inventory_management_screen.dart';
import '../../features/sales/presentation/sales_management_screen.dart';
import '../../features/customers/presentation/customer_management_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/roles/presentation/role_management_screen.dart';
import '../../features/users/presentation/user_management_screen.dart';
import '../../features/approvals/presentation/approval_management_screen.dart';
import '../../features/audit_logs/presentation/audit_logs_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    DashboardScreen(onNavigate: (idx) => setState(() => _selectedIndex = idx)),
    const PosBillingScreen(),
    const ProductManagementScreen(),
    const InventoryManagementScreen(),
    const SalesManagementScreen(),
    const CustomerManagementScreen(),
    const ReportsScreen(),
    const RoleManagementScreen(),
    const UserManagementScreen(),
    const ApprovalManagementScreen(),
    const AuditLogsScreen(),
    const ProfileScreen(),
  ];

  int _getBottomNavIndex(int screenIdx) {
    switch (screenIdx) {
      case 0: return 0;
      case 1: return 1;
      case 2:
      case 3: return 2;
      case 4: return 3;
      case 11: return 4;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;
        final user = AuthService().currentUser;
        final initials = (user?.fullName.isNotEmpty ?? false)
            ? user!.fullName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join()
            : 'AK';

    final sidebarContent = Container(
      width: 250,
      color: const Color(0xFF101C30),
      child: Column(
        children: [
          // Brand Header with Official NPTS Logo
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
                Text(
                  'Smart Shop Management System',
                  style: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildNavItem(0, 'Dashboard', Icons.home_outlined),
                _buildNavItem(1, 'POS Billing', Icons.point_of_sale_outlined),
                _buildNavItem(2, 'Products', Icons.inventory_2_outlined),
                _buildNavItem(3, 'Inventory', Icons.warehouse_outlined),
                _buildNavItem(4, 'Sales & Invoices', Icons.receipt_long_outlined),
                _buildNavItem(5, 'Customers', Icons.people_outline),
                _buildNavItem(6, 'Reports & Analytics', Icons.auto_graph_outlined),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'SECURITY & ACCESS',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildNavItem(7, 'Roles & Permissions', Icons.security),
                _buildNavItem(8, 'Employee Directory', Icons.manage_accounts_outlined),
                _buildNavItem(9, 'Approval Queue', Icons.rule_folder_outlined, badge: '3'),
                _buildNavItem(10, 'Audit Logs', Icons.verified_user_outlined),
                _buildNavItem(11, 'My Profile / Settings', Icons.settings_outlined),
              ],
            ),
          ),

          // Bottom User Profile Box & Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0B1424),
              border: Border(top: BorderSide(color: Color(0xFF1E2F4A))),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => setState(() => _selectedIndex = 11),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'Ali Khan',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.roleName ?? 'Shop Owner',
                          style: const TextStyle(color: AppColors.secondary, fontSize: 11),
                        ),
                      ],
                    ),
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

        // If not Desktop (Mobile or Tablet), use Drawer and Responsive Navigation
        if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
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
                const Icon(Icons.storefront, color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  user?.shopName ?? 'My Shop',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.textSecondary, size: 20),
              onPressed: () {},
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: InkWell(
                onTap: () => setState(() => _selectedIndex = 11),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    initials,
                    style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(child: sidebarContent),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _getBottomNavIndex(_selectedIndex),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
          onTap: (navIndex) {
            setState(() {
              switch (navIndex) {
                case 0: _selectedIndex = 0; break;
                case 1: _selectedIndex = 1; break;
                case 2: _selectedIndex = 2; break;
                case 3: _selectedIndex = 4; break;
                case 4: _selectedIndex = 11; break;
              }
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_outlined), activeIcon: Icon(Icons.point_of_sale), label: 'POS'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Products'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Sales'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
    }

    // Desktop Layout (Persistent Docked Sidebar + Top Bar)
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          sidebarContent,

          // Main Workspace
          Expanded(
            child: Column(
              children: [
                // Top Global Bar
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
                      // Branch Selector Dropdown
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.storefront, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: 'Main Branch – Skardu',
                                  isExpanded: false,
                                  items: const [
                                    DropdownMenuItem(value: 'Main Branch – Skardu', child: Text('ABC Supermarket – Skardu (Main)')),
                                    DropdownMenuItem(value: 'Branch 2 – Gilgit', child: Text('Branch 2 – Gilgit')),
                                    DropdownMenuItem(value: 'Branch 3 – Islamabad', child: Text('Branch 3 – Islamabad')),
                                  ],
                                  onChanged: (val) {},
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right Quick Status & Profile
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.fiber_manual_record, color: AppColors.success, size: 9),
                                SizedBox(width: 6),
                                Text(
                                  'RBAC ONLINE',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          IconButton(
                            icon: const Icon(Icons.notifications_none, color: AppColors.textSecondary, size: 20),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              initials,
                              style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Selected Feature View
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon, {String? badge}) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        onTap: () {
          setState(() => _selectedIndex = index);
          if (Responsive.isMobile(context)) {
            Navigator.of(context).maybePop(); // close mobile drawer
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : Colors.transparent, // Orange highlight pill
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              ),
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
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: isSelected ? AppColors.secondary : Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
