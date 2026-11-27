// File: models/registered_shop_item.dart
// ---------------------------------------------------
// Dart model representing a shop record from the backend.
// Matches the fields defined in backend/src/models/shop.model.js.
// ---------------------------------------------------
import 'dart:convert';

class RegisteredShopItem {
  final String? id; // MongoDB _id as string
  final String name;
  final String? code;
  final String ownerId;
  final String? subscriptionPlan;
  final String? subscriptionStatus;
  final int? maxBranches;
  final int? maxUsers;
  final DateTime? expiresAt;
  final bool isActive;

  RegisteredShopItem({
    this.id,
    required this.name,
    this.code,
    required this.ownerId,
    this.subscriptionPlan,
    this.subscriptionStatus,
    this.maxBranches,
    this.maxUsers,
    this.expiresAt,
    required this.isActive,
  });

  factory RegisteredShopItem.fromJson(Map<String, dynamic> json) {
    return RegisteredShopItem(
      id: json['_id'] as String?,
      name: json['name'] as String,
      code: json['code'] as String?,
      ownerId: (json['ownerId'] ?? json['owner_id'] ?? '').toString(),
      subscriptionPlan: json['subscription']?['plan'] as String?,
      subscriptionStatus: json['subscription']?['status'] as String?,
      maxBranches: json['subscription']?['maxBranches'] as int?,
      maxUsers: json['subscription']?['maxUsers'] as int?,
      expiresAt: json['subscription']?['expiresAt'] != null
          ? DateTime.parse(json['subscription']['expiresAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      if (code != null) 'code': code,
      'ownerId': ownerId,
      'subscription': {
        if (subscriptionPlan != null) 'plan': subscriptionPlan,
        if (subscriptionStatus != null) 'status': subscriptionStatus,
        if (maxBranches != null) 'maxBranches': maxBranches,
        if (maxUsers != null) 'maxUsers': maxUsers,
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      },
      'isActive': isActive,
    };
  }

  // Equality and hashCode overrides removed – default identity semantics are sufficient for now


  @override
  String toString() => jsonEncode(toJson());
}
