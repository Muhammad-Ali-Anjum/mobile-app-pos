import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Reusable Permission Guard Widget
/// Enforces client-side UI visibility based on the user's effective permissions.
/// (Backend authorization remains strictly enforced on every API).
class PermissionGuard extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService(),
      builder: (context, _) {
        final hasAccess = AuthService().can(permission);
        if (hasAccess) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

