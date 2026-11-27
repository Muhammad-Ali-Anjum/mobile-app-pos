import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/npts_logo.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'superadmin@nextplanners.com');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;

  void _handleLogin() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both username/email and password.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await AuthService().login(email, password);
      if (!mounted) return;
      setState(() => _isLoading = false);
      widget.onLoginSuccess();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }


  void _openOnboarding() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => OnboardingScreen(
          onFinish: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 500;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          // Background Mountain & Wave Illustration Footer (matches design sheet exactly)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: isSmallScreen ? 110 : 160,
            child: CustomPaint(
              painter: _MountainWaveFooterPainter(),
            ),
          ),

          // Main Login Content Container
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16.0 : 24.0,
                  vertical: 24.0,
                ),
                child: Container(
                  width: isSmallScreen ? double.infinity : 460,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF123B8B).withValues(alpha: 0.08),
                        blurRadius: 36,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 24.0 : 40.0,
                    vertical: isSmallScreen ? 28.0 : 36.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Official Logo
                      const NptsLogo(height: 52),
                      const SizedBox(height: 22),

                      // Heading from Design Sheet
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in to your account',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 26),

                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Email / Username Input
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email or Username',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter your email or username',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Input
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 19,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Remember Me & Forgot Password Row
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Remember Me',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please contact Super Admin for password recovery assistance.'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Large Navy Blue Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Clarification Notice: Registration is performed exclusively by Super Admin
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.shield_outlined, size: 20, color: AppColors.primary),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Don’t have an account? New shop accounts are registered exclusively by NPTS.',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tour button
                      TextButton.icon(
                        onPressed: _openOnboarding,
                        icon: const Icon(Icons.slideshow_outlined, size: 16, color: AppColors.primary),
                        label: const Text(
                          'View App Onboarding Tour',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter for the blue waves and mountain illustration shown on the design sheet
class _MountainWaveFooterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dark Blue Wave
    final wavePaint = Paint()
      ..color = const Color(0xFF123B8B).withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.45);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.6, size.width, size.height * 0.25);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, wavePaint);

    // 2. Secondary Orange Accent Wave Ribbon
    final orangePaint = Paint()
      ..color = const Color(0xFFFF7900)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final orangePath = Path();
    orangePath.moveTo(0, size.height * 0.44);
    orangePath.quadraticBezierTo(size.width * 0.25, size.height * 0.19, size.width * 0.5, size.height * 0.39);
    orangePath.quadraticBezierTo(size.width * 0.75, size.height * 0.59, size.width, size.height * 0.24);
    canvas.drawPath(orangePath, orangePaint);

    // 3. Snow-capped mountains on the right
    final mountainPaint = Paint()
      ..color = const Color(0xFF1E3A8A).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final mPath = Path();
    mPath.moveTo(size.width * 0.7, size.height);
    mPath.lineTo(size.width * 0.85, size.height * 0.15);
    mPath.lineTo(size.width * 0.92, size.height * 0.4);
    mPath.lineTo(size.width, size.height * 0.2);
    mPath.lineTo(size.width, size.height);
    mPath.close();
    canvas.drawPath(mPath, mountainPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
