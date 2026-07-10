import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),

                FadeSlideIn(
                  index: 0,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: c.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(AppIcons.hub, size: 100, color: c.accent),
                  ),
                ),
                const SizedBox(height: 48),

                FadeSlideIn(
                  index: 1,
                  child: Text(
                    'Welcome to\nOJT Tracker',
                    textAlign: TextAlign.center,
                    style: ts.displayLarge?.copyWith(
                      fontSize: 36,
                      height: 1.2,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                FadeSlideIn(
                  index: 2,
                  child: Text(
                    'Track your on-the-job training hours effortlessly, log attendances, and view your progress in real time.',
                    textAlign: TextAlign.center,
                    style: ts.bodyLarge?.copyWith(
                      color: c.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const Spacer(flex: 3),

                FadeSlideIn(
                  index: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Get Started'),
                  ),
                ),
                const SizedBox(height: 16),

                FadeSlideIn(
                  index: 4,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(color: c.border, width: 1.5),
                      shape: const RoundedRectangleBorder(borderRadius: kRadiusBtn),
                    ),
                    child: Text(
                      'Log In',
                      style: ts.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
