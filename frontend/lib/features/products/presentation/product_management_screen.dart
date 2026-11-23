import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/permission_guard.dart';
import '../../../core/constants/permissions.dart';

class ProductItemModel {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int stock;
  final double sellingPrice;
  final double? purchasePrice;
  final String status;
  final IconData icon;

  ProductItemModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.stock,
    required this.sellingPrice,
    this.purchasePrice,
    required this.status,
    required this.icon,
  });
}

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final List<ProductItemModel> _products = [
    ProductItemModel(id: '1', name: 'Rice 5kg', sku: 'RCK001', category: 'Groceries', stock: 120, sellingPrice: 120, purchasePrice: 90, status: 'In Stock', icon: Icons.grain),
    ProductItemModel(id: '2', name: 'Sugar 1kg', sku: 'SUG001', category: 'Groceries', stock: 50, sellingPrice: 50, purchasePrice: 38, status: 'In Stock', icon: Icons.kitchen),
    ProductItemModel(id: '3', name: 'Milk 1L', sku: 'MIL001', category: 'Daily', stock: 25, sellingPrice: 40, purchasePrice: 30, status: 'In Stock', icon: Icons.local_drink),
    ProductItemModel(id: '4', name: 'Cooking Oil 1L', sku: 'OIL001', category: 'Groceries', stock: 4, sellingPrice: 500, purchasePrice: 420, status: 'Low Stock', icon: Icons.opacity),
    ProductItemModel(id: '5', name: 'Biscuits', sku: 'BIS001', category: 'Snacks', stock: 0, sellingPrice: 120, purchasePrice: 90, status: 'Out of Stock', icon: Icons.cookie),
  ];

  String _search = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final filtered = _products.where((p) {
      final matchCat = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchSearch = p.name.toLowerCase().contains(_search.toLowerCase()) ||
          p.sku.toLowerCase().contains(_search.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Action Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Products',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage product catalog, inventory status and pricing',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                PermissionGuard(
                  permission: AppPermissions.productsCreate,
                  child: ElevatedButton.icon(
                    onPressed: () => _openAddProductDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('+ Add Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary, // Orange button from image
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Top Stat Cards matching Image 1
            Row(
              children: [
                _buildStatCard('Total Products', '245', Icons.inventory_2_outlined, AppColors.primary),
                const SizedBox(width: 14),
                _buildStatCard('Active', '220', Icons.check_circle_outline, AppColors.success),
                const SizedBox(width: 14),
                _buildStatCard('Low Stock', '15', Icons.warning_amber_rounded, AppColors.warning),
                const SizedBox(width: 14),
                _buildStatCard('Out of Stock', '7', Icons.cancel_outlined, AppColors.danger),
                const SizedBox(width: 14),
                _buildStatCard('Inventory Value', 'Rs. 640,500', Icons.account_balance_wallet_outlined, const Color(0xFF6366F1)),
              ],
            ),
            const SizedBox(height: 18),

            // Filter Bar with Search, Categories, and Brands dropdowns
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                          hintText: 'Search products by name or SKU...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onChanged: (val) => setState(() => _search = val),
                      ),
                    ),
                    const VerticalDivider(width: 24),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All Categories')),
                          DropdownMenuItem(value: 'Groceries', child: Text('Groceries')),
                          DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                          DropdownMenuItem(value: 'Snacks', child: Text('Snacks')),
                        ],
                        onChanged: (val) => setState(() => _selectedCategory = val ?? 'All'),
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const VerticalDivider(width: 24),
                    const Text('All Brands', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Products Table matching Image 1
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                        child: const Row(
                          children: [
                            Expanded(flex: 1, child: Text('IMAGE', style: _tblHeaderStyle)),
                            Expanded(flex: 3, child: Text('NAME', style: _tblHeaderStyle)),
                            Expanded(flex: 2, child: Text('SKU', style: _tblHeaderStyle)),
                            Expanded(flex: 2, child: Text('CATEGORY', style: _tblHeaderStyle)),
                            Expanded(flex: 2, child: Text('STOCK', style: _tblHeaderStyle)),
                            Expanded(flex: 2, child: Text('PRICE', style: _tblHeaderStyle)),
                            Expanded(flex: 2, child: Text('STATUS', style: _tblHeaderStyle)),
                            Expanded(flex: 1, child: Text('ACTION', style: _tblHeaderStyle)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.borderLight),
                          itemBuilder: (context, index) {
                            final prod = filtered[index];
                            final isLow = prod.status == 'Low Stock';
                            final isOut = prod.status == 'Out of Stock';
                            final color = isOut ? AppColors.danger : (isLow ? AppColors.warning : AppColors.success);

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(prod.icon, color: AppColors.primary, size: 20),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                                  ),
                                  Expanded(flex: 2, child: Text(prod.sku, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                                  Expanded(flex: 2, child: Text(prod.category, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
                                  Expanded(flex: 2, child: Text('${prod.stock}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                  Expanded(
                                    flex: 2,
                                    child: Text('Rs. ${prod.sellingPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                        child: Text(prod.status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.textSecondary),
                                      onPressed: () {},
                                      tooltip: 'Edit Product',
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

  static Widget _buildStatCard(String label, String count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(count, style: TextStyle(fontFamily: 'Poppins', fontSize: 19, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Product'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(decoration: InputDecoration(labelText: 'Product Name')),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'SKU / Barcode')),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Selling Price (Rs.)')),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Initial Stock Quantity')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            child: const Text('Save Product'),
          ),
        ],
      ),
    );
  }
}

const TextStyle _tblHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.bold,
  color: AppColors.textSecondary,
);
