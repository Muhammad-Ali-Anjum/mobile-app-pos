import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/registered_shop_item.dart';

class PlanTier {
  final String slug;
  final String name;
  final int monthlyPrice;
  final int yearlyPrice;
  final int maxBranches;
  final int maxUsers;
  final int maxPosTerminals;
  final int maxProducts;
  final int storageLimitMb;
  final int trialDays;
  final bool dedicatedSupport;
  final bool isActive;
  final Map<String, bool> features;
  final String description;

  PlanTier({
    required this.slug,
    required this.name,
    required this.monthlyPrice,
    this.yearlyPrice = 0,
    required this.maxBranches,
    required this.maxUsers,
    this.maxPosTerminals = 1,
    this.maxProducts = 1000,
    this.storageLimitMb = 500,
    this.trialDays = 0,
    this.dedicatedSupport = false,
    this.isActive = true,
    this.features = const {'inventory': true, 'barcode': true, 'reports': true, 'multiBranch': false},
    required this.description,
  });

  factory PlanTier.fromMap(Map<String, dynamic> map) {
    final rawFeatures = map['features'] is Map<String, dynamic> ? map['features'] as Map<String, dynamic> : {};
    return PlanTier(
      slug: (map['slug'] ?? 'BASIC').toString().toUpperCase(),
      name: (map['name'] ?? '').toString(),
      monthlyPrice: (map['monthlyPrice'] as num?)?.toInt() ?? 0,
      yearlyPrice: (map['yearlyPrice'] as num?)?.toInt() ?? 0,
      maxBranches: (map['maxBranches'] as num?)?.toInt() ?? 1,
      maxUsers: (map['maxUsers'] as num?)?.toInt() ?? 3,
      maxPosTerminals: (map['maxPosTerminals'] as num?)?.toInt() ?? 1,
      maxProducts: (map['maxProducts'] as num?)?.toInt() ?? 1000,
      storageLimitMb: (map['storageLimitMb'] as num?)?.toInt() ?? 500,
      trialDays: (map['trialDays'] as num?)?.toInt() ?? 0,
      dedicatedSupport: map['dedicatedSupport'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? true,
      features: {
        'inventory': rawFeatures['inventory'] as bool? ?? true,
        'barcode': rawFeatures['barcode'] as bool? ?? true,
        'reports': rawFeatures['reports'] as bool? ?? true,
        'multiBranch': rawFeatures['multiBranch'] as bool? ?? false,
      },
      description: (map['description'] ?? '').toString(),
    );
  }
}

class PaymentReminderItem {
  final String id;
  final String shopName;
  final String ownerName;
  final String channel;
  final String recipient;
  final String subject;
  final String message;
  final String sentAt;
  final String whatsappUrl;
  final String deliveryNote;

  PaymentReminderItem({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.channel,
    required this.recipient,
    required this.subject,
    required this.message,
    required this.sentAt,
    this.whatsappUrl = '',
    this.deliveryNote = '',
  });

  factory PaymentReminderItem.fromMap(Map<String, dynamic> map) => PaymentReminderItem(
        id: (map['_id'] ?? map['id'] ?? '').toString(),
        shopName: (map['shopName'] ?? '').toString(),
        ownerName: (map['ownerName'] ?? '').toString(),
        channel: (map['channel'] ?? 'EMAIL').toString(),
        recipient: (map['recipient'] ?? '').toString(),
        subject: (map['subject'] ?? '').toString(),
        message: (map['message'] ?? '').toString(),
        sentAt: RegisteredShopItem.formatDate(map['createdAt']),
        whatsappUrl: (map['whatsappUrl'] ?? '').toString(),
        deliveryNote: (map['deliveryNote'] ?? '').toString(),
      );
}

class ShopDetailsBundle {
  final RegisteredShopItem shop;
  final List<Map<String, dynamic>> branches;
  final List<Map<String, dynamic>> users;
  final List<PaymentReminderItem> reminders;

  ShopDetailsBundle({
    required this.shop,
    required this.branches,
    required this.users,
    required this.reminders,
  });
}

class SubscriptionItem {
  final String id;
  final String shopId;
  final String shopName;
  final String tenantId;
  final String planSlug;
  final String planName;
  final String billingCycle;
  final String startDate;
  final String expiresAt;
  final int amount;
  final int discount;
  final String paymentStatus;
  final String status;
  final bool autoRenew;
  final int gracePeriodDays;

  SubscriptionItem({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.tenantId,
    required this.planSlug,
    required this.planName,
    required this.billingCycle,
    required this.startDate,
    required this.expiresAt,
    required this.amount,
    required this.discount,
    required this.paymentStatus,
    required this.status,
    required this.autoRenew,
    required this.gracePeriodDays,
  });

  factory SubscriptionItem.fromMap(Map<String, dynamic> map) {
    final shopObj = map['shopId'] is Map<String, dynamic> ? map['shopId'] as Map<String, dynamic> : null;
    return SubscriptionItem(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      shopId: (shopObj?['_id'] ?? map['shopId'] ?? '').toString(),
      shopName: (shopObj?['name'] ?? 'Shop').toString(),
      tenantId: (shopObj?['tenantId'] ?? shopObj?['code'] ?? '').toString(),
      planSlug: (map['planSlug'] ?? 'STANDARD').toString(),
      planName: (map['planName'] ?? map['planSlug'] ?? '').toString(),
      billingCycle: (map['billingCycle'] ?? 'MONTHLY').toString(),
      startDate: RegisteredShopItem.formatDate(map['startDate']),
      expiresAt: RegisteredShopItem.formatDate(map['expiresAt']),
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      discount: (map['discount'] as num?)?.toInt() ?? 0,
      paymentStatus: (map['paymentStatus'] ?? 'PAID').toString(),
      status: (map['status'] ?? 'ACTIVE').toString(),
      autoRenew: map['autoRenew'] as bool? ?? true,
      gracePeriodDays: (map['gracePeriodDays'] as num?)?.toInt() ?? 3,
    );
  }
}

class InvoiceItem {
  final String id;
  final String invoiceNumber;
  final String shopId;
  final String shopName;
  final String planSlug;
  final int totalAmount;
  final int discount;
  final int paidAmount;
  final int remainingAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String paymentDate;

  InvoiceItem({
    required this.id,
    required this.invoiceNumber,
    required this.shopId,
    required this.shopName,
    required this.planSlug,
    required this.totalAmount,
    required this.discount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentDate,
  });

  factory InvoiceItem.fromMap(Map<String, dynamic> map) => InvoiceItem(
        id: (map['_id'] ?? map['id'] ?? '').toString(),
        invoiceNumber: (map['invoiceNumber'] ?? '').toString(),
        shopId: (map['shopId'] ?? '').toString(),
        shopName: (map['shopName'] ?? '').toString(),
        planSlug: (map['planSlug'] ?? '').toString(),
        totalAmount: (map['totalAmount'] as num?)?.toInt() ?? 0,
        discount: (map['discount'] as num?)?.toInt() ?? 0,
        paidAmount: (map['paidAmount'] as num?)?.toInt() ?? 0,
        remainingAmount: (map['remainingAmount'] as num?)?.toInt() ?? 0,
        paymentMethod: (map['paymentMethod'] ?? 'BANK_TRANSFER').toString(),
        paymentStatus: (map['paymentStatus'] ?? 'UNPAID').toString(),
        paymentDate: map['paymentDate'] != null
            ? RegisteredShopItem.formatDate(map['paymentDate'])
            : RegisteredShopItem.formatDate(map['createdAt']),
      );
}

class CouponItem {
  final String id;
  final String code;
  final String discountType;
  final int value;
  final int usageLimit;
  final int usedCount;
  final String expiresAt;
  final bool isActive;

  CouponItem({
    required this.id,
    required this.code,
    required this.discountType,
    required this.value,
    required this.usageLimit,
    required this.usedCount,
    required this.expiresAt,
    required this.isActive,
  });

  factory CouponItem.fromMap(Map<String, dynamic> map) => CouponItem(
        id: (map['_id'] ?? map['id'] ?? '').toString(),
        code: (map['code'] ?? '').toString(),
        discountType: (map['discountType'] ?? 'PERCENTAGE').toString(),
        value: (map['value'] as num?)?.toInt() ?? 0,
        usageLimit: (map['usageLimit'] as num?)?.toInt() ?? 100,
        usedCount: (map['usedCount'] as num?)?.toInt() ?? 0,
        expiresAt: RegisteredShopItem.formatDate(map['expiresAt']),
        isActive: map['isActive'] as bool? ?? true,
      );
}

class ShopRepository {
  static const String _shopsUrl = 'http://localhost:5002/api/shops';
  static const String _plansUrl = 'http://localhost:5002/api/plans';
  static const String _subsUrl = 'http://localhost:5002/api/subscriptions';
  static const String _billingUrl = 'http://localhost:5002/api/billing';
  static const String _platformUsersUrl = 'http://localhost:5002/api/platform-users';
  static const String _ticketsUrl = 'http://localhost:5002/api/tickets';
  static const String _systemUrl = 'http://localhost:5002/api/system';

  Future<Map<String, String>> _authHeaders({Map<String, String>? extra}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?extra,
    };
  }

  Future<http.Response> _get(Uri url) async => http.get(url, headers: await _authHeaders());
  Future<http.Response> _post(Uri url, {Map<String, String>? headers, Object? body}) async =>
      http.post(url, headers: await _authHeaders(extra: headers), body: body);
  Future<http.Response> _put(Uri url, {Map<String, String>? headers, Object? body}) async =>
      http.put(url, headers: await _authHeaders(extra: headers), body: body);
  Future<http.Response> _patch(Uri url, {Map<String, String>? headers, Object? body}) async =>
      http.patch(url, headers: await _authHeaders(extra: headers), body: body);
  Future<http.Response> _delete(Uri url) async => http.delete(url, headers: await _authHeaders());

  Future<List<RegisteredShopItem>> fetchAllShops() async {
    final response = await _get(Uri.parse(_shopsUrl));
    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded.map((e) => RegisteredShopItem.fromMap(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load shops (status ${response.statusCode})');
  }

  Future<ShopDetailsBundle> fetchShopDetails(String id) async {
    final response = await _get(Uri.parse('$_shopsUrl/$id/details'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ShopDetailsBundle(
        shop: RegisteredShopItem.fromMap(data['shop'] as Map<String, dynamic>),
        branches: ((data['branches'] as List?) ?? []).cast<Map<String, dynamic>>(),
        users: ((data['users'] as List?) ?? []).cast<Map<String, dynamic>>(),
        reminders: ((data['reminders'] as List?) ?? [])
            .map((e) => PaymentReminderItem.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw Exception('Failed to load shop details (status ${response.statusCode})');
  }

  Future<RegisteredShopItem> addShop(RegisteredShopItem shop, {String? password}) async {
    return createShopFromWizard({
      'shopName': shop.shopName,
      'owner': shop.owner,
      'email': shop.email,
      'phone': shop.phone,
      'plan': shop.plan,
      'shopType': shop.shopType,
      'branches': shop.branches,
      if (password != null && password.isNotEmpty) 'password': password,
    });
  }

  Future<RegisteredShopItem> createShopFromWizard(Map<String, dynamic> payload) async {
    final response = await _post(
      Uri.parse(_shopsUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return RegisteredShopItem.fromMap(data);
    }
    throw Exception('Failed to register shop (status ${response.statusCode}): ${response.body}');
  }

  Future<RegisteredShopItem> updateShop(String id, Map<String, dynamic> payload) async {
    final response = await _put(
      Uri.parse('$_shopsUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      return RegisteredShopItem.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update shop (status ${response.statusCode})');
  }

  Future<RegisteredShopItem> toggleShopStatus(String id, bool isActive) async {
    final response = await _patch(
      Uri.parse('$_shopsUrl/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isActive': isActive}),
    );
    if (response.statusCode == 200) {
      return RegisteredShopItem.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update shop status (status ${response.statusCode})');
  }

  Future<RegisteredShopItem> updateShopPlan(
    String id,
    String plan, {
    int? branches,
    String? billingCycle,
    int? extendDays,
  }) async {
    final response = await _patch(
      Uri.parse('$_shopsUrl/$id/plan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'plan': plan,
        'branches': ?branches,
        'billingCycle': ?billingCycle,
        'extendDays': ?extendDays,
      }),
    );
    if (response.statusCode == 200) {
      return RegisteredShopItem.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update shop plan (status ${response.statusCode})');
  }

  Future<void> resetOwnerPassword(String id, String newPassword) async {
    final response = await _patch(
      Uri.parse('$_shopsUrl/$id/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newPassword': newPassword}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to reset password (status ${response.statusCode})');
    }
  }

  Future<void> deleteShop(String id) async {
    final response = await _delete(Uri.parse('$_shopsUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete shop (status ${response.statusCode})');
    }
  }

  Future<List<PlanTier>> fetchPlans() async {
    final response = await _get(Uri.parse(_plansUrl));
    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded.map((e) => PlanTier.fromMap(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load plans (status ${response.statusCode})');
  }

  Future<PlanTier> createPlan(Map<String, dynamic> payload) async {
    final response = await _post(
      Uri.parse(_plansUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return PlanTier.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create plan (status ${response.statusCode}): ${response.body}');
  }

  Future<PlanTier> updatePlan(
    String slug, {
    required String name,
    required int monthlyPrice,
    int? yearlyPrice,
    required int maxBranches,
    required int maxUsers,
    int? maxPosTerminals,
    int? maxProducts,
    int? storageLimitMb,
    int? trialDays,
    bool? dedicatedSupport,
    Map<String, bool>? features,
    required String description,
  }) async {
    final response = await _patch(
      Uri.parse('$_plansUrl/$slug'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'monthlyPrice': monthlyPrice,
        'yearlyPrice': ?yearlyPrice,
        'maxBranches': maxBranches,
        'maxUsers': maxUsers,
        'maxPosTerminals': ?maxPosTerminals,
        'maxProducts': ?maxProducts,
        'storageLimitMb': ?storageLimitMb,
        'trialDays': ?trialDays,
        'dedicatedSupport': ?dedicatedSupport,
        'features': ?features,
        'description': description,
      }),
    );
    if (response.statusCode == 200) {
      return PlanTier.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update plan (status ${response.statusCode})');
  }

  Future<PlanTier> duplicatePlan(String slug) async {
    final response = await _post(Uri.parse('$_plansUrl/$slug/duplicate'));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return PlanTier.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to duplicate plan (status ${response.statusCode})');
  }

  Future<PlanTier> togglePlanStatus(String slug, bool isActive) async {
    final response = await _patch(
      Uri.parse('$_plansUrl/$slug/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isActive': isActive}),
    );
    if (response.statusCode == 200) {
      return PlanTier.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to toggle plan status (status ${response.statusCode})');
  }

  Future<PaymentReminderItem> sendPaymentReminder({
    required String shopId,
    required String channel,
    required String recipient,
    required String subject,
    required String message,
  }) async {
    final response = await _post(
      Uri.parse('$_shopsUrl/$shopId/reminder'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channel': channel,
        'recipient': recipient,
        'subject': subject,
        'message': message,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return PaymentReminderItem.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to send reminder (status ${response.statusCode})');
  }

  Future<List<PaymentReminderItem>> fetchReminders() async {
    final response = await _get(Uri.parse('$_shopsUrl/reminders'));
    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded.map((e) => PaymentReminderItem.fromMap(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load reminders (status ${response.statusCode})');
  }

  Future<List<SubscriptionItem>> fetchSubscriptions({String status = 'ALL'}) async {
    final uri = Uri.parse('$_subsUrl${status != 'ALL' ? '?status=$status' : ''}');
    final response = await _get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded.map((e) => SubscriptionItem.fromMap(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load subscriptions (status ${response.statusCode})');
  }

  Future<SubscriptionItem> assignSubscription(Map<String, dynamic> payload) async {
    final response = await _post(
      Uri.parse(_subsUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return SubscriptionItem.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to assign subscription (status ${response.statusCode})');
  }

  Future<SubscriptionItem> updateSubscriptionLifecycle(String id, Map<String, dynamic> payload) async {
    final response = await _patch(
      Uri.parse('$_subsUrl/$id/lifecycle'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      return SubscriptionItem.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update subscription (status ${response.statusCode})');
  }

  Future<List<InvoiceItem>> fetchInvoices({String status = 'ALL'}) async {
    final uri = Uri.parse('$_billingUrl/invoices${status != 'ALL' ? '?status=$status' : ''}');
    final response = await _get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded.map((e) => InvoiceItem.fromMap(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load invoices (status ${response.statusCode})');
  }

  Future<InvoiceItem> createInvoice(Map<String, dynamic> payload) async {
    final response = await _post(
      Uri.parse('$_billingUrl/invoices'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return InvoiceItem.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create invoice (status ${response.statusCode})');
  }

  Future<InvoiceItem> recordInvoicePayment(String id, int amount, String method) async {
    final response = await _patch(
      Uri.parse('$_billingUrl/invoices/$id/pay'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount, 'paymentMethod': method}),
    );
    if (response.statusCode == 200) {
      return InvoiceItem.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to record payment (status ${response.statusCode})');
  }

  Future<InvoiceItem> verifyInvoicePayment(String id) async {
    final response = await _patch(Uri.parse('$_billingUrl/invoices/$id/verify'));
    if (response.statusCode == 200) {
      return InvoiceItem.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to verify payment (status ${response.statusCode})');
  }

  Future<InvoiceItem> refundInvoice(String id) async {
    final response = await _patch(Uri.parse('$_billingUrl/invoices/$id/refund'));
    if (response.statusCode == 200) {
      return InvoiceItem.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to refund invoice (status ${response.statusCode})');
  }

  Future<Map<String, dynamic>> fetchRevenueReports() async {
    final response = await _get(Uri.parse('$_billingUrl/reports'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load revenue reports');
  }

  Future<List<CouponItem>> fetchCoupons() async {
    final response = await _get(Uri.parse('$_billingUrl/coupons'));
    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded.map((e) => CouponItem.fromMap(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load coupons');
  }

  Future<CouponItem> createCoupon(Map<String, dynamic> payload) async {
    final response = await _post(
      Uri.parse('$_billingUrl/coupons'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return CouponItem.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create coupon');
  }

  Future<void> toggleCoupon(String id) async {
    final response = await _patch(Uri.parse('$_billingUrl/coupons/$id/toggle'));
    if (response.statusCode != 200) throw Exception('Failed to toggle coupon');
  }

  Future<void> deleteCoupon(String id) async {
    final response = await _delete(Uri.parse('$_billingUrl/coupons/$id'));
    if (response.statusCode != 200) throw Exception('Failed to delete coupon');
  }

  // --- Phase 4-6: Platform Users, Notifications, Audit Logs, Tickets, System ---
  Future<List<Map<String, dynamic>>> fetchPlatformUsers() async {
    final response = await _get(Uri.parse(_platformUsersUrl));
    if (response.statusCode == 200) return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    throw Exception('Failed to load platform users');
  }

  Future<Map<String, dynamic>> createPlatformUser(Map<String, dynamic> payload) async {
    final response = await _post(
      Uri.parse(_platformUsersUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 201 || response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception('Failed to create user: ${response.body}');
  }

  Future<void> togglePlatformUserStatus(String id) async {
    final response = await _patch(Uri.parse('$_platformUsersUrl/$id/status'));
    if (response.statusCode != 200) throw Exception('Failed to update user status');
  }

  Future<void> updatePlatformUser(String id, Map<String, dynamic> payload) async {
    final response = await _patch(
      Uri.parse('$_platformUsersUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) throw Exception('Failed to update user');
  }

  Future<void> resetPlatformUserPassword(String id, String newPassword) async {
    final response = await _patch(
      Uri.parse('$_platformUsersUrl/$id/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newPassword': newPassword}),
    );
    if (response.statusCode != 200) throw Exception('Failed to reset password');
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final response = await _get(Uri.parse('$_platformUsersUrl/notifications'));
    if (response.statusCode == 200) return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    throw Exception('Failed to load notifications');
  }

  Future<void> markNotificationRead(String id) async {
    await _patch(Uri.parse('$_platformUsersUrl/notifications/$id/read'));
  }

  Future<Map<String, dynamic>> checkExpiringSubscriptions() async {
    final response = await _post(Uri.parse('$_platformUsersUrl/notifications/check-expiring'));
    if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception('Failed to check expiring subscriptions');
  }

  Future<List<Map<String, dynamic>>> fetchAuditLogs() async {
    final response = await _get(Uri.parse('$_platformUsersUrl/audit-logs'));
    if (response.statusCode == 200) return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    throw Exception('Failed to load audit logs');
  }

  Future<List<Map<String, dynamic>>> fetchTickets({String status = 'ALL'}) async {
    final response = await _get(Uri.parse('$_ticketsUrl${status != 'ALL' ? '?status=$status' : ''}'));
    if (response.statusCode == 200) return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    throw Exception('Failed to load tickets');
  }

  Future<void> createTicket(Map<String, dynamic> payload) async {
    final response = await _post(
      Uri.parse(_ticketsUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201 && response.statusCode != 200) throw Exception('Failed to create ticket');
  }

  Future<void> replyTicket(String id, String message) async {
    final response = await _post(
      Uri.parse('$_ticketsUrl/$id/reply'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );
    if (response.statusCode != 200) throw Exception('Failed to reply');
  }

  Future<void> updateTicket(String id, Map<String, dynamic> payload) async {
    final response = await _patch(
      Uri.parse('$_ticketsUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) throw Exception('Failed to update ticket');
  }

  Future<Map<String, dynamic>> fetchSystemSettings() async {
    final response = await _get(Uri.parse('$_systemUrl/settings'));
    if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception('Failed to load settings');
  }

  Future<Map<String, dynamic>> updateSystemSettings(Map<String, dynamic> payload) async {
    final response = await _put(
      Uri.parse('$_systemUrl/settings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception('Failed to save settings');
  }

  Future<Map<String, dynamic>> triggerBackup() async {
    final response = await _post(Uri.parse('$_systemUrl/backup'));
    if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception('Failed to trigger backup');
  }

  Future<Map<String, dynamic>> impersonateShopAdmin(String shopId) async {
    final response = await _post(Uri.parse('$_shopsUrl/$shopId/impersonate'));
    if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception('Failed to impersonate shop admin');
  }

  Future<List<Map<String, dynamic>>> fetchLeads() async {
    final response = await _get(Uri.parse('$_platformUsersUrl/leads'));
    if (response.statusCode == 200) return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    throw Exception('Failed to load leads');
  }

  Future<void> createLead(Map<String, dynamic> payload) async {
    final response = await _post(
      Uri.parse('$_platformUsersUrl/leads'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201 && response.statusCode != 200) throw Exception('Failed to create lead');
  }

  Future<void> updateLead(String id, Map<String, dynamic> payload) async {
    final response = await _patch(
      Uri.parse('$_platformUsersUrl/leads/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) throw Exception('Failed to update lead');
  }

  Future<void> deleteLead(String id) async {
    await _delete(Uri.parse('$_platformUsersUrl/leads/$id'));
  }

  Future<Map<String, dynamic>> fetchPlatformAnalytics() async {
    final response = await _get(Uri.parse('$_platformUsersUrl/analytics'));
    if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception('Failed to load analytics');
  }

  Future<List<Map<String, dynamic>>> fetchAllBranches() async {
    final response = await _get(Uri.parse('$_platformUsersUrl/branches'));
    if (response.statusCode == 200) return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    throw Exception('Failed to load branches');
  }

  Future<List<Map<String, dynamic>>> fetchAllTenantUsers() async {
    final response = await _get(Uri.parse('$_platformUsersUrl/tenant-users'));
    if (response.statusCode == 200) return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    throw Exception('Failed to load tenant users');
  }
}
