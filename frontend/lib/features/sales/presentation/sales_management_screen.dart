import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';

class InvoiceItem {
  final String invoiceNumber;
  final String customer;
  final String date;
  final double total;
  final double paid;
  final String status;

  InvoiceItem({
    required this.invoiceNumber,
    required this.customer,
    required this.date,
    required this.total,
    required this.paid,
    required this.status,
  });

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    final total = (map['grandTotal'] as num?)?.toDouble() ?? 0;
    final paid = (map['paidAmount'] as num?)?.toDouble() ?? total;
    return InvoiceItem(
      invoiceNumber: (map['invoiceNumber'] ?? map['_id'] ?? '').toString(),
      customer: (map['customerName'] ?? 'Walk-in Customer').toString(),
      date: (map['createdAt'] ?? '').toString().split('T').first,
      total: total,
      paid: paid,
      status: (map['status'] ?? 'COMPLETED').toString(),
    );
  }
}

class SalesManagementScreen extends StatefulWidget {
  const SalesManagementScreen({super.key});

  @override
  State<SalesManagementScreen> createState() => _SalesManagementScreenState();
}

class _SalesManagementScreenState extends State<SalesManagementScreen> {
  List<InvoiceItem> _invoices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final res = await http.get(
        Uri.parse('http://localhost:5002/api/pos/sales'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (body['data'] as List?) ?? [];
        if (!mounted) return;
        setState(() {
          _invoices = list.map((e) => InvoiceItem.fromMap(e as Map<String, dynamic>)).toList();
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
    final totalRevenue = _invoices.fold<double>(0, (s, i) => s + i.total);
    final pendingTotal = _invoices.fold<double>(0, (s, i) => s + (i.total - i.paid).clamp(0, double.infinity));

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
                    Text('Sales & Invoices', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Invoice records, customer receipts, and payment verification', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: _loadSales,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                _buildStatCard('Total Sales', 'Rs. ${totalRevenue.toStringAsFixed(0)}', AppColors.primary),
                const SizedBox(width: 14),
                _buildStatCard('Total Invoices', '${_invoices.length}', AppColors.secondary),
                const SizedBox(width: 14),
                _buildStatCard('Pending Payments', 'Rs. ${pendingTotal.toStringAsFixed(0)}', AppColors.warning),
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
                            Expanded(flex: 2, child: Text('INVOICE #', style: _headerStyle)),
                            Expanded(flex: 3, child: Text('CUSTOMER', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('DATE', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('TOTAL', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('PAID', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('STATUS', style: _headerStyle)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _invoices.isEmpty
                                ? const Center(child: Text('No sales recorded in database yet.', style: TextStyle(color: AppColors.textSecondary)))
                                : ListView.separated(
                                    itemCount: _invoices.length,
                                    separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.border),
                                    itemBuilder: (context, index) {
                                      final inv = _invoices[index];
                                      final isCompleted = inv.status.toUpperCase() == 'COMPLETED' || inv.status.toUpperCase() == 'PAID';
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        child: Row(
                                          children: [
                                            Expanded(flex: 2, child: Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary))),
                                            Expanded(flex: 3, child: Text(inv.customer, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                                            Expanded(flex: 2, child: Text(inv.date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                                            Expanded(flex: 2, child: Text('Rs. ${inv.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                            Expanded(flex: 2, child: Text('Rs. ${inv.paid.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: AppColors.success))),
                                            Expanded(
                                              flex: 2,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: isCompleted ? AppColors.successLight : AppColors.warningLight,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    inv.status,
                                                    style: TextStyle(
                                                      color: isCompleted ? AppColors.success : AppColors.warning,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
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
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.bold,
  color: AppColors.textSecondary,
);
