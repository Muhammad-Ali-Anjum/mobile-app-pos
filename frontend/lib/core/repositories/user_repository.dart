import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../services/auth_service.dart';

/// Simple repository that reads a static JSON file placed in
/// `assets/data/users.json`. In a real project this would be an HTTP
/// request to a REST API or a call to Firebase/Firestore.
class UserRepository {
  static const _assetPath = 'assets/data/users.json';

  /// Load the raw JSON data from the asset file.
  Future<List<dynamic>> _loadRawUsers() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded;
  }

  /// Authenticate a user against the static JSON "database".
  /// Returns a [UserSession] on success, or `null` if credentials
  /// are invalid.
  Future<UserSession?> authenticate(String email, String password) async {
    final users = await _loadRawUsers();
    for (final raw in users) {
      final map = raw as Map<String, dynamic>;
      if (map['email'] == email && map['password'] == password) {
        // Permissions are stored as a list of strings – convert to Set.
        final permissions = Set<String>.from(map['permissions'] as List);
        return UserSession(
          id: map['id'] as String,
          fullName: map['fullName'] as String,
          email: map['email'] as String,
          roleName: map['roleName'] as String,
          shopId: map['shopId'] as String,
          shopName: map['shopName'] as String,
          branches: List<String>.from(map['branches'] as List),
          permissions: permissions,
          isPlatformAdmin: map['isPlatformAdmin'] as bool,
        );
      }
    }
    return null; // not found or password mismatch
  }
}
