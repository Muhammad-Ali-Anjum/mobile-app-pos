import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/super_admin/presentation/super_admin_dashboard_screen.dart';
import 'features/auth/presentation/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/shell/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NextPlannersPosApp());
}

class NextPlannersPosApp extends StatefulWidget {
  const NextPlannersPosApp({super.key});

  @override
  State<NextPlannersPosApp> createState() => _NextPlannersPosAppState();
}

class _NextPlannersPosAppState extends State<NextPlannersPosApp> {
  bool _onboarded = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboarded') ?? false;
    // Load any persisted auth session (mock or real)
    await AuthService().loadPersistedSession();
    setState(() {
      _onboarded = onboarded;
      _initialized = true;
    });
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    setState(() {
      _onboarded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    if (!_onboarded) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: OnboardingScreen(onFinish: _finishOnboarding),
      );
    }
    return MaterialApp(
      title: 'Next Planners POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ListenableBuilder(
        listenable: AuthService(),
        builder: (context, _) {
          if (!AuthService().isAuthenticated) {
            return LoginScreen(onLoginSuccess: () {});
          }
          if (AuthService().isSuperAdmin) {
            return const SuperAdminDashboardScreen();
          }
          return const AppShell();
        },
      ),
    );
  }
}
