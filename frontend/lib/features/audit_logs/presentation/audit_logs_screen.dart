import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AuditEntry {
  final String id;
  final String timestamp;
  final String user;
  final String role;
  final String action;
  final String module;
  final String details;
  final String ipAddress;

  AuditEntry({
    required this.id,
    required this.timestamp,
    required this.user,
    required this.role,
    required this.action,
    required this.module,
    required this.details,
    required this.ipAddress,
  });
}

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final List<AuditEntry> _logs = [
    AuditEntry(
      id: 'log_1',
      timestamp: 'Today, 11:42 PM',
      user: 'Ali Khan',
      role: 'Shop Owner',
      action: 'USER_ROLE_ASSIGNED',
      module: 'users',
      details: 'Assigned role [Senior Cashier] to employee Fatima Ali (EMP-002)',
      ipAddress: '192.168.1.104',
    ),
    AuditEntry(
      id: 'log_2',
      timestamp: 'Today, 10:15 PM',
      user: 'Fatima Ali',
      role: 'Branch Manager',
      action: 'APPROVAL_APPROVED',
      module: 'pos',
      details: 'Approved 15% discount override for Invoice #INV-1025 requested by Usman Raza',
      ipAddress: '192.168.1.112',
    ),
    AuditEntry(
      id: 'log_3',
      timestamp: 'Today, 08:30 PM',
      user: 'Tariq Mehmood',
      role: 'Inventory Manager',
      action: 'STOCK_ADJUSTMENT',
      module: 'inventory',
      details: 'Recorded physical stock count discrepancy of -5 units for Rice 5kg (Batch #RC-12)',
      ipAddress: '192.168.1.150',
    ),
    AuditEntry(
      id: 'log_4',
      timestamp: 'Today, 04:10 PM',
      user: 'Ali Khan',
      role: 'Shop Owner',
      action: 'USER_SUSPENDED',
      module: 'users',
      details: 'Suspended employee account for Tariq Mehmood pending audit review',
      ipAddress: '192.168.1.104',
    ),
    AuditEntry(
      id: 'log_5',
      timestamp: 'Yesterday, 06:05 PM',
      user: 'Usman Raza',
      role: 'Cashier',
      action: 'LOGIN_SUCCESS',
      module: 'auth',
      details: 'Cashier shift opened on POS Terminal #01 (Main Branch Skardu)',
      ipAddress: '192.168.1.201',
    ),
  ];

  String _selectedModule = 'ALL';

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _selectedModule == 'ALL'
        ? _logs
        : _logs.where((l) => l.module.toLowerCase() == _selectedModule.toLowerCase()).toList();

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
                      'Audit & Activity Trails',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Immutable, tamper-proof security log recording every critical transaction and role change',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export Audit Log (CSV)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'All Modules'),
                  _buildFilterChip('pos', 'POS Operations'),
                  _buildFilterChip('users', 'User & Role Changes'),
                  _buildFilterChip('inventory', 'Inventory Movements'),
                  _buildFilterChip('auth', 'Auth & Sessions'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logs Table / List
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLogs.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.history, size: 18, color: AppColors.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          log.user,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: Text(
                                            log.role,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      log.timestamp,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  log.details,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        log.action,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'IP: ${log.ipAddress}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String moduleKey, String label) {
    final isSelected = _selectedModule == moduleKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
        onSelected: (val) {
          setState(() {
            _selectedModule = moduleKey;
          });
        },
      ),
    );
  }
}

