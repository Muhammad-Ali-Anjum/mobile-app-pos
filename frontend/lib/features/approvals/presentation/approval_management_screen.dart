import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/permission_guard.dart';
import '../../../core/constants/permissions.dart';

class ApprovalItem {
  final String id;
  final String actionType;
  final String module;
  final String requestedBy;
  final String branch;
  final String summary;
  final String reason;
  final String timeAgo;
  final String status;

  ApprovalItem({
    required this.id,
    required this.actionType,
    required this.module,
    required this.requestedBy,
    required this.branch,
    required this.summary,
    required this.reason,
    required this.timeAgo,
    this.status = 'PENDING',
  });
}

class ApprovalManagementScreen extends StatefulWidget {
  const ApprovalManagementScreen({super.key});

  @override
  State<ApprovalManagementScreen> createState() => _ApprovalManagementScreenState();
}

class _ApprovalManagementScreenState extends State<ApprovalManagementScreen> {
  final List<ApprovalItem> _pendingApprovals = [
    ApprovalItem(
      id: 'app_1',
      actionType: 'DISCOUNT_OVERRIDE',
      module: 'pos',
      requestedBy: 'Usman Raza (Cashier)',
      branch: 'Main Branch – Skardu',
      summary: '15% Discount on Invoice #INV-1025 (Standard limit is 10%)',
      reason: 'Long-standing VIP client requesting bulk purchase concession.',
      timeAgo: '10 mins ago',
    ),
    ApprovalItem(
      id: 'app_2',
      actionType: 'HIGH_VALUE_REFUND',
      module: 'pos',
      requestedBy: 'Sana Tariq (Cashier)',
      branch: 'Gilgit Branch',
      summary: 'Cash refund of Rs. 9,450 for returned electronic items (Limit Rs. 5,000)',
      reason: 'Customer returned sealed parcel with original receipt.',
      timeAgo: '25 mins ago',
    ),
    ApprovalItem(
      id: 'app_3',
      actionType: 'STOCK_ADJUSTMENT',
      module: 'inventory',
      requestedBy: 'Tariq Mehmood (Inventory Manager)',
      branch: 'Main Branch – Skardu',
      summary: 'Write-off 12 units of Cooking Oil (Expired batch #CK-902)',
      reason: 'Damaged during transit and shelf expiry detected.',
      timeAgo: '1 hour ago',
    ),
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
                    Text(
                      'Approval Requests',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Review sensitive operational thresholds requiring managerial authorization',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pending_actions, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        '${_pendingApprovals.length} Pending Actions',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: _pendingApprovals.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      itemCount: _pendingApprovals.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = _pendingApprovals[index];
                        return _buildApprovalCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalCard(ApprovalItem item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.actionType.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.branch,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.timeAgo,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              item.summary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              'Reason: ${item.reason}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Submitted by: ${item.requestedBy}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                PermissionGuard(
                  permission: AppPermissions.approvalsManage,
                  fallback: const Text(
                    'View Only (Authorization needed to approve)',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _pendingApprovals.remove(item);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request rejected.')),
                          );
                        },
                        icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
                        label: const Text('Reject', style: TextStyle(color: AppColors.danger)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.danger),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _pendingApprovals.remove(item);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.success,
                              content: Text('Request approved and logged to audit trail.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve Operation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
          SizedBox(height: 16),
          Text(
            'All Approvals Clear!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8),
          Text(
            'There are currently no pending authorization requests.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

