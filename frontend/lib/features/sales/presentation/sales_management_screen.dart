import 'package:flutter/material.dart';
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
}

class SalesManagementScreen extends StatelessWidget {
  const SalesManagementScreen({super.key});

  static final List<InvoiceItem> _invoices = [
    InvoiceItem(invoiceNumber: 'INV-1001', customer: 'Ali Khan', date: '12 Dec 2024', total: 24500, paid: 24500, status: 'Paid'),
    InvoiceItem(invoiceNumber: 'INV-1002', customer: 'Fatima Ali', date: '12 Dec 2024', total: 18750, paid: 18750, status: 'Paid'),
    InvoiceItem(invoiceNumber: 'INV-1003', customer: 'Usman Raza', date: '11 Dec 2024', total: 32400, paid: 25000, status: 'Partial'),
    InvoiceItem(invoiceNumber: 'INV-1004', customer: 'Sana Malik', date: '10 Dec 2024', total: 12800, paid: 12800, status: 'Paid'),
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
                    Text('Sales & Invoices', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Invoice records, customer receipts, payment verification, and sales returns', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Export Invoices'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                _buildStatCard('Today\'s Sales', 'Rs. 108,750', AppColors.primary),
                const SizedBox(width: 14),
                _buildStatCard('Return Sales', 'Rs. 24,500', AppColors.danger),
                const SizedBox(width: 14),
                _buildStatCard('Total Invoices', '48', AppColors.secondary),
                const SizedBox(width: 14),
                _buildStatCard('Pending Payments', 'Rs. 8,750', AppColors.warning),
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
                        child: ListView.separated(
                          itemCount: _invoices.length,
                          separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.border),
                          itemBuilder: (context, index) {
                            final inv = _invoices[index];
                            final isPaid = inv.status == 'Paid';
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                                  ),
                                  Expanded(flex: 3, child: Text(inv.customer, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                                  Expanded(flex: 2, child: Text(inv.date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                                  Expanded(
                                    flex: 2,
                                    child: Text('Rs. ${inv.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                                  ),
                                  Expanded(flex: 2, child: Text('Rs. ${inv.paid.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isPaid ? AppColors.successLight : AppColors.warningLight,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          inv.status,
                                          style: TextStyle(
                                            color: isPaid ? AppColors.success : const Color(0xFFB45309),
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
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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

