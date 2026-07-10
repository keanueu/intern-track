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
  bool _isAuthenticating = false;
  bool _isCheckingLock = false;
  bool _biometricsAvailable = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometrics();
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
      _lockService.updateActivity();
    } else if (state == AppLifecycleState.resumed) {
      _checkLock();
    }
  }

  Future<void> _checkBiometrics() async {
    final available = await _lockService.canAuthenticate();
    if (mounted) setState(() => _biometricsAvailable = available);
  }

  Future<void> _checkLock() async {
    if (_isCheckingLock) return;
    _isCheckingLock = true;
    try {
      final shouldLock = await _lockService.shouldLock(
        context.read<SettingsService>(),
      );
      if (shouldLock && mounted) {
        _lockService.lock();
        setState(() {});
        await _authenticate();
      }
    } finally {
      _isCheckingLock = false;
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    try {
      final ok = await _lockService.authenticate();
      if (ok && mounted) {
        setState(() {});
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;
    if (_lockService.isLocked) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) SystemNavigator.pop();
        },
        child: Scaffold(
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
                      ),
                      child: Semantics(
                        label: 'App is locked',
                        child: Icon(AppIcons.lock, color: c.textPrimary, size: 36),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('OJT Tracker', style: ts.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Authenticate to continue', style: ts.bodyMedium),
                    const SizedBox(height: 32),

                    if (!_biometricsAvailable) ...[
                      Icon(AppIcons.warning, color: c.warning, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        'Biometrics not available.\nPlease disable lock screen in Settings.',
                        textAlign: TextAlign.center,
                        style: ts.bodyMedium,
                      ),
                    ] else
                      SizedBox(
                        width: 200,
                        child: TapScale(
                          onTap: _isAuthenticating ? null : () => _authenticate(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: _isAuthenticating ? null : kGreenGradient,
                              color: _isAuthenticating ? c.surface2 : null,
                              borderRadius: kRadiusBtn,
                            ),
                            child: Center(
                              child: _isAuthenticating
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: c.textSecondary,
                                      ),
                                    )
                                  : Text('Unlock',
                                      style: ts.labelLarge?.copyWith(color: c.onAccent)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
