import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/permission_guard.dart';
import '../../../core/constants/permissions.dart';

class RecentSaleItem {
  final String invoiceNo;
  final String customer;
  final String paymentMethod;
  final String total;
  final String status;
  final String time;
  final List<Map<String, dynamic>> items;

  RecentSaleItem({
    required this.invoiceNo,
    required this.customer,
    required this.paymentMethod,
    required this.total,
    required this.status,
    required this.time,
    required this.items,
  });
}

class LowStockAlertItem {
  final String name;
  final String category;
  int quantityLeft;
  final String unit;
  final Color badgeColor;

  LowStockAlertItem({
    required this.name,
    required this.category,
    required this.quantityLeft,
    required this.unit,
    required this.badgeColor,
  });
}

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const DashboardScreen({super.key, this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTimeframe = 'This Month';
  String _selectedBranch = 'Main Branch – Skardu';
  int _selectedBarIndex = 4; // Friday highlighted by default
  bool _isLoading = false;

  final List<String> _timeframes = ['Today', 'This Week', 'This Month', 'This Year'];
  final List<String> _branches = [
    'All Branches',
    'Main Branch – Skardu',
    'Gilgit Branch',
    'Islamabad Branch',
  ];

  late List<LowStockAlertItem> _lowStockItems;
  late List<RecentSaleItem> _recentSales;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _lowStockItems = [
      LowStockAlertItem(name: 'Cooking Oil 1L', category: 'Dalda - Groceries', quantityLeft: 4, unit: 'bottles', badgeColor: AppColors.danger),
      LowStockAlertItem(name: 'Milk Powder 500g', category: 'Dairy Fresh', quantityLeft: 6, unit: 'packs', badgeColor: AppColors.warning),
      LowStockAlertItem(name: 'Biscuits Pack', category: 'Luu Snacks', quantityLeft: 10, unit: 'boxes', badgeColor: AppColors.warning),
      LowStockAlertItem(name: 'Basmati Rice 5kg', category: 'Mehran Super', quantityLeft: 3, unit: 'bags', badgeColor: AppColors.danger),
    ];

    _recentSales = [
      RecentSaleItem(
        invoiceNo: 'INV-1001',
        customer: 'Walk-in Customer',
        paymentMethod: 'Cash',
        total: 'Rs. 24,500',
        status: 'Completed',
        time: '12 mins ago',
        items: [
          {'name': 'Basmati Rice 5kg', 'qty': 2, 'price': 'Rs. 3,500', 'subtotal': 'Rs. 7,000'},
          {'name': 'Cooking Oil 1L', 'qty': 3, 'price': 'Rs. 1,250', 'subtotal': 'Rs. 3,750'},
          {'name': 'Sugar 10kg', 'qty': 1, 'price': 'Rs. 1,600', 'subtotal': 'Rs. 1,600'},
          {'name': 'Dairy Milk Box', 'qty': 2, 'price': 'Rs. 6,075', 'subtotal': 'Rs. 12,150'},
        ],
      ),
      RecentSaleItem(
        invoiceNo: 'INV-1002',
        customer: 'Ali Khan',
        paymentMethod: 'Card',
        total: 'Rs. 18,750',
        status: 'Completed',
        time: '45 mins ago',
        items: [
          {'name': 'Detergent 5kg', 'qty': 2, 'price': 'Rs. 2,400', 'subtotal': 'Rs. 4,800'},
          {'name': 'Cooking Oil 5L', 'qty': 2, 'price': 'Rs. 6,975', 'subtotal': 'Rs. 13,950'},
        ],
      ),
      RecentSaleItem(
        invoiceNo: 'INV-1003',
        customer: 'Fatima Ali',
        paymentMethod: 'Cash',
        total: 'Rs. 12,400',
        status: 'Completed',
        time: '2 hours ago',
        items: [
          {'name': 'Tea 950g Pack', 'qty': 4, 'price': 'Rs. 1,850', 'subtotal': 'Rs. 7,400'},
          {'name': 'Noodles Carton', 'qty': 1, 'price': 'Rs. 5,000', 'subtotal': 'Rs. 5,000'},
        ],
      ),
      RecentSaleItem(
        invoiceNo: 'INV-1004',
        customer: 'Usman Raza',
        paymentMethod: 'Online / EasyPaisa',
        total: 'Rs. 8,950',
        status: 'Completed',
        time: '3 hours ago',
        items: [
          {'name': 'Milk Powder 500g', 'qty': 5, 'price': 'Rs. 1,790', 'subtotal': 'Rs. 8,950'},
        ],
      ),
    ];
  }

  // Dynamic Metrics based on Timeframe and Branch
  Map<String, String> _getMetrics() {
    switch (_selectedTimeframe) {
      case 'Today':
        return {
          'todaySales': 'Rs. 24,500',
          'totalRevenue': 'Rs. 24,500',
          'totalOrders': '48',
          'profit': 'Rs. 9,800',
          'trend': '+14.2% vs yesterday',
          'margin': '40.0% margin',
        };
      case 'This Week':
        return {
          'todaySales': 'Rs. 112,400',
          'totalRevenue': 'Rs. 112,400',
          'totalOrders': '210',
          'profit': 'Rs. 44,960',
          'trend': '+9.8% vs last week',
          'margin': '39.2% margin',
        };
      case 'This Year':
        return {
          'todaySales': 'Rs. 2,850,000',
          'totalRevenue': 'Rs. 2,850,000',
          'totalOrders': '4,820',
          'profit': 'Rs. 1,140,000',
          'trend': '+28.4% YoY Growth',
          'margin': '40.0% margin',
        };
      case 'This Month':
      default:
        return {
          'todaySales': 'Rs. 24,500',
          'totalRevenue': 'Rs. 220,750',
          'totalOrders': '350',
          'profit': 'Rs. 88,420',
          'trend': '+8.4% this month',
          'margin': '38.5% margin',
        };
    }
  }

  Future<void> _refreshDashboard() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard metrics updated successfully!'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _showRestockDialog(LowStockAlertItem item) {
    int addQty = 20;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_shopping_cart, color: AppColors.secondary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quick Restock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(item.name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Current Stock:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text(
                        '${item.quantityLeft} ${item.unit}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: item.badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Add Quantity:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: addQty > 5 ? () => setDlgState(() => addQty -= 5) : null,
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+$addQty',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setDlgState(() => addQty += 5),
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [10, 25, 50, 100].map((val) {
                    return ChoiceChip(
                      label: Text('+$val'),
                      selected: addQty == val,
                      selectedColor: AppColors.secondary.withValues(alpha: 0.2),
                      onSelected: (selected) {
                        if (selected) setDlgState(() => addQty = val);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                setState(() {
                  item.quantityLeft += addQty;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Restocked ${item.name} with +$addQty units. New stock: ${item.quantityLeft}!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Confirm Restock', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceDetailsDialog(RecentSaleItem sale) {
    showDialog(
      context: context,
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(sale.invoiceNo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sale.status,
                  style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 440,
              maxHeight: screenHeight * 0.72,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Customer: ${sale.customer}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      Text(sale.time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Payment: ${sale.paymentMethod}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const Divider(height: 20, color: AppColors.border),
                  const Text('ITEMS PURCHASED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  ...sale.items.map((it) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('${it['name']} x${it['qty']}', style: const TextStyle(fontSize: 12)),
                            ),
                            Text(it['subtotal'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )),
                  const Divider(height: 20, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Grand Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(
                        sale.total,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Share'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invoice ${sale.invoiceNo} link copied to clipboard!')),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.print, size: 16, color: Colors.white),
            label: const Text('Print Receipt', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Receipt printed for ${sale.invoiceNo}')),
              );
            },
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final isTablet = constraints.maxWidth >= 700 && constraints.maxWidth < 1100;
        final metrics = _getMetrics();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: _refreshDashboard,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isMobile ? 12.0 : 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading) const LinearProgressIndicator(color: AppColors.secondary),
                  // 1. MOBILE APP HEADER & HERO (Matching Mobile App UI from Design Sheet)
                  if (isMobile) ...[
                    _buildMobileHeroHeader(metrics),
                    const SizedBox(height: 16),
                    _buildMobileQuickActions(),
                    const SizedBox(height: 16),
                    _buildTimeframePills(),
                    const SizedBox(height: 16),
                  ],

                  // 2. DESKTOP / TABLET TOP ROW
                  if (!isMobile) ...[
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning, Ali Khan!',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: isTablet ? 19 : 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Here's your shop performance overview for $_selectedBranch.",
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            // Branch Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedBranch,
                                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedBranch = val);
                                  },
                                  items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                                ),
                              ),
                            ),
                            // Timeframe Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedTimeframe,
                                  icon: const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedTimeframe = val);
                                  },
                                  items: _timeframes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 3. 4 KEY METRIC CARDS (Responsive Grid)
                  LayoutBuilder(
                    builder: (ctx, kpiConstraints) {
                      final width = kpiConstraints.maxWidth;
                      int crossAxisCount = width < 580 ? 2 : (width < 1100 ? 2 : 4);
                      double childAspectRatio = width < 480 ? 1.25 : (width < 700 ? 1.35 : 1.6);

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                        children: [
                          _buildKpiCard(
                            title: "Today's Sales",
                            amount: metrics['todaySales']!,
                            icon: Icons.shopping_bag_outlined,
                            color: AppColors.secondary,
                            trend: metrics['trend']!,
                          ),
                          _buildKpiCard(
                            title: 'Total Revenue',
                            amount: metrics['totalRevenue']!,
                            icon: Icons.account_balance_wallet_outlined,
                            color: AppColors.primary,
                            trend: '+8.4% vs last period',
                          ),
                          _buildKpiCard(
                            title: 'Total Orders',
                            amount: metrics['totalOrders']!,
                            icon: Icons.check_circle_outline,
                            color: AppColors.success,
                            trend: '${metrics['totalOrders']} orders completed',
                          ),
                          PermissionGuard(
                            permission: AppPermissions.dashboardViewProfit,
                            fallback: _buildKpiCard(
                              title: 'Net Profit',
                              amount: 'Restricted',
                              icon: Icons.lock_outline,
                              color: AppColors.textMuted,
                              trend: 'Requires authorization',
                            ),
                            child: _buildKpiCard(
                              title: 'Net Profit',
                              amount: metrics['profit']!,
                              icon: Icons.trending_up,
                              color: const Color(0xFF7C3AED),
                              trend: metrics['margin']!,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // 4. PERFORMANCE CHARTS (Interactive Bar + Area Chart)
                  LayoutBuilder(
                    builder: (ctx, chartConstraints) {
                      if (chartConstraints.maxWidth < 850) {
                        return Column(
                          children: [
                            _buildInteractiveWeeklySalesCard(),
                            const SizedBox(height: 16),
                            _buildSalesVsExpensesCard(),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: _buildInteractiveWeeklySalesCard()),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: _buildSalesVsExpensesCard()),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // 5. RECENT SALES & LOW STOCK ALERTS
                  LayoutBuilder(
                    builder: (ctx, rowConstraints) {
                      final isNarrow = rowConstraints.maxWidth < 850;
                      if (isNarrow) {
                        return Column(
                          children: [
                            _buildRecentSalesCard(isMobile),
                            const SizedBox(height: 16),
                            _buildLowStockCard(),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildRecentSalesCard(isMobile)),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: _buildLowStockCard()),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildMobileHeroHeader(Map<String, String> metrics) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF101C30), Color(0xFF123B8B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123B8B).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront, color: AppColors.secondary, size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'ABC Supermarket',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: AppColors.secondary, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _selectedBranch.replaceAll('Main Branch – ', ''),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Today's Sales ($_selectedTimeframe)",
            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    metrics['todaySales']!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  metrics['trend']!.split(' ').take(2).join(' '),
                  style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeroStat('Orders', metrics['totalOrders']!),
                const Text('|', style: TextStyle(color: Colors.white24)),
                _buildHeroStat('Margin', metrics['margin']!.split(' ')[0]),
                const Text('|', style: TextStyle(color: Colors.white24)),
                _buildHeroStat('Status', 'Online'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String title, String val) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMobileQuickActions() {
    return Row(
      children: [
        _buildActionTile('POS', Icons.point_of_sale, AppColors.primary, () => widget.onNavigate?.call(1)),
        const SizedBox(width: 10),
        _buildActionTile('Products', Icons.inventory_2, AppColors.secondary, () => widget.onNavigate?.call(2)),
        const SizedBox(width: 10),
        _buildActionTile('Sales', Icons.receipt_long, AppColors.success, () => widget.onNavigate?.call(4)),
        const SizedBox(width: 10),
        _buildActionTile('Reports', Icons.auto_graph, const Color(0xFF0284C7), () => widget.onNavigate?.call(6)),
      ],
    );
  }

  Widget _buildActionTile(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframePills() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _timeframes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (ctx, idx) {
          final t = _timeframes[idx];
          final isSelected = t == _selectedTimeframe;
          return ChoiceChip(
            label: Text(t),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
            onSelected: (val) {
              if (val) setState(() => _selectedTimeframe = t);
            },
          );
        },
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 15, color: color),
                ),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              trend,
              style: TextStyle(
                fontSize: 10,
                color: trend.contains('+') ? AppColors.success : AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveWeeklySalesCard() {
    final days = [
      {'day': 'Mon', 'height': 45.0, 'amount': 'Rs. 18,200', 'orders': '34'},
      {'day': 'Tue', 'height': 70.0, 'amount': 'Rs. 26,400', 'orders': '45'},
      {'day': 'Wed', 'height': 55.0, 'amount': 'Rs. 21,100', 'orders': '38'},
      {'day': 'Thu', 'height': 85.0, 'amount': 'Rs. 31,500', 'orders': '52'},
      {'day': 'Fri', 'height': 95.0, 'amount': 'Rs. 38,200', 'orders': '64'},
      {'day': 'Sat', 'height': 75.0, 'amount': 'Rs. 29,800', 'orders': '49'},
      {'day': 'Sun', 'height': 60.0, 'amount': 'Rs. 23,600', 'orders': '41'},
    ];

    final activeDay = days[_selectedBarIndex];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Sales',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Selected: ${activeDay['day']} • ${activeDay['amount']} (${activeDay['orders']} orders)',
                      style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                  child: const Text('Last 7 Days', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 155,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(days.length, (idx) {
                  final it = days[idx];
                  final isSelected = idx == _selectedBarIndex;
                  return InkWell(
                    onTap: () => setState(() => _selectedBarIndex = idx),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              it['orders'] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        Container(
                          width: isSelected ? 24 : 18,
                          height: it['height'] as double,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.secondary : AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          it['day'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesVsExpensesCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sales vs Expenses',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Row(
                  children: [
                    _buildLegend('Sales', AppColors.primary),
                    const SizedBox(width: 12),
                    _buildLegend('Expenses', AppColors.secondary),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(
                painter: _SalesExpensesChartPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSalesCard(bool isMobile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Sales',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () => widget.onNavigate?.call(4),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // NATIVE MOBILE LIST TILES (Touch-optimized, no sideways scroll)
            if (isMobile) ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentSales.length,
                separatorBuilder: (context, index) => const Divider(height: 14, color: AppColors.borderLight),
                itemBuilder: (ctx, idx) {
                  final sale = _recentSales[idx];
                  return InkWell(
                    onTap: () => _showInvoiceDetailsDialog(sale),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(sale.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                                    const SizedBox(width: 6),
                                    Text('• ${sale.time}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(sale.customer, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(sale.total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(sale.paymentMethod, style: const TextStyle(fontSize: 9, color: AppColors.success, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            // DESKTOP TABLE VIEW
            if (!isMobile) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Expanded(flex: 2, child: Text('INVOICE', style: _tblHeaderStyle)),
                    Expanded(flex: 3, child: Text('CUSTOMER', style: _tblHeaderStyle)),
                    Expanded(flex: 2, child: Text('PAYMENT', style: _tblHeaderStyle)),
                    Expanded(flex: 2, child: Text('TOTAL', style: _tblHeaderStyle)),
                    Expanded(flex: 2, child: Text('ACTION', style: _tblHeaderStyle)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              ..._recentSales.map((sale) => InkWell(
                    onTap: () => _showInvoiceDetailsDialog(sale),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(sale.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary))),
                          Expanded(flex: 3, child: Text(sale.customer, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                          Expanded(flex: 2, child: Text(sale.paymentMethod, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                          Expanded(flex: 2, child: Text(sale.total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary))),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.visibility, size: 14),
                                label: const Text('View', style: TextStyle(fontSize: 11)),
                                onPressed: () => _showInvoiceDetailsDialog(sale),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Low Stock Alerts',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_lowStockItems.length} Critical',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lowStockItems.length,
              separatorBuilder: (context, index) => const Divider(height: 16, color: AppColors.borderLight),
              itemBuilder: (ctx, idx) {
                final item = _lowStockItems[idx];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(item.category, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.badgeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.quantityLeft} left',
                            style: TextStyle(color: item.badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart, size: 18, color: AppColors.secondary),
                          tooltip: 'Quick Restock',
                          onPressed: () => _showRestockDialog(item),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

const TextStyle _tblHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.bold,
  color: AppColors.textSecondary,
);

class _SalesExpensesChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final salesPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final sPath = Path();
    sPath.moveTo(0, size.height * 0.7);
    sPath.quadraticBezierTo(size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.5);
    sPath.quadraticBezierTo(size.width * 0.75, size.height * 0.2, size.width, size.height * 0.3);
    canvas.drawPath(sPath, salesPaint);

    final expPaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final ePath = Path();
    ePath.moveTo(0, size.height * 0.85);
    ePath.quadraticBezierTo(size.width * 0.25, size.height * 0.7, size.width * 0.5, size.height * 0.75);
    ePath.quadraticBezierTo(size.width * 0.75, size.height * 0.6, size.width, size.height * 0.65);
    canvas.drawPath(ePath, expPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
