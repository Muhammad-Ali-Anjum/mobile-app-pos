import 'package:flutter/material.dart';
import '../../../../core/models/registered_shop_item.dart';
import '../../../../core/repositories/shop_repository.dart';
import '../../../../core/theme/app_colors.dart';

class PaymentsBillingPage extends StatefulWidget {
  final List<RegisteredShopItem> shops;
  final List<PlanTier> plans;
  final int initialTabIndex;

  const PaymentsBillingPage({
    super.key,
    required this.shops,
    required this.plans,
    this.initialTabIndex = 0,
  });

  @override
  State<PaymentsBillingPage> createState() => _PaymentsBillingPageState();
}

class _PaymentsBillingPageState extends State<PaymentsBillingPage> {
  List<InvoiceItem> _invoices = [];
  List<CouponItem> _coupons = [];
  Map<String, dynamic> _report = {};
  bool _loading = true;
  String _statusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ShopRepository();
      final results = await Future.wait([
        repo.fetchInvoices(status: _statusFilter),
        repo.fetchCoupons(),
        repo.fetchRevenueReports(),
      ]);
      if (!mounted) return;
      setState(() {
        _invoices = results[0] as List<InvoiceItem>;
        _coupons = results[1] as List<CouponItem>;
        _report = results[2] as Map<String, dynamic>;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _openCreateInvoiceDialog() {
    if (widget.shops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Register a shop first.')));
      return;
    }
    String shopId = widget.shops.first.id;
    String planSlug = widget.plans.isNotEmpty ? widget.plans.first.slug : 'STANDARD';
    String method = 'BANK_TRANSFER';
    bool pendingVerify = false;
    final totalCtrl = TextEditingController(text: '5000');
    final discountCtrl = TextEditingController(text: '0');
    final paidCtrl = TextEditingController(text: '5000');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Create Invoice / Record Payment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: shopId,
                    decoration: const InputDecoration(labelText: 'Shop', border: OutlineInputBorder()),
                    items: widget.shops.map((s) => DropdownMenuItem(value: s.id, child: Text(s.shopName))).toList(),
                    onChanged: (v) => shopId = v ?? shopId,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: planSlug,
                    decoration: const InputDecoration(labelText: 'Plan', border: OutlineInputBorder()),
                    items: widget.plans.map((p) => DropdownMenuItem(value: p.slug, child: Text(p.name))).toList(),
                    onChanged: (v) => planSlug = v ?? planSlug,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: totalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total (Rs.)', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: discountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Paid Amount', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: method,
                          decoration: const InputDecoration(labelText: 'Method', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                            DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Bank Transfer')),
                            DropdownMenuItem(value: 'EASYPAISA', child: Text('Easypaisa')),
                            DropdownMenuItem(value: 'JAZZCASH', child: Text('JazzCash')),
                            DropdownMenuItem(value: 'ONLINE', child: Text('Online')),
                          ],
                          onChanged: (v) => method = v ?? 'BANK_TRANSFER',
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Requires Manual Verification', style: TextStyle(fontSize: 12)),
                    value: pendingVerify,
                    onChanged: (v) => setDlg(() => pendingVerify = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              onPressed: () async {
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await ShopRepository().createInvoice({
                    'shopId': shopId,
                    'planSlug': planSlug,
                    'totalAmount': int.tryParse(totalCtrl.text.trim()) ?? 0,
                    'discount': int.tryParse(discountCtrl.text.trim()) ?? 0,
                    'paidAmount': int.tryParse(paidCtrl.text.trim()) ?? 0,
                    'paymentMethod': method,
                    'pendingVerification': pendingVerify,
                  });
                  navigator.pop();
                  await _load();
                  messenger.showSnackBar(const SnackBar(content: Text('Invoice created!'), backgroundColor: AppColors.success));
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger));
                }
              },
              child: const Text('Create Invoice', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _openRecordPaymentDialog(InvoiceItem inv) {
    final amtCtrl = TextEditingController(text: '${inv.remainingAmount}');
    String method = inv.paymentMethod;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Receive Payment - ${inv.invoiceNumber}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (Rs.)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: method,
              decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Bank Transfer')),
                DropdownMenuItem(value: 'EASYPAISA', child: Text('Easypaisa')),
                DropdownMenuItem(value: 'JAZZCASH', child: Text('JazzCash')),
                DropdownMenuItem(value: 'ONLINE', child: Text('Online')),
              ],
              onChanged: (v) => method = v ?? method,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              await ShopRepository().recordInvoicePayment(inv.id, int.tryParse(amtCtrl.text.trim()) ?? 0, method);
              navigator.pop();
              await _load();
            },
            child: const Text('Record Payment', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openInvoiceReceiptDialog(InvoiceItem inv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Invoice ${inv.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shop: ${inv.shopName}', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Plan: ${inv.planSlug}'),
              Text('Date: ${inv.paymentDate}'),
              Text('Method: ${inv.paymentMethod}'),
              const Divider(height: 20),
              Text('Total Amount: Rs. ${inv.totalAmount}'),
              Text('Discount: Rs. ${inv.discount}'),
              Text('Paid Amount: Rs. ${inv.paidAmount}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              Text('Remaining Due: Rs. ${inv.remainingAmount}', style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Status: ${inv.paymentStatus}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _openCreateCouponDialog() {
    final codeCtrl = TextEditingController();
    final valCtrl = TextEditingController(text: '15');
    final limitCtrl = TextEditingController(text: '50');
    String type = 'PERCENTAGE';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Discount Coupon', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Coupon Code (e.g. WELCOME20)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: const InputDecoration(labelText: 'Discount Type', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'PERCENTAGE', child: Text('Percentage (%)')),
                DropdownMenuItem(value: 'FIXED', child: Text('Fixed Amount (Rs.)')),
              ],
              onChanged: (v) => type = v ?? 'PERCENTAGE',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: valCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: limitCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Usage Limit', border: OutlineInputBorder()))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              await ShopRepository().createCoupon({
                'code': codeCtrl.text.trim(),
                'discountType': type,
                'value': int.tryParse(valCtrl.text.trim()) ?? 10,
                'usageLimit': int.tryParse(limitCtrl.text.trim()) ?? 50,
              });
              navigator.pop();
              await _load();
            },
            child: const Text('Create Coupon', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [
                Tab(text: 'Payments & Invoices'),
                Tab(text: 'Coupons & Discounts'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'Monthly: Rs. ${_report['monthlyCollected'] ?? 0}  •  Yearly: Rs. ${_report['yearlyCollected'] ?? 0}  •  Due: Rs. ${_report['pendingDue'] ?? 0}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                                  onPressed: _openCreateInvoiceDialog,
                                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                  label: const Text('New Invoice', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: ['ALL', 'PAID', 'PARTIAL', 'UNPAID', 'PENDING_VERIFICATION', 'REFUNDED'].map((s) {
                                final sel = _statusFilter == s;
                                return ChoiceChip(
                                  label: Text(s, style: const TextStyle(fontSize: 10)),
                                  selected: sel,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(color: sel ? Colors.white : AppColors.textSecondary),
                                  onSelected: (v) {
                                    if (v) {
                                      setState(() => _statusFilter = s);
                                      _load();
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),
                            if (_invoices.isEmpty)
                              const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No invoices found.'))))
                            else
                              ..._invoices.map((inv) => Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('${inv.invoiceNumber} • ${inv.shopName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                              Text(inv.paymentStatus, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Total: Rs. ${inv.totalAmount} | Discount: Rs. ${inv.discount} | Paid: Rs. ${inv.paidAmount} | Due: Rs. ${inv.remainingAmount} (${inv.paymentMethod})',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: () => _openInvoiceReceiptDialog(inv),
                                                icon: const Icon(Icons.receipt_outlined, size: 14),
                                                label: const Text('Receipt', style: TextStyle(fontSize: 11)),
                                              ),
                                              if (inv.remainingAmount > 0 && inv.paymentStatus != 'REFUNDED')
                                                OutlinedButton(onPressed: () => _openRecordPaymentDialog(inv), child: const Text('Pay', style: TextStyle(fontSize: 11))),
                                              if (inv.paymentStatus == 'PENDING_VERIFICATION')
                                                OutlinedButton(
                                                  onPressed: () async {
                                                    await ShopRepository().verifyInvoicePayment(inv.id);
                                                    _load();
                                                  },
                                                  child: const Text('Verify', style: TextStyle(fontSize: 11)),
                                                ),
                                              if (inv.paymentStatus != 'REFUNDED')
                                                OutlinedButton(
                                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                                                  onPressed: () async {
                                                    await ShopRepository().refundInvoice(inv.id);
                                                    _load();
                                                  },
                                                  child: const Text('Refund', style: TextStyle(fontSize: 11)),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Discount Coupons', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                                  onPressed: _openCreateCouponDialog,
                                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                  label: const Text('New Coupon', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_coupons.isEmpty)
                              const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No coupons created yet.'))))
                            else
                              ..._coupons.map((c) => Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                                    child: ListTile(
                                      title: Text('${c.code} (${c.discountType == 'PERCENTAGE' ? '${c.value}%' : 'Rs. ${c.value}'})',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      subtitle: Text('Used: ${c.usedCount}/${c.usageLimit} • Expires: ${c.expiresAt}', style: const TextStyle(fontSize: 11)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Switch(
                                            value: c.isActive,
                                            onChanged: (_) async {
                                              await ShopRepository().toggleCoupon(c.id);
                                              _load();
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                                            onPressed: () async {
                                              await ShopRepository().deleteCoupon(c.id);
                                              _load();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
