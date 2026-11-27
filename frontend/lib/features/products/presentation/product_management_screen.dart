import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  factory ProductItemModel.fromMap(Map<String, dynamic> map) {
    final stock = (map['currentStock'] as num?)?.toInt() ?? 0;
    final rawStatus = (map['status'] ?? 'ACTIVE').toString().toUpperCase();
    String displayStatus = 'In Stock';
    if (stock <= 0 || rawStatus == 'OUT_OF_STOCK') {
      displayStatus = 'Out of Stock';
    } else if (stock <= 5 || rawStatus == 'LOW_STOCK') {
      displayStatus = 'Low Stock';
    }
    return ProductItemModel(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      sku: (map['sku'] ?? '').toString(),
      category: (map['category'] ?? 'General').toString(),
      stock: stock,
      sellingPrice: (map['sellingPrice'] as num?)?.toDouble() ?? 0,
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble(),
      status: displayStatus,
      icon: Icons.inventory_2_outlined,
    );
  }
}

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  static const String _baseUrl = 'http://localhost:5002/api/products';
  List<ProductItemModel> _products = [];
  List<Map<String, dynamic>> _categoryItems = [];
  List<String> _categories = [];
  bool _loading = true;
  String? _apiError;
  String _search = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final h = await _headers();
      final results = await Future.wait([
        http.get(Uri.parse(_baseUrl), headers: h),
        http.get(Uri.parse('$_baseUrl/categories'), headers: h),
      ]);

      final prodRes = results[0];
      final catRes = results[1];

      final List<ProductItemModel> loadedProducts = [];
      String? errMsg;
      if (prodRes.statusCode == 200) {
        final body = jsonDecode(prodRes.body) as Map<String, dynamic>;
        final list = (body['data'] as List?) ?? [];
        loadedProducts.addAll(list.map((e) => ProductItemModel.fromMap(e as Map<String, dynamic>)));
      } else {
        try {
          errMsg = (jsonDecode(prodRes.body)['message'] ?? 'Error ${prodRes.statusCode}').toString();
        } catch (_) {
          errMsg = 'HTTP ${prodRes.statusCode}';
        }
      }

      final Set<String> loadedCats = {};
      final List<Map<String, dynamic>> loadedCatItems = [];
      if (catRes.statusCode == 200) {
        final body = jsonDecode(catRes.body) as Map<String, dynamic>;
        final list = (body['data'] as List?) ?? [];
        for (final c in list) {
          final map = c as Map<String, dynamic>;
          final name = (map['name'] ?? '').toString().trim();
          if (name.isNotEmpty) {
            loadedCats.add(name);
            loadedCatItems.add(map);
          }
        }
      }
      for (final p in loadedProducts) {
        if (p.category.isNotEmpty) loadedCats.add(p.category);
      }

      if (!mounted) return;
      setState(() {
        _products = loadedProducts;
        _categoryItems = loadedCatItems;
        _categories = loadedCats.toList()..sort();
        _apiError = errMsg;
        if (_selectedCategory != 'All' && !_categories.contains(_selectedCategory)) {
          _selectedCategory = 'All';
        }
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _products.where((p) {
      final matchCat = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchSearch = p.name.toLowerCase().contains(_search.toLowerCase()) ||
          p.sku.toLowerCase().contains(_search.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    final totalCount = _products.length;
    final activeCount = _products.where((p) => p.status == 'In Stock').length;
    final lowCount = _products.where((p) => p.status == 'Low Stock').length;
    final outCount = _products.where((p) => p.status == 'Out of Stock').length;
    final inventoryValue = _products.fold<double>(0, (sum, p) => sum + (p.sellingPrice * p.stock));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                      Text(
                        'Products & Categories',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage product catalog, categories, inventory status and pricing',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  PermissionGuard(
                    permission: AppPermissions.productsCreate,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _openAddOrEditCategoryDialog(context),
                          icon: const Icon(Icons.category_outlined, size: 18),
                          label: const Text('+ Add Category'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _openProductFormDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('+ Add Product'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.secondary,
                tabs: [
                  Tab(icon: Icon(Icons.inventory_2_outlined, size: 18), text: 'Products'),
                  Tab(icon: Icon(Icons.category_outlined, size: 18), text: 'Categories'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard('Total Products', '$totalCount', Icons.inventory_2_outlined, AppColors.primary),
                  const SizedBox(width: 12),
                  _buildStatCard('Active', '$activeCount', Icons.check_circle_outline, AppColors.success),
                  const SizedBox(width: 12),
                  _buildStatCard('Low Stock', '$lowCount', Icons.warning_amber_rounded, AppColors.warning),
                  const SizedBox(width: 12),
                  _buildStatCard('Out of Stock', '$outCount', Icons.cancel_outlined, AppColors.danger),
                  const SizedBox(width: 12),
                  _buildStatCard('Inventory Value', 'Rs. ${inventoryValue.toStringAsFixed(0)}', Icons.account_balance_wallet_outlined, const Color(0xFF6366F1)),
                ],
              ),
            ),
            const SizedBox(height: 18),

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
                        items: [
                          const DropdownMenuItem(value: 'All', child: Text('All Categories')),
                          ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                        ],
                        onChanged: (val) => setState(() => _selectedCategory = val ?? 'All'),
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

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
                            Expanded(flex: 2, child: Text('ACTION', style: _tblHeaderStyle)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _apiError != null
                                ? Center(
                                    child: Text(
                                      'API Error: $_apiError',
                                      style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                                    ),
                                  )
                                : filtered.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No products found in database. Add a category and product to get started.',
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  )
                                : LayoutBuilder(
                                    builder: (ctx, box) {
                                      final isNarrow = box.maxWidth < 680;
                                      return ListView.separated(
                                        itemCount: filtered.length,
                                        separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.borderLight),
                                        itemBuilder: (context, index) {
                                          final prod = filtered[index];
                                          final isLow = prod.status == 'Low Stock';
                                          final isOut = prod.status == 'Out of Stock';
                                          final color = isOut ? AppColors.danger : (isLow ? AppColors.warning : AppColors.success);

                                          if (isNarrow) {
                                            return ListTile(
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              leading: CircleAvatar(
                                                backgroundColor: AppColors.primaryLight,
                                                child: Icon(prod.icon, color: AppColors.primary, size: 18),
                                              ),
                                              title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                              subtitle: Text('${prod.category} • SKU: ${prod.sku} • Stock: ${prod.stock}', style: const TextStyle(fontSize: 11)),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Rs. ${prod.sellingPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                                                  IconButton(
                                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                                    onPressed: () => _openProductFormDialog(context, existing: prod),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                                    onPressed: () => _confirmDeleteProduct(prod),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

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
                                                  flex: 2,
                                                  child: Wrap(
                                                    spacing: 4,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.primary),
                                                        tooltip: 'Edit Product',
                                                        onPressed: () => _openProductFormDialog(context, existing: prod),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete_outline, size: 17, color: AppColors.danger),
                                                        tooltip: 'Delete Product',
                                                        onPressed: () => _confirmDeleteProduct(prod),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
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
                    _buildCategoriesTab(),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildCategoriesTab() {
    if (_loading) return const Center(child: CircularProgressIndicator());
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
                Text(
                  'All Categories (${_categoryItems.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openAddOrEditCategoryDialog(context),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text('Add Category', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _categoryItems.isEmpty
                  ? const Center(
                      child: Text('No categories yet. Click "Add Category" to create one.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : ListView.separated(
                      itemCount: _categoryItems.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
                      itemBuilder: (_, i) {
                        final cat = _categoryItems[i];
                        final id = (cat['_id'] ?? cat['id']).toString();
                        final name = (cat['name'] ?? '').toString();
                        final productCount = _products.where((p) => p.category == name).length;
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.category_outlined, color: AppColors.primary, size: 20),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('$productCount products', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                tooltip: 'Edit Category',
                                onPressed: () => _openAddOrEditCategoryDialog(context, existingId: id, existingName: name),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                tooltip: 'Delete Category',
                                onPressed: () async {
                                  final res = await http.delete(Uri.parse('$_baseUrl/categories/$id'), headers: await _headers());
                                  if (res.statusCode == 200) await _loadData();
                                },
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
    );
  }

  void _openAddOrEditCategoryDialog(BuildContext context, {String? existingId, String? existingName}) {
    final isEdit = existingId != null;
    final ctrl = TextEditingController(text: existingName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Category' : 'Add Category'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Category Name', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              final nav = Navigator.of(ctx);
              final res = isEdit
                  ? await http.put(Uri.parse('$_baseUrl/categories/$existingId'), headers: await _headers(), body: jsonEncode({'name': name}))
                  : await http.post(Uri.parse('$_baseUrl/categories'), headers: await _headers(), body: jsonEncode({'name': name}));
              if (res.statusCode == 200 || res.statusCode == 201) {
                nav.pop();
                await _loadData();
              }
            },
            child: Text(isEdit ? 'Update' : 'Save', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatCard(String label, String count, IconData icon, Color color) {
    return SizedBox(
      width: 195,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(count, style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
                  ],
                ),
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

  void _confirmDeleteProduct(ProductItemModel prod) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Delete "${prod.name}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final msg = ScaffoldMessenger.of(context);
              final res = await http.delete(Uri.parse('$_baseUrl/${prod.id}'), headers: await _headers());
              nav.pop();
              if (res.statusCode == 200) {
                await _loadData();
                msg.showSnackBar(SnackBar(content: Text('Deleted ${prod.name}'), backgroundColor: AppColors.danger));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openProductFormDialog(BuildContext context, {ProductItemModel? existing}) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final skuCtrl = TextEditingController(text: existing?.sku ?? '');
    final priceCtrl = TextEditingController(text: existing != null ? existing.sellingPrice.toStringAsFixed(0) : '');
    final costCtrl = TextEditingController(text: existing?.purchasePrice?.toStringAsFixed(0) ?? '');
    final stockCtrl = TextEditingController(text: '${existing?.stock ?? 0}');
    String selectedCat = existing?.category ?? (_categories.isNotEmpty ? _categories.first : 'General');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Product' : 'Add Product'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU / Barcode', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _categories.contains(selectedCat) ? selectedCat : null,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: (_categories.isEmpty ? ['General'] : _categories)
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedCat = v ?? 'General'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Selling Price (Rs.)', border: OutlineInputBorder()))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Purchase Price (Rs.)', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Initial Stock Quantity', border: OutlineInputBorder())),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final sku = skuCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                final cost = double.tryParse(costCtrl.text.trim()) ?? 0;
                final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
                if (name.isEmpty || sku.isEmpty) return;

                final nav = Navigator.of(ctx);
                final msg = ScaffoldMessenger.of(context);
                try {
                  final payload = jsonEncode({
                    'name': name,
                    'sku': sku,
                    'category': selectedCat,
                    'sellingPrice': price,
                    'purchasePrice': cost,
                    'currentStock': stock,
                  });
                  final res = isEdit
                      ? await http.put(Uri.parse('$_baseUrl/${existing.id}'), headers: await _headers(), body: payload)
                      : await http.post(Uri.parse(_baseUrl), headers: await _headers(), body: payload);
                  if (res.statusCode == 201 || res.statusCode == 200) {
                    nav.pop();
                    await _loadData();
                    msg.showSnackBar(SnackBar(content: Text('Product "$name" saved to MongoDB!'), backgroundColor: AppColors.success));
                  } else {
                    final err = jsonDecode(res.body);
                    msg.showSnackBar(SnackBar(content: Text('${err['message'] ?? 'Failed'}'), backgroundColor: AppColors.danger));
                  }
                } catch (e) {
                  msg.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              child: const Text('Save Product', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

const TextStyle _tblHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.bold,
  color: AppColors.textSecondary,
);
