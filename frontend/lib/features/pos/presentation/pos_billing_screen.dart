import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/permission_guard.dart';
import '../../../core/constants/permissions.dart';
import '../../../core/widgets/responsive_layout.dart';

class PosProductItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String sku;
  final IconData icon;

  PosProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.sku,
    required this.icon,
  });
}

class CartItem {
  final PosProductItem product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

class PosBillingScreen extends StatefulWidget {
  const PosBillingScreen({super.key});

  @override
  State<PosBillingScreen> createState() => _PosBillingScreenState();
}

class _PosBillingScreenState extends State<PosBillingScreen> {
  final List<PosProductItem> _catalog = [
    PosProductItem(id: '1', name: 'Rice 5kg', category: 'Groceries', price: 120, sku: 'RCK001', icon: Icons.grain),
    PosProductItem(id: '2', name: 'Sugar 1kg', category: 'Groceries', price: 50, sku: 'SUG001', icon: Icons.kitchen),
    PosProductItem(id: '3', name: 'Milk 1L', category: 'Beverages', price: 40, sku: 'MIL001', icon: Icons.local_drink),
    PosProductItem(id: '4', name: 'Cooking Oil 1L', category: 'Groceries', price: 500, sku: 'OIL001', icon: Icons.opacity),
    PosProductItem(id: '5', name: 'Biscuits', category: 'Snacks', price: 120, sku: 'BIS001', icon: Icons.cookie),
    PosProductItem(id: '6', name: 'Tea 250g', category: 'Groceries', price: 250, sku: 'TEA001', icon: Icons.emoji_food_beverage),
    PosProductItem(id: '7', name: 'Noodles', category: 'Snacks', price: 60, sku: 'NOD001', icon: Icons.ramen_dining),
    PosProductItem(id: '8', name: 'Detergent', category: 'Others', price: 350, sku: 'DET001', icon: Icons.cleaning_services),
  ];

  final List<CartItem> _cart = [];
  String _selectedCategory = 'All';
  String _search = '';
  double _discountPercent = 0;
  String _selectedCustomer = 'Walk-in Customer';

  int get totalItemsCount => _cart.fold(0, (acc, item) => acc + item.quantity);
  double get subtotal => _cart.fold(0, (acc, item) => acc + item.total);
  double get discountAmount => (subtotal * _discountPercent) / 100;
  double get grandTotal => subtotal - discountAmount;

  void _addToCart(PosProductItem product) {
    setState(() {
      final existing = _cart.indexWhere((c) => c.product.id == product.id);
      if (existing >= 0) {
        _cart[existing].quantity += 1;
      } else {
        _cart.add(CartItem(product: product));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final filtered = _catalog.where((p) {
      final matchCat = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchSearch = p.name.toLowerCase().contains(_search.toLowerCase()) ||
          p.sku.toLowerCase().contains(_search.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    // Products Catalog Grid Widget
    final productsCatalog = Padding(
      padding: EdgeInsets.all(isMobile ? 14.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Search & Category Filter
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                      hintText: 'Search products by name or SKU...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (val) => setState(() => _search = val),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                tooltip: 'Barcode Scanner',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Categories Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Groceries', 'Beverages', 'Snacks', 'Others'].map((cat) {
                final isSel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Responsive Products Grid
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                int cols = 4;
                if (constraints.maxWidth < 500) {
                  cols = 2;
                } else if (constraints.maxWidth < 900) {
                  cols = 3;
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final prod = filtered[index];
                    return _buildProductCard(prod);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    // Cart Panel Widget
    final cartPanel = Container(
      width: isMobile ? double.infinity : 380,
      decoration: BoxDecoration(
        color: Colors.white,
        border: isMobile ? null : const Border(left: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cart Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Invoice #INV-1001',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                  ),
                  Text(
                    'Terminal: Counter 01',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _selectedCustomer,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'Walk-in Customer', child: Text('Walk-in Customer')),
                  DropdownMenuItem(value: 'Ali Khan (0300-1234567)', child: Text('Ali Khan')),
                  DropdownMenuItem(value: 'Usman Raza', child: Text('Usman Raza')),
                ],
                onChanged: (val) => setState(() => _selectedCustomer = val ?? _selectedCustomer),
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.border),

          // Cart Items List
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shopping_cart_outlined, size: 42, color: AppColors.textMuted),
                        SizedBox(height: 8),
                        Text('Cart is Empty', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Tap items to add to cart.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _cart.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 10, color: AppColors.borderLight),
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                                ),
                                Text(
                                  'Rs. ${item.product.price.toStringAsFixed(0)} each',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 16),
                                onPressed: () {
                                  setState(() {
                                    if (item.quantity > 1) {
                                      item.quantity -= 1;
                                    } else {
                                      _cart.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 16),
                                onPressed: () {
                                  setState(() {
                                    item.quantity += 1;
                                  });
                                },
                              ),
                            ],
                          ),
                          Text(
                            'Rs. ${item.total.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const Divider(height: 16, color: AppColors.border),

          // Calculations
          _buildCalcRow('Subtotal', 'Rs. ${subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Discount (%):', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 44,
                    height: 26,
                    child: TextField(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() {
                          _discountPercent = double.tryParse(val) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Text(
                '- Rs. ${discountAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (_discountPercent > 10) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(4)),
              child: const Text(
                'Discount > 10% requires Manager Approval!',
                style: TextStyle(color: Color(0xFFB45309), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          const SizedBox(height: 4),
          _buildCalcRow('Tax (0%)', 'Rs. 0'),
          const Divider(height: 12, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(
                'Rs. ${grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _cart.clear()),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _cart.isEmpty ? null : () {},
                  child: const Text('Hold'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          PermissionGuard(
            permission: AppPermissions.posCreate,
            fallback: const Center(child: Text('Cashier permissions required')),
            child: ElevatedButton(
              onPressed: _cart.isEmpty ? null : () => _showPaymentDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Pay Now →',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );

    // On Mobile: Full width catalog with floating bottom checkout button matching Mobile App UI in Image 1
    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            productsCatalog,
            if (_cart.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: InkWell(
                  onTap: () => _openMobileCartBottomSheet(context, cartPanel),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.secondary, // Orange Floating Checkout Bar
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Cart ($totalItemsCount items)',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Text(
                          'Rs. ${grandTotal.toStringAsFixed(0)}  •  Checkout →',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // On Desktop & Tablet: Side-by-side
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: productsCatalog),
          cartPanel,
        ],
      ),
    );
  }

  Widget _buildProductCard(PosProductItem item) {
    return InkWell(
      onTap: () => _addToCart(item),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Rs. ${item.price.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildCalcRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  void _openMobileCartBottomSheet(BuildContext context, Widget cartPanelWidget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.85,
        child: cartPanelWidget,
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount to Pay: Rs. ${grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Select Payment Method:'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPaymentOption(Icons.money, 'Cash'),
                _buildPaymentOption(Icons.credit_card, 'Card'),
                _buildPaymentOption(Icons.account_balance, 'Bank'),
                _buildPaymentOption(Icons.qr_code, 'UPI'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _cart.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text('Sale completed successfully! Receipt sent to thermal printer.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            child: const Text('Confirm & Print Receipt'),
          ),
        ],
      ),
    );
  }

  static Widget _buildPaymentOption(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
