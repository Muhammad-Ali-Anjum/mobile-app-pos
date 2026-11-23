import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/permission_guard.dart';
import '../../../core/constants/permissions.dart';

class RoleModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final bool isSystemRole;
  final int permissionCount;

  RoleModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.isSystemRole,
    required this.permissionCount,
  });
}

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  final List<RoleModel> _roles = [
    RoleModel(
      id: '1',
      name: 'Shop Owner',
      slug: 'shop_owner',
      description: 'Complete business management, all branches, financials and delegations.',
      isSystemRole: true,
      permissionCount: 88,
    ),
    RoleModel(
      id: '2',
      name: 'Shop Administrator',
      slug: 'shop_admin',
      description: 'High-level shop management and cross-branch operations.',
      isSystemRole: true,
      permissionCount: 72,
    ),
    RoleModel(
      id: '3',
      name: 'Branch Manager',
      slug: 'branch_manager',
      description: 'Managerial authority scoped strictly to designated branch.',
      isSystemRole: true,
      permissionCount: 54,
    ),
    RoleModel(
      id: '4',
      name: 'Sales Manager',
      slug: 'sales_manager',
      description: 'Supervises cashiers, customer credit lines, and discount approvals.',
      isSystemRole: true,
      permissionCount: 41,
    ),
    RoleModel(
      id: '5',
      name: 'Cashier / POS Operator',
      slug: 'cashier',
      description: 'POS billing, customer checkout, receipt printing with discount limits.',
      isSystemRole: true,
      permissionCount: 17,
    ),
    RoleModel(
      id: '6',
      name: 'Inventory Manager',
      slug: 'inventory_manager',
      description: 'Stock management, product catalogs, warehouse movements, and counting.',
      isSystemRole: true,
      permissionCount: 38,
    ),
    RoleModel(
      id: '7',
      name: 'Purchase Officer',
      slug: 'purchase_officer',
      description: 'Procurement orders, supplier interactions, and goods receiving.',
      isSystemRole: true,
      permissionCount: 29,
    ),
    RoleModel(
      id: '8',
      name: 'Accountant / Finance Officer',
      slug: 'accountant',
      description: 'General ledger, expense reviews, cashbook reconciliation, and reports.',
      isSystemRole: true,
      permissionCount: 36,
    ),
    RoleModel(
      id: '9',
      name: 'Auditor / Read-only User',
      slug: 'auditor',
      description: 'Comprehensive inspection and reporting with strict zero-mutation policy.',
      isSystemRole: true,
      permissionCount: 24,
    ),
    RoleModel(
      id: '10',
      name: 'Senior Cashier (Custom)',
      slug: 'senior_cashier',
      description: 'Authorized cashier with extended discount limit (up to 10%) and returns.',
      isSystemRole: false,
      permissionCount: 22,
    ),
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredRoles = _roles.where((r) {
      return r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Roles & Permissions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Configure predefined and custom role permissions across all shop operations',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                PermissionGuard(
                  permission: AppPermissions.rolesCreate,
                  child: ElevatedButton.icon(
                    onPressed: () => _openCreateRoleDialog(context),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create Custom Role'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar & Stats
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                          hintText: 'Search roles by title or responsibility...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Total Roles: ${_roles.length}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Roles Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: filteredRoles.length,
                itemBuilder: (context, index) {
                  final role = filteredRoles[index];
                  return _buildRoleCard(role);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(RoleModel role) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: role.isSystemRole ? AppColors.border : AppColors.secondary.withValues(alpha: 0.5),
          width: role.isSystemRole ? 1 : 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        role.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: role.isSystemRole ? AppColors.primaryLight : AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        role.isSystemRole ? 'SYSTEM' : 'CUSTOM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: role.isSystemRole ? AppColors.primary : AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  role.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${role.permissionCount} permissions',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    role.isSystemRole ? 'View Details' : 'Edit Permissions',
                    style: TextStyle(
                      color: role.isSystemRole ? AppColors.primary : AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Custom Role'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Role Name',
                  hintText: 'e.g. Senior Cashier or Storekeeper',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe responsibilities and scope',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text(
                'Assign permission groups via expandable catalog in next step.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Proceed to Permissions'),
          ),
        ],
      ),
    );
  }
}

