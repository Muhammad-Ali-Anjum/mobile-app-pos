class RegisteredShopItem {
  final String id;
  final String tenantId;
  final String shopName;
  final String owner;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String plan;
  String status;
  final String subscriptionStatus;
  final String billingCycle;
  final String expiresAt;
  final String joined;
  final DateTime? createdAt;
  final String shopType;
  final int branches;
  final int maxUsers;
  final int maxPosTerminals;

  RegisteredShopItem({
    required this.id,
    this.tenantId = '',
    required this.shopName,
    required this.owner,
    required this.email,
    required this.phone,
    this.address = '',
    this.city = '',
    this.country = 'Pakistan',
    required this.plan,
    required this.status,
    this.subscriptionStatus = 'ACTIVE',
    this.billingCycle = 'MONTHLY',
    this.expiresAt = '',
    required this.joined,
    this.createdAt,
    required this.shopType,
    this.branches = 1,
    this.maxUsers = 5,
    this.maxPosTerminals = 1,
  });

  static String _formatPlan(String raw) {
    switch (raw.toUpperCase()) {
      case 'TRIAL':
        return 'Trial';
      case 'BASIC':
        return 'Basic';
      case 'STANDARD':
        return 'Standard';
      case 'PREMIUM':
      case 'ENTERPRISE':
        return 'Premium';
      default:
        return raw.isEmpty ? 'Standard' : raw;
    }
  }

  static String formatDate(dynamic rawDate) {
    if (rawDate == null) return 'N/A';
    final parsed = DateTime.tryParse(rawDate.toString());
    if (parsed == null) return rawDate.toString();
    final local = parsed.toLocal();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}';
  }

  factory RegisteredShopItem.fromMap(Map<String, dynamic> map) {
    final ownerObj = map['ownerId'] is Map<String, dynamic> ? map['ownerId'] as Map<String, dynamic> : null;
    final subObj = map['subscription'] is Map<String, dynamic> ? map['subscription'] as Map<String, dynamic> : null;

    final rawId = (map['_id'] ?? map['id'] ?? '').toString();
    final rawName = (map['name'] ?? map['shopName'] ?? 'Unnamed Shop').toString();
    final rawOwner = (ownerObj?['fullName'] ?? map['owner'] ?? 'Shop Owner').toString();
    final rawEmail = (map['email']?.toString().isNotEmpty == true ? map['email'] : ownerObj?['email'] ?? '').toString();
    final rawPhone = (map['phone']?.toString().isNotEmpty == true ? map['phone'] : ownerObj?['phone'] ?? '').toString();
    final rawPlan = (subObj?['plan'] ?? map['plan'] ?? 'Standard').toString();
    final subStatus = (subObj?['status'] ?? map['subscriptionStatus'] ?? 'ACTIVE').toString().toUpperCase();
    final isActive = map['isActive'] is bool
        ? map['isActive'] as bool
        : (subStatus == 'ACTIVE' || subStatus == 'TRIAL');

    return RegisteredShopItem(
      id: rawId,
      tenantId: (map['tenantId'] ?? map['code'] ?? '').toString(),
      shopName: rawName,
      owner: rawOwner,
      email: rawEmail,
      phone: rawPhone,
      address: (map['address'] ?? '').toString(),
      city: (map['city'] ?? '').toString(),
      country: (map['country'] ?? 'Pakistan').toString(),
      plan: _formatPlan(rawPlan),
      status: isActive ? 'Active' : 'Inactive',
      subscriptionStatus: subStatus,
      billingCycle: (subObj?['billingCycle'] ?? 'MONTHLY').toString(),
      expiresAt: subObj?['expiresAt'] != null ? formatDate(subObj!['expiresAt']) : 'N/A',
      joined: map['joined']?.toString() ?? formatDate(map['createdAt']),
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) : null,
      shopType: (map['shopType'] ?? 'Retail').toString(),
      branches: (subObj?['maxBranches'] as num?)?.toInt() ?? (map['branches'] as num?)?.toInt() ?? 1,
      maxUsers: (subObj?['maxUsers'] as num?)?.toInt() ?? 5,
      maxPosTerminals: (subObj?['maxPosTerminals'] as num?)?.toInt() ?? 1,
    );
  }

  factory RegisteredShopItem.fromJson(Map<String, dynamic> json) => RegisteredShopItem.fromMap(json);

  Map<String, dynamic> toMap() => {
        'id': id,
        'tenantId': tenantId,
        'shopName': shopName,
        'owner': owner,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'country': country,
        'plan': plan,
        'status': status,
        'joined': joined,
        'shopType': shopType,
        'branches': branches,
      };
}
