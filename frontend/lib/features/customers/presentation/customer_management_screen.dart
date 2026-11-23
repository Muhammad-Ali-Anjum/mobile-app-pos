import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/permission_guard.dart';
import '../../../core/constants/permissions.dart';

class CustomerEntry {
  final String name;
  final String phone;
  final String email;
  final double balance;
  final String status;

  CustomerEntry({
    required this.name,
    required this.phone,
    required this.email,
    required this.balance,
    required this.status,
  });
}

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final List<CustomerEntry> _customers = [
    CustomerEntry(name: 'Ali Khan', phone: '0300 1234567', email: 'ali@abc.com', balance: 2500, status: 'Active'),
    CustomerEntry(name: 'Fatima Ali', phone: '0312 9876543', email: 'fatima@abc.com', balance: 0, status: 'Active'),
    CustomerEntry(name: 'Usman Raza', phone: '0345 1112233', email: 'usman@abc.com', balance: 1200, status: 'Active'),
    CustomerEntry(name: 'Sana Malik', phone: '0322 4455667', email: 'sana@abc.com', balance: 0, status: 'Active'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Customer Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Customer ledger, balances, loyalty, and contact details', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
                PermissionGuard(
                  permission: AppPermissions.usersCreate,
                  child: ElevatedButton.icon(
                    onPressed: () => _openAddCustomerDialog(context),
                    icon: const Icon(Icons.person_add, size: 20),
                    label: const Text('Add Customer'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                _buildStatCard('Total Customers', '540', AppColors.primary),
                const SizedBox(width: 14),
                _buildStatCard('Active Accounts', '520', AppColors.success),
                const SizedBox(width: 14),
                _buildStatCard('With Outstanding Balance', '25', AppColors.warning),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Expanded(flex: 3, child: Text('NAME', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('PHONE', style: _headerStyle)),
                            Expanded(flex: 3, child: Text('EMAIL', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('BALANCE', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('STATUS', style: _headerStyle)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _customers.length,
                          separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.border),
                          itemBuilder: (context, index) {
                            final c = _customers[index];
                            final hasBal = c.balance > 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                                  ),
                                  Expanded(flex: 2, child: Text(c.phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                                  Expanded(flex: 3, child: Text(c.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Rs. ${c.balance.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: hasBal ? AppColors.danger : AppColors.success,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.successLight,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(c.status, style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(decoration: InputDecoration(labelText: 'Customer Full Name')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Phone Number (e.g. 0300 1234567)')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Email Address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Save Customer'),
          ),
        ],
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.bold,
  color: AppColors.textSecondary,
);

