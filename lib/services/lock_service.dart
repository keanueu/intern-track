import 'package:local_auth/local_auth.dart';
import 'settings_service.dart';

class LockService {
  static final LockService instance = LockService._();
  LockService._();

  final LocalAuthentication _auth = LocalAuthentication();
  DateTime _lastActive = DateTime.now();
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  void updateActivity() {
    _lastActive = DateTime.now();
  }

  Future<bool> shouldLock(SettingsService settings) async {
    if (!settings.lockEnabled) return false;
    if (_isLocked) return true;
    final elapsed = DateTime.now().difference(_lastActive).inSeconds;
    if (elapsed >= settings.lockTimeoutSeconds) {
      _isLocked = true;
      return true;
    }
    return false;
  }

  Future<bool> authenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canCheck) return false;

      final result = await _auth.authenticate(
        localizedReason: 'Unlock OJT Tracker',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (result) {
        _isLocked = false;
        _lastActive = DateTime.now();
      }
      return result;
    } catch (_) {
      return false;
    }
  }

  void lock() {
    _isLocked = true;
  }

  void unlock() {
    _isLocked = false;
    _lastActive = DateTime.now();
  }
}
