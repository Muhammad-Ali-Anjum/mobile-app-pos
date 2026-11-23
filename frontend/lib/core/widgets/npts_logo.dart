import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NptsLogo extends StatelessWidget {
  final double height;
  final bool isDark;

  const NptsLogo({
    super.key,
    this.height = 42,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/npts_logo.jpg',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // High fidelity vector-like fallback if asset is loading
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 2),
                color: AppColors.primary,
              ),
              child: const Text(
                'NPTS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NEXTPLANNER',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: height * 0.36,
                    letterSpacing: 1.1,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
                Text(
                  'TECH SOLUTION',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: height * 0.22,
                    letterSpacing: 1.6,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
