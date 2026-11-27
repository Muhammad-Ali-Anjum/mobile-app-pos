import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/permission_guard.dart';
import '../../../core/constants/permissions.dart';

class CustomerEntry {
  final String id;
  final String name;
  final String phone;
  final String email;
  final double balance;
  final String status;

  CustomerEntry({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.balance,
    required this.status,
  });

  factory CustomerEntry.fromMap(Map<String, dynamic> map) => CustomerEntry(
        id: (map['_id'] ?? map['id'] ?? '').toString(),
        name: (map['name'] ?? map['fullName'] ?? '').toString(),
        phone: (map['phone'] ?? '').toString(),
        email: (map['email'] ?? '').toString(),
        balance: (map['balance'] as num?)?.toDouble() ?? 0,
        status: (map['status'] ?? 'Active').toString(),
      );
}

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  static const String _baseUrl = 'http://localhost:5002/api/customers';
  List<CustomerEntry> _customers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadCustomers() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse(_baseUrl), headers: await _headers());
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (body['data'] as List?) ?? [];
        if (!mounted) return;
        setState(() {
          _customers = list.map((e) => CustomerEntry.fromMap(e as Map<String, dynamic>)).toList();
          _loading = false;
        });
        return;
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final total = _customers.length;
    final active = _customers.where((c) => c.status.toLowerCase() == 'active').length;
    final withBalance = _customers.where((c) => c.balance > 0).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Customer ledger, balances, loyalty, and contact details', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
                PermissionGuard(
                  permission: AppPermissions.usersCreate,
                  child: ElevatedButton.icon(
                    onPressed: () => _openAddCustomerDialog(context),
                    icon: const Icon(Icons.person_add, size: 20, color: Colors.white),
                    label: const Text('Add Customer', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                _buildStatCard('Total Customers', '$total', AppColors.primary),
                const SizedBox(width: 14),
                _buildStatCard('Active Accounts', '$active', AppColors.success),
                const SizedBox(width: 14),
                _buildStatCard('With Outstanding Balance', '$withBalance', AppColors.warning),
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
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _customers.isEmpty
                                ? const Center(child: Text('No customers found in database.', style: TextStyle(color: AppColors.textSecondary)))
                                : ListView.separated(
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
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddCustomerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Customer Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number (e.g. 0300 1234567)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final nav = Navigator.of(ctx);
              final msg = ScaffoldMessenger.of(context);
              final res = await http.post(
                Uri.parse(_baseUrl),
                headers: await _headers(),
                body: jsonEncode({
                  'name': name,
                  'phone': phoneCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                }),
              );
              if (res.statusCode == 201 || res.statusCode == 200) {
                nav.pop();
                await _loadCustomers();
                msg.showSnackBar(SnackBar(content: Text('Customer "$name" saved!'), backgroundColor: AppColors.success));
              }
            },
            child: const Text('Save Customer', style: TextStyle(color: Colors.white)),
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
