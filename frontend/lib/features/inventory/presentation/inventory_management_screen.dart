import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/permission_guard.dart';
import '../../../core/constants/permissions.dart';

class InventoryMovementItem {
  final String date;
  final String product;
  final String type;
  final int qty;
  final String branch;

  InventoryMovementItem({
    required this.date,
    required this.product,
    required this.type,
    required this.qty,
    required this.branch,
  });
}

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final List<InventoryMovementItem> _movements = [
    InventoryMovementItem(date: 'Today, 11:20 AM', product: 'Rice 5kg', type: 'Stock In', qty: 50, branch: 'Main Branch'),
    InventoryMovementItem(date: 'Today, 10:45 AM', product: 'Milk 1L', type: 'Sale', qty: -10, branch: 'Main Branch'),
    InventoryMovementItem(date: 'Yesterday', product: 'Sugar 1kg', type: 'Stock Out', qty: -15, branch: 'Branch 2 - Gilgit'),
    InventoryMovementItem(date: 'Yesterday', product: 'Cooking Oil 1L', type: 'Adjustment', qty: -2, branch: 'Main Branch'),
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
                    Text('Inventory & Warehouse', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Real-time stock tracking, warehouse transfers, adjustments, and re-order thresholds', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text('Transfer Stock'),
                    ),
                    const SizedBox(width: 12),
                    PermissionGuard(
                      permission: AppPermissions.inventoryAdjust,
                      child: ElevatedButton.icon(
                        onPressed: () => _openStockAdjustmentDialog(context),
                        icon: const Icon(Icons.tune, size: 18),
                        label: const Text('Stock Adjustment'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Top Stat Cards
            Row(
              children: [
                _buildStatCard('Total Stock Items', '1,250', AppColors.primary),
                const SizedBox(width: 14),
                _buildStatCard('Total Inventory Value', 'Rs. 450,750', AppColors.secondary),
                const SizedBox(width: 14),
                _buildStatCard('Low Stock Items', '18', AppColors.warning),
                const SizedBox(width: 14),
                _buildStatCard('Out of Stock', '12', AppColors.danger),
              ],
            ),
            const SizedBox(height: 20),

            // Recent Movements Table
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Inventory Stock Movements',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: Text('DATE', style: _headerStyle)),
                            Expanded(flex: 3, child: Text('PRODUCT', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('MOVEMENT TYPE', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('QUANTITY', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('BRANCH', style: _headerStyle)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _movements.length,
                          separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.border),
                          itemBuilder: (context, index) {
                            final m = _movements[index];
                            final isPlus = m.qty > 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(flex: 2, child: Text(m.date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                                  Expanded(flex: 3, child: Text(m.product, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary))),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(m.type, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${isPlus ? "+" : ""}${m.qty}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isPlus ? AppColors.success : AppColors.danger,
                                      ),
                                    ),
                                  ),
                                  Expanded(flex: 2, child: Text(m.branch, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
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

  void _openStockAdjustmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Inventory Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(decoration: InputDecoration(labelText: 'Select Product')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'New Stock Count')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Adjustment Reason (e.g. damaged, physical audit)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stock count updated and logged in audit trails.')),
              );
            },
            child: const Text('Save Adjustment'),
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

