import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/registered_shop_item.dart';

class ShopRepository {
  static const _assetPath = 'assets/data/shops.json';

  Future<List<RegisteredShopItem>> fetchAllShops() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded
        .map((e) => RegisteredShopItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
