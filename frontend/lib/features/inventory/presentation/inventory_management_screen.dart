import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';

class InventoryProductItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int stock;
  final double price;

  InventoryProductItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.stock,
    required this.price,
  });
}

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  List<InventoryProductItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadInventory() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('http://localhost:5002/api/products'), headers: await _headers());
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (body['data'] as List?) ?? [];
        if (!mounted) return;
        setState(() {
          _items = list
              .map((p) => InventoryProductItem(
                    id: (p['_id'] ?? p['id'] ?? '').toString(),
                    name: (p['name'] ?? '').toString(),
                    sku: (p['sku'] ?? '').toString(),
                    category: (p['category'] ?? 'General').toString(),
                    stock: (p['currentStock'] as num?)?.toInt() ?? 0,
                    price: (p['sellingPrice'] as num?)?.toDouble() ?? 0,
                  ))
              .toList();
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
    final totalStock = _items.fold<int>(0, (s, p) => s + p.stock);
    final totalVal = _items.fold<double>(0, (s, p) => s + (p.stock * p.price));
    final lowCount = _items.where((p) => p.stock > 0 && p.stock <= 5).length;
    final outCount = _items.where((p) => p.stock <= 0).length;

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
                    Text('Inventory & Warehouse', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Real-time stock tracking and quick stock adjustments from MongoDB', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: _loadInventory,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard('Total Stock Units', '$totalStock', AppColors.primary),
                  const SizedBox(width: 14),
                  _buildStatCard('Total Inventory Value', 'Rs. ${totalVal.toStringAsFixed(0)}', AppColors.secondary),
                  const SizedBox(width: 14),
                  _buildStatCard('Low Stock Items', '$lowCount', AppColors.warning),
                  const SizedBox(width: 14),
                  _buildStatCard('Out of Stock', '$outCount', AppColors.danger),
                ],
              ),
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
                            Expanded(flex: 3, child: Text('PRODUCT', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('SKU', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('CATEGORY', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('STOCK', style: _headerStyle)),
                            Expanded(flex: 2, child: Text('ADJUST', style: _headerStyle)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _items.isEmpty
                                ? const Center(child: Text('No inventory items in database.', style: TextStyle(color: AppColors.textSecondary)))
                                : ListView.separated(
                                    itemCount: _items.length,
                                    separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.border),
                                    itemBuilder: (context, index) {
                                      final item = _items[index];
                                      final isOut = item.stock <= 0;
                                      final isLow = item.stock > 0 && item.stock <= 5;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            Expanded(flex: 3, child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                            Expanded(flex: 2, child: Text(item.sku, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                                            Expanded(flex: 2, child: Text(item.category, style: const TextStyle(fontSize: 12))),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '${item.stock}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isOut ? AppColors.danger : (isLow ? AppColors.warning : AppColors.success),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: TextButton.icon(
                                                onPressed: () => _openStockAdjustmentDialog(item),
                                                icon: const Icon(Icons.tune, size: 16),
                                                label: const Text('Adjust', style: TextStyle(fontSize: 12)),
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
    return SizedBox(
      width: 210,
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

  void _openStockAdjustmentDialog(InventoryProductItem item) {
    final qtyCtrl = TextEditingController(text: '${item.stock}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Adjust Stock - ${item.name}'),
        content: TextField(
          controller: qtyCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New Stock Quantity', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final nextQty = int.tryParse(qtyCtrl.text.trim());
              if (nextQty == null) return;
              final nav = Navigator.of(ctx);
              final res = await http.put(
                Uri.parse('http://localhost:5002/api/products/${item.id}'),
                headers: await _headers(),
                body: jsonEncode({'currentStock': nextQty}),
              );
              if (res.statusCode == 200) {
                nav.pop();
                await _loadInventory();
              }
            },
            child: const Text('Save Stock', style: TextStyle(color: Colors.white)),
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
