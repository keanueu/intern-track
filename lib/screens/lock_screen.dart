import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/lock_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class LockScreen extends StatefulWidget {
  final Widget child;
  const LockScreen({super.key, required this.child});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with WidgetsBindingObserver {
  final LockService _lockService = LockService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lockService.lock();
    } else if (state == AppLifecycleState.resumed) {
      _checkLock();
    }
  }

  Future<void> _checkLock() async {
    final shouldLock = await _lockService.shouldLock(
      context.read<SettingsService>(),
    );
    if (shouldLock && mounted) {
      setState(() {});
      if (_lockService.isLocked) {
        await _lockService.authenticate();
        if (mounted) setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    if (_lockService.isLocked) {
      return Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: kGreenGradientDeep,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: kGreenGlow,
                    ),
                    child: Icon(AppIcons.lock, color: c.textPrimary, size: 36),
                  ),
                  const SizedBox(height: 24),
                  Text('OJT Tracker',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: c.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Authenticate to continue',
                      style: TextStyle(fontSize: 14, color: c.textSecondary)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    child: TapScale(
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await _lockService.authenticate();
                        if (ok && mounted) {
                          setState(() {});
                        } else if (mounted) {
                          HapticFeedback.heavyImpact();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Authentication failed',
                                  style: TextStyle(color: c.textPrimary)),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: kRed,
                              shape: RoundedRectangleBorder(
                                  borderRadius: kRadiusBtn),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: kGreenGradient,
                          borderRadius: kRadiusBtn,
                          boxShadow: kGreenGlow,
                        ),
                        child: Center(
                          child: Text('Unlock',
                              style: TextStyle(
                                  color: c.onAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16)),
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
    return widget.child;
  }
}
