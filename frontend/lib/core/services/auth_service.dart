import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserSession {
  final String id;
  final String fullName;
  final String email;
  final String roleName;
  final String shopId;
  final String shopName;
  final List<String> branches;
  final Set<String> permissions;
  final bool isPlatformAdmin;

  UserSession({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roleName,
    required this.shopId,
    required this.shopName,
    required this.branches,
    required this.permissions,
    this.isPlatformAdmin = false,
  });

  bool hasPermission(String permission) {
    if (isPlatformAdmin || permissions.contains('*')) return true;
    return permissions.contains(permission);
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../repositories/user_repository.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserSession? _currentUser;
  UserSession? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;
  bool get isSuperAdmin => _currentUser?.isPlatformAdmin ?? false;

  // ------------------------------------------------
  // Public API
  // ------------------------------------------------
  Future<void> login(String email, String password) async {
    // Use the repository to fetch user data from the local JSON "database"
    final repo = UserRepository();
    final session = await repo.authenticate(email, password);
    if (session == null) {
      throw Exception('Invalid credentials');
    }
    setSession(session);
    // Persist locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session', jsonEncode(session.toMap()));
  }

  void setSession(UserSession session) {
    _currentUser = session;
    notifyListeners();
  }

  Future<void> loadPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('session');
    if (json != null) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      // Re‑create the Set for permissions
      map['permissions'] = Set<String>.from(map['permissions'] as List);
      _currentUser = UserSession(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        email: map['email'] as String,
        roleName: map['roleName'] as String,
        shopId: map['shopId'] as String,
        shopName: map['shopName'] as String,
        branches: List<String>.from(map['branches'] as List),
        permissions: map['permissions'] as Set<String>,
        isPlatformAdmin: map['isPlatformAdmin'] as bool,
      );
      notifyListeners();
    }
  }

  void logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session');
    notifyListeners();
  }

  bool can(String permission) {
    if (_currentUser?.isPlatformAdmin ?? false) return true;
    return _currentUser?.hasPermission(permission) ?? false;
  }
}

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserSession? _currentUser;
  UserSession? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;
  bool get isSuperAdmin => _currentUser?.isPlatformAdmin ?? false;

  // ---------- Mock user DB ----------
  // In a real project replace this with a call to Firebase, Supabase, or your own REST API.
  static const Map<String, Map<String, dynamic>> _mockUsers = {
    'superadmin@nextplanners.com': {
      'password': 'admin123',
      'session': {
        'id': 'user_super_admin',
        'fullName': 'Platform Super Admin',
        'email': 'superadmin@nextplanners.com',
        'roleName': 'Super Admin',
        'shopId': '',
        'shopName': 'NPTS Platform Central',
        'branches': ['All Platforms'],
        'permissions': ['*'],
        'isPlatformAdmin': true,
      },
    },
    'cashier@abc.com': {
      'password': 'cashier123',
      'session': {
        'id': 'user_cashier_1',
        'fullName': 'Usman Raza',
        'email': 'cashier@abc.com',
        'roleName': 'Cashier / POS Operator',
        'shopId': 'shop_skd_01',
        'shopName': 'ABC Supermarket (Skardu)',
        'branches': ['Main Branch – Skardu'],
        'permissions': [
          'pos.view',
          'pos.create',
          'pos.edit_cart',
          'pos.remove_item',
          'pos.apply_discount',
          'pos.complete_sale',
          'pos.view_own_sales',
          'pos.print_receipt',
          'products.view',
          'sales.view_own',
          'customers.view',
        ],
        'isPlatformAdmin': false,
      },
    },
    'owner@abc.com': {
      'password': 'owner123',
      'session': {
        'id': 'user_owner_1',
        'fullName': 'Ali Khan',
        'email': 'owner@abc.com',
        'roleName': 'Shop Owner',
        'shopId': 'shop_skd_01',
        'shopName': 'ABC Supermarket (Skardu)',
        'branches': [
          'Main Branch – Skardu',
          'Gilgit Branch',
          'Islamabad Branch',
        ],
        'permissions': ['*'],
        'isPlatformAdmin': false,
      },
    },
  };

  // ------------------------------------------------
  // Public API
  // ------------------------------------------------
  Future<void> login(String email, String password) async {
    final user = _mockUsers[email];
    if (user == null || user['password'] != password) {
      throw Exception('Invalid credentials');
    }
    // Build session from mock data
    final sessionMap = Map<String, dynamic>.from(user['session'] as Map);
    // Convert List permissions to Set<String>
    sessionMap['permissions'] = Set<String>.from(sessionMap['permissions'] as List);
    final session = UserSession(
      id: sessionMap['id'] as String,
      fullName: sessionMap['fullName'] as String,
      email: sessionMap['email'] as String,
      roleName: sessionMap['roleName'] as String,
      shopId: sessionMap['shopId'] as String,
      shopName: sessionMap['shopName'] as String,
      branches: List<String>.from(sessionMap['branches'] as List),
      permissions: sessionMap['permissions'] as Set<String>,
      isPlatformAdmin: sessionMap['isPlatformAdmin'] as bool,
    );
    setSession(session);
    // Persist locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session', jsonEncode(sessionMap));
  }

  void setSession(UserSession session) {
    _currentUser = session;
    notifyListeners();
  }

  Future<void> loadPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('session');
    if (json != null) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      // Re‑create the Set for permissions
      map['permissions'] = Set<String>.from(map['permissions'] as List);
      _currentUser = UserSession(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        email: map['email'] as String,
        roleName: map['roleName'] as String,
        shopId: map['shopId'] as String,
        shopName: map['shopName'] as String,
        branches: List<String>.from(map['branches'] as List),
        permissions: map['permissions'] as Set<String>,
        isPlatformAdmin: map['isPlatformAdmin'] as bool,
      );
      notifyListeners();
    }
  }

  void logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session');
    notifyListeners();
  }

  bool can(String permission) {
    if (_currentUser?.isPlatformAdmin ?? false) return true;
    return _currentUser?.hasPermission(permission) ?? false;
  }
}

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserSession? _currentUser;
  UserSession? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;
  bool get isSuperAdmin => _currentUser?.isPlatformAdmin ?? false;

  void setSession(UserSession session) {
    _currentUser = session;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  bool can(String permission) {
    if (_currentUser?.isPlatformAdmin ?? false) return true;
    return _currentUser?.hasPermission(permission) ?? false;
  }
}
