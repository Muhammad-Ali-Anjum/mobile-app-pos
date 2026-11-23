class RegisteredShopItem {
  final String id;
  final String shopName;
  final String owner;
  final String email;
  final String phone;
  final String plan;
  String status;
  final String joined;
  final String shopType;
  final int branches;

  RegisteredShopItem({
    required this.id,
    required this.shopName,
    required this.owner,
    required this.email,
    required this.phone,
    required this.plan,
    required this.status,
    required this.joined,
    required this.shopType,
    this.branches = 1,
  });

  factory RegisteredShopItem.fromMap(Map<String, dynamic> map) => RegisteredShopItem(
        id: map['id'] as String,
        shopName: map['shopName'] as String,
        owner: map['owner'] as String,
        email: map['email'] as String,
        phone: map['phone'] as String,
        plan: map['plan'] as String,
        status: map['status'] as String,
        joined: map['joined'] as String,
        shopType: map['shopType'] as String,
        branches: map['branches'] as int? ?? 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'shopName': shopName,
        'owner': owner,
        'email': email,
        'phone': phone,
        'plan': plan,
        'status': status,
        'joined': joined,
        'shopType': shopType,
        'branches': branches,
      };
}
